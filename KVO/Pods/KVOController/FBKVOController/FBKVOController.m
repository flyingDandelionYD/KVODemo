/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBKVOController.h"

#import <objc/message.h>
#import <pthread/pthread.h>

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Convert your project to ARC or specify the -fobjc-arc flag.
#endif

NS_ASSUME_NONNULL_BEGIN

#pragma mark Utilities -

static NSString *describe_option(NSKeyValueObservingOptions option)
{
  switch (option) {
    case NSKeyValueObservingOptionNew:
      return @"NSKeyValueObservingOptionNew";
      break;
    case NSKeyValueObservingOptionOld:
      return @"NSKeyValueObservingOptionOld";
      break;
    case NSKeyValueObservingOptionInitial:
      return @"NSKeyValueObservingOptionInitial";
      break;
    case NSKeyValueObservingOptionPrior:
      return @"NSKeyValueObservingOptionPrior";
      break;
    default:
      NSCAssert(NO, @"unexpected option %tu", option);
      break;
  }
  return nil;
}

static void append_option_description(NSMutableString *s, NSUInteger option)
{
  if (0 == s.length) {
    [s appendString:describe_option(option)];
  } else {
    [s appendString:@"|"];
    [s appendString:describe_option(option)];
  }
}

static NSUInteger enumerate_flags(NSUInteger *ptrFlags)
{
  NSCAssert(ptrFlags, @"expected ptrFlags");
  if (!ptrFlags) {
    return 0;
  }

  NSUInteger flags = *ptrFlags;
  if (!flags) {
    return 0;
  }

  NSUInteger flag = 1 << __builtin_ctzl(flags);
  flags &= ~flag;
  *ptrFlags = flags;
  return flag;
}

static NSString *describe_options(NSKeyValueObservingOptions options)
{
  NSMutableString *s = [NSMutableString string];
  NSUInteger option;
  while (0 != (option = enumerate_flags(&options))) {
    append_option_description(s, option);
  }
  return s;
}


//========================================_FBKVOInfo=======================================
#pragma mark _FBKVOInfo -

typedef NS_ENUM(uint8_t, _FBKVOInfoState) {
  _FBKVOInfoStateInitial = 0,//初始化状态

  // whether the observer registration in Foundation has completed
  _FBKVOInfoStateObserving,//正在被监听

  // whether `unobserve` was called before observer registration in Foundation has completed
  // this could happen when `NSKeyValueObservingOptionInitial` is one of the NSKeyValueObservingOptions
  _FBKVOInfoStateNotObserving,//没有被监听
};

NSString *const FBKVONotificationKeyPathKey = @"FBKVONotificationKeyPathKey";

/**
 @abstract The key-value observation info.
 @discussion Object equality is only used within the scope of a controller instance. Safely omit controller from equality definition.
 */
@interface _FBKVOInfo : NSObject
@end

@implementation _FBKVOInfo
{
@public
  __weak FBKVOController *_controller;
  NSString *_keyPath; //监听的属性路径
  NSKeyValueObservingOptions _options;//监听的属性选择
  SEL _action;//要执行SEL
  void *_context;//监听的上下文
  FBKVONotificationBlock _block;//要执行的block
  _FBKVOInfoState _state;//被监听属性的对象的状态（初始化、正在被监听、没有被监听）
}

//初始化对象，保存相应的属性
- (instancetype)initWithController:(FBKVOController *)controller
                           keyPath:(NSString *)keyPath
                           options:(NSKeyValueObservingOptions)options
                             block:(nullable FBKVONotificationBlock)block
                            action:(nullable SEL)action
                           context:(nullable void *)context
{
  self = [super init];
  if (nil != self) {
    _controller = controller;
    _block = [block copy];
    _keyPath = [keyPath copy];
    _options = options;
    _action = action;
    _context = context;
  }
  return self;
}

//初始化（block监听方法）
- (instancetype)initWithController:(FBKVOController *)controller keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(FBKVONotificationBlock)block
{
  return [self initWithController:controller keyPath:keyPath options:options block:block action:NULL context:NULL];
}

//初始化（action监听方法）
- (instancetype)initWithController:(FBKVOController *)controller keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options action:(SEL)action
{
  return [self initWithController:controller keyPath:keyPath options:options block:NULL action:action context:NULL];
}


//初始化（带上下文，实现系统的observe方法来监听）
- (instancetype)initWithController:(FBKVOController *)controller keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
  return [self initWithController:controller keyPath:keyPath options:options block:NULL action:NULL context:context];
}

//初始化（默认的option以及实现系统的方法来监听）
- (instancetype)initWithController:(FBKVOController *)controller keyPath:(NSString *)keyPath
{
  return [self initWithController:controller keyPath:keyPath options:0 block:NULL action:NULL context:NULL];
}


// NSMapTable<id, NSMutableSet<_FBKVOInfo *> *> *_objectInfosMap; 里面的NSMutableSet的_FBKVOInfo对象会进行比较的
//重写了hash和isEqual的方法（_FBKVOInfo的唯一性由keyPath决定）
//当把一个实例添加到NSMutableSet，一定会 调用hash方法
//当继续添加一个实例到NSMutableSet,先调用hash方法后，会根据其返回值，判断是否需要继续调用isEqual:方法（不等等一个一个的比较），有一个相同就不添加啦，不相同则添加
- (NSUInteger)hash
{
  return [_keyPath hash];
}

- (BOOL)isEqual:(id)object
{
  //为空 则为 NO
  if (nil == object) {
    return NO;
  }
    
  //是本身对象 YES
  if (self == object) {
    return YES;
  }

  //如果不是_FBKVOInfo类  NO
  if (![object isKindOfClass:[self class]]) {
    return NO;
  }
  
  //如果_keyPath相同 则 YES  不同 NO
  return [_keyPath isEqualToString:((_FBKVOInfo *)object)->_keyPath];
}


- (NSString *)debugDescription
{
  NSMutableString *s = [NSMutableString stringWithFormat:@"<%@:%p keyPath:%@", NSStringFromClass([self class]), self, _keyPath];
  if (0 != _options) {
    [s appendFormat:@" options:%@", describe_options(_options)];
  }
  if (NULL != _action) {
    [s appendFormat:@" action:%@", NSStringFromSelector(_action)];
  }
  if (NULL != _context) {
    [s appendFormat:@" context:%p", _context];
  }
  if (NULL != _block) {
    [s appendFormat:@" block:%p", _block];
  }
  [s appendString:@">"];
  return s;
}

@end

//======================================_FBKVOSharedController============================================
#pragma mark _FBKVOSharedController -
//执行监听 以及 实现监听方法的真正实现者
@interface _FBKVOSharedController : NSObject

//单例方法
+ (instancetype)sharedController;

//添加监听（传入info对象）
- (void)observe:(id)object info:(nullable _FBKVOInfo *)info;


//移除监听（传入info对象）
- (void)unobserve:(id)object info:(nullable _FBKVOInfo *)info;


//移除多个监听（传入infos集合对象）
- (void)unobserve:(id)object infos:(nullable NSSet *)infos;

@end

@implementation _FBKVOSharedController
{
  NSHashTable<_FBKVOInfo *> *_infos;//存放_infos的hashTable表
  //NSHashTable使用可参考  https://www.jianshu.com/p/079eeeff81f7
  pthread_mutex_t _mutex;//互斥锁
}


//单例方法
+ (instancetype)sharedController
{
  static _FBKVOSharedController *_controller = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _controller = [[_FBKVOSharedController alloc] init];
  });
  return _controller;
}

- (instancetype)init
{
  self = [super init];
  if (nil != self) {
    //创建infos 的hashTable对象
    NSHashTable *infos = [NSHashTable alloc];
#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
    _infos = [infos initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
    if ([NSHashTable respondsToSelector:@selector(weakObjectsHashTable)]) {
      _infos = [infos initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
    } else {
      // silence deprecated warnings
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
      _infos = [infos initWithOptions:NSPointerFunctionsZeroingWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
#pragma clang diagnostic pop
    }

#endif
    pthread_mutex_init(&_mutex, NULL);//初始化互斥锁_mutex
  }
  return self;
}

- (void)dealloc
{
  pthread_mutex_destroy(&_mutex);//释放互斥锁_mutex
}

- (NSString *)debugDescription
{
  NSMutableString *s = [NSMutableString stringWithFormat:@"<%@:%p", NSStringFromClass([self class]), self];

  // 加锁
  pthread_mutex_lock(&_mutex);

  NSMutableArray *infoDescriptions = [NSMutableArray arrayWithCapacity:_infos.count];
  for (_FBKVOInfo *info in _infos) {
    [infoDescriptions addObject:info.debugDescription];
  }

  [s appendFormat:@" contexts:%@", infoDescriptions];

  // 解锁
  pthread_mutex_unlock(&_mutex);

  [s appendString:@">"];
  return s;
}


//添加监听（传入info对象）
- (void)observe:(id)object info:(nullable _FBKVOInfo *)info
{
  if (nil == info) {
    return;
  }

  //加锁
  pthread_mutex_lock(&_mutex);
 
  //将info添加到hashTable里
  [_infos addObject:info];

  //加锁
  pthread_mutex_unlock(&_mutex);

  //调用系统的 KVO的方法
  [object addObserver:self forKeyPath:info->_keyPath options:info->_options context:(void *)info];

  //如果状态为初始化，则转为真正监听
  if (info->_state == _FBKVOInfoStateInitial) {
    info->_state = _FBKVOInfoStateObserving;
  } else if (info->_state == _FBKVOInfoStateNotObserving) {//如果没有被监听，则移除监听者
    [object removeObserver:self forKeyPath:info->_keyPath context:(void *)info];
  }
}


//移除监听
- (void)unobserve:(id)object info:(nullable _FBKVOInfo *)info
{
  if (nil == info) {
    return;
  }

  //加锁
  pthread_mutex_lock(&_mutex);
    
  //将info从hashTable移除
  [_infos removeObject:info];

  //解锁
  pthread_mutex_unlock(&_mutex);
  
  //如果正在监听，则移除
  if (info->_state == _FBKVOInfoStateObserving) {
    [object removeObserver:self forKeyPath:info->_keyPath context:(void *)info];
  }
  //状态改为 没有被监听
  info->_state = _FBKVOInfoStateNotObserving;
}

//移除多个监听（传入infos集合对象）
- (void)unobserve:(id)object infos:(nullable NSSet<_FBKVOInfo *> *)infos
{
  if (0 == infos.count) {
    return;
  }

  //加锁
  pthread_mutex_lock(&_mutex);
  
  //for-in 将info从hashTable移除
  for (_FBKVOInfo *info in infos) {
    [_infos removeObject:info];
  }
 //解锁
  pthread_mutex_unlock(&_mutex);

 //for-in 改变状态
  for (_FBKVOInfo *info in infos) {
    if (info->_state == _FBKVOInfoStateObserving) {
        //移除监听
      [object removeObserver:self forKeyPath:info->_keyPath context:(void *)info];
    }
    info->_state = _FBKVOInfoStateNotObserving;
  }
}


//实现系统的KVO(真正的监听执行处)
- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSString *, id> *)change
                       context:(nullable void *)context
{
  NSAssert(context, @"missing context keyPath:%@ object:%@ change:%@", keyPath, object, change);

  _FBKVOInfo *info;

  {
    //加锁
    pthread_mutex_lock(&_mutex);
    
    //拿到info
    info = [_infos member:(__bridge id)context]; //Line 324行  传入的context:是(void *)info对象
    //解锁
    pthread_mutex_unlock(&_mutex);
  }

  //存在
  if (nil != info) {
    //拿到监听者
    FBKVOController *controller = info->_controller;
    if (nil != controller) {
        //拿到要监听的对象
      id observer = controller.observer;
      if (nil != observer) {

        //如果监听的是通过blcok回调
        if (info->_block) {
          NSDictionary<NSString *, id> *changeWithKeyPath = change;
          if (keyPath) {//如果监听的keypath存在
            NSMutableDictionary<NSString *, id> *mChange = [NSMutableDictionary dictionaryWithObject:keyPath forKey:FBKVONotificationKeyPathKey];
            [mChange addEntriesFromDictionary:change];//拼接字典
            changeWithKeyPath = [mChange copy];
          }
          info->_block(observer, object, changeWithKeyPath);
        } else if (info->_action) { //如果监听的是通过SEL
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          [observer performSelector:info->_action withObject:change withObject:object];
#pragma clang diagnostic pop
        } else {//其他：调用系统的observeValueForKeyPath...的方法
          [observer observeValueForKeyPath:keyPath ofObject:object change:change context:info->_context];
        }
      }
    }
  }
}

@end


//======================================FBKVOController============================================
#pragma mark FBKVOController -
@implementation FBKVOController
{
  //对于NSMApTable的说明：可参考https://www.jianshu.com/p/fb5db92bd1b8
  NSMapTable<id, NSMutableSet<_FBKVOInfo *> *> *_objectInfosMap; //里面key是传进来的object（要监听的对象），value是一个set集合（_FBKVOInfo对象）
  pthread_mutex_t _lock; //互斥锁
}

#pragma mark Lifecycle -

//初始化对象类方法
+ (instancetype)controllerWithObserver:(nullable id)observer
{
  return [[self alloc] initWithObserver:observer];
}

//初始化对象方法
- (instancetype)initWithObserver:(nullable id)observer retainObserved:(BOOL)retainObserved
{
  self = [super init];
  if (nil != self) {
    //将传入的观察者保存到属性_observer
    _observer = observer;
      
    /*
     NSPointerFunctionsOptions枚举：
     NSPointerFunctionsStrongMemory             // 和strong一样，默认
     NSPointerFunctionsZeroingWeakMemory        // 已废弃，在 GC 下，弱引用指针，防止悬挂指针
     NSPointerFunctionsOpaqueMemory             // 在指针去除时不做任何动作
     NSPointerFunctionsMallocMemory             // 去除时调用free() , 加入时calloc()
     NSPointerFunctionsMachVirtualMemory        //使用可执行文件的虚拟内存
     NSPointerFunctionsWeakMemory               //和weak一样
     NSPointerFunctionsObjectPersonality        /使用NSObject的hash、isEqual、description，默认
     NSPointerFunctionsOpaquePersonality        //使用偏移后指针，进行hash和直接比较等同性
     NSPointerFunctionsObjectPointerPersonality //和上一个相同，多了description方法
     NSPointerFunctionsCStringPersonality       //使用c字符串的hash和strcmp比较，%s作为decription
     NSPointerFunctionsStructPersonality        // 使用内存的hash和memcmp
     NSPointerFunctionsIntegerPersonality       //使用偏移量作为hash和等同性判断
     NSPointerFunctionsCopyIn                   //通过NSCopying方法，复制后存入
     */
     NSPointerFunctionsOptions keyOptions = retainObserved ? NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPointerPersonality : NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality;
      
     //初始化_objectInfosMap对象（用来存放要监听的属性key-value）(上面已经说明)
      _objectInfosMap = [[NSMapTable alloc] initWithKeyOptions:keyOptions valueOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality capacity:0];
      
      //初始化 互斥锁_lock
      pthread_mutex_init(&_lock, NULL);
  }
  return self;
}

//初始化对象方法
- (instancetype)initWithObserver:(nullable id)observer
{
  return [self initWithObserver:observer retainObserved:YES];
}

//重写dealloc方法：
- (void)dealloc
{
   [self unobserveAll];//移除所有的观察对象
   pthread_mutex_destroy(&_lock);//并且释放互斥锁_lock
}

#pragma mark Properties -
//debugDescription的get方法
- (NSString *)debugDescription
{
  NSMutableString *s = [NSMutableString stringWithFormat:@"<%@:%p", NSStringFromClass([self class]), self];
  [s appendFormat:@" observer:<%@:%p>", NSStringFromClass([_observer class]), _observer];

  //加锁：防止在读取的过程中：会对_objectInfosMap进行write的操作
  pthread_mutex_lock(&_lock);

  //如果mapTable里面有数据就拼接  “\n”
  if (0 != _objectInfosMap.count) {
    [s appendString:@"\n  "];
  }

  //通过for-in ==>
  /*
  mapTable{
            {key1(object):infos(_FBKVOInfo1,_FBKVOInfo2,...)}，
            {key2(object):infos(_FBKVOInfo1,_FBKVOInfo2,...)},
            ...
          }
  */
  for (id object in _objectInfosMap) {
    NSMutableSet *infos = [_objectInfosMap objectForKey:object];
    NSMutableArray *infoDescriptions = [NSMutableArray arrayWithCapacity:infos.count];
    [infos enumerateObjectsUsingBlock:^(_FBKVOInfo *info, BOOL *stop) {
      [infoDescriptions addObject:info.debugDescription];
    }];
    [s appendFormat:@"%@ -> %@", object, infoDescriptions];
  }

  //解锁
  pthread_mutex_unlock(&_lock);

  //末尾拼上 “>”
  [s appendString:@">"];
  return s;
}

#pragma mark Utilities -

- (void)_observe:(id)object info:(_FBKVOInfo *)info
{
  //加锁
  pthread_mutex_lock(&_lock);

 //拿到infos的set集合
  NSMutableSet *infos = [_objectInfosMap objectForKey:object];

  //检查_FBKVOInfo是否已经存在
  _FBKVOInfo *existingInfo = [infos member:info];
    
  //已经存在啦
   if (nil != existingInfo) {
    //解锁，直接返回（已经有了，不需要再次添加啦）
    pthread_mutex_unlock(&_lock);
    return;
  }

  //如果此时集合为nil，就进行懒加载 创建set集合对象
  if (nil == infos) {
    infos = [NSMutableSet set];
    //将其加入到mapTable里面
    [_objectInfosMap setObject:infos forKey:object];
  }

  //将info对象加入到infos集合内
  [infos addObject:info];

  //解锁
  pthread_mutex_unlock(&_lock);

  //调用_FBKVOSharedController的observe：info：方法（真正的操作者）
  [[_FBKVOSharedController sharedController] observe:object info:info];
}

//移除观察的对象和观察属性（具体的）
- (void)_unobserve:(id)object info:(_FBKVOInfo *)info
{
  //加锁
  pthread_mutex_lock(&_lock);

  //通过object的key来获取监听的属性集合（infos）
  NSMutableSet *infos = [_objectInfosMap objectForKey:object];

  //找到集合里面的 info对象（监听的属性对象）（判断该集合是否含有某个对象）
  _FBKVOInfo *registeredInfo = [infos member:info];

  //如果集合里面存在了
  if (nil != registeredInfo) {
     //将他从集合里面移除
    [infos removeObject:registeredInfo];

    //如果移除过后,集合里面的元素为空了，就将集合也从那个mapTable里面移除鸟
    if (0 == infos.count) {
      [_objectInfosMap removeObjectForKey:object];
    }
  }

  //解锁
  pthread_mutex_unlock(&_lock);

  //通过_FBKVOSharedController对象来移除监听（真正的操作者）
  [[_FBKVOSharedController sharedController] unobserve:object info:registeredInfo];
}


//直接移除观察的对象（里面的属性监听都给移除掉）
- (void)_unobserve:(id)object
{
  //加锁
  pthread_mutex_lock(&_lock);

  NSMutableSet *infos = [_objectInfosMap objectForKey:object];

  //直接将object（key）对于的集合监听从mapTable里面移除掉
  [_objectInfosMap removeObjectForKey:object];

  //解锁
  pthread_mutex_unlock(&_lock);

  //调用_FBKVOSharedController对象的移除对象方法（真正的操作者）
  [[_FBKVOSharedController sharedController] unobserve:object infos:infos];
}


//移除所有的监听
- (void)_unobserveAll
{
  //加锁
  pthread_mutex_lock(&_lock);

  //先将mapTable拷贝一份
  NSMapTable *objectInfoMaps = [_objectInfosMap copy];

  //将mapTable里面的全给移除了
  [_objectInfosMap removeAllObjects];

  //解锁
  pthread_mutex_unlock(&_lock);

  //拿到真正操作的对象
  _FBKVOSharedController *shareController = [_FBKVOSharedController sharedController];
  
  //for-in 来移除里面的所有的监听的属性对象
  for (id object in objectInfoMaps) {
    NSSet *infos = [objectInfoMaps objectForKey:object];
    [shareController unobserve:object infos:infos];
  }
}

#pragma mark API -

//添加单个监听属性（要监听谁、要监听的属性、...）
- (void)observe:(nullable id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(FBKVONotificationBlock)block
{
 //如果 keyPath、block空则报错提示
  NSAssert(0 != keyPath.length && NULL != block, @"missing required parameters observe:%@ keyPath:%@ block:%p", object, keyPath, block);
  //如果keyPath是空字符串或者object为空或block为空则直接返回啦
  if (nil == object || 0 == keyPath.length || NULL == block) {
    return;
  }

  //创建一个要监听的属性的_FBKVOInfo属性（里面存放监听到的block操作，keyPath等等）
  _FBKVOInfo *info = [[_FBKVOInfo alloc] initWithController:self keyPath:keyPath options:options block:block];

  //开始调用监听方法
  [self _observe:object info:info];
}


//添加监听多个属性（要监听谁、要监听的属性、...）
- (void)observe:(nullable id)object keyPaths:(NSArray<NSString *> *)keyPaths options:(NSKeyValueObservingOptions)options block:(FBKVONotificationBlock)block
{
 //如果 keyPath、block空则报错提示
  NSAssert(0 != keyPaths.count && NULL != block, @"missing required parameters observe:%@ keyPath:%@ block:%p", object, keyPaths, block);
  
  //如果keyPaths是空数组或者object为空或block为空则直接返回啦
  if (nil == object || 0 == keyPaths.count || NULL == block) {
    return;
  }

 //for-in 遍历添加监听
  for (NSString *keyPath in keyPaths) {
    [self observe:object keyPath:keyPath options:options block:block];
  }
}

//添加单个监听属性（要监听谁、要监听的属性、...）
- (void)observe:(nullable id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options action:(SEL)action
{
 //如果没有keypath、action为空，直接报错
  NSAssert(0 != keyPath.length && NULL != action, @"missing required parameters observe:%@ keyPath:%@ action:%@", object, keyPath, NSStringFromSelector(action));
   
 //如果监听者没有实现监听的方法则报错
  NSAssert([_observer respondsToSelector:action], @"%@ does not respond to %@", _observer, NSStringFromSelector(action));

 //如果要监听的对象OR其属性OR监听的方法为空 直接返回
  if (nil == object || 0 == keyPath.length || NULL == action) {
    return;
  }
    
    
 //创建一个要监听的属性的_FBKVOInfo属性（里面存放监听到的action操作，keyPath等等）
  _FBKVOInfo *info = [[_FBKVOInfo alloc] initWithController:self keyPath:keyPath options:options action:action];
    
  [self _observe:object info:info];
}

//添加监听多个属性（要监听谁、要监听的属性、...）
- (void)observe:(nullable id)object keyPaths:(NSArray<NSString *> *)keyPaths options:(NSKeyValueObservingOptions)options action:(SEL)action
{
    
  //如果keypaths数组为空、action为空，直接报错
  NSAssert(0 != keyPaths.count && NULL != action, @"missing required parameters observe:%@ keyPath:%@ action:%@", object, keyPaths, NSStringFromSelector(action));
  
//如果监听者没有实现监听的方法则报错
  NSAssert([_observer respondsToSelector:action], @"%@ does not respond to %@", _observer, NSStringFromSelector(action));
 
 //如果要监听的对象OR其属性OR监听的方法为空 直接返回
  if (nil == object || 0 == keyPaths.count || NULL == action) {
    return;
  }

  //for-in 添加
  for (NSString *keyPath in keyPaths) {
    [self observe:object keyPath:keyPath options:options action:action];
  }
}


//添加单个监听属性（带上下文的...）
- (void)observe:(nullable id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context
{
 
  //如果keyPath为空、空字符串直接报错
  NSAssert(0 != keyPath.length, @"missing required parameters observe:%@ keyPath:%@", object, keyPath);
  
  //如果object为空 OR keyPath不存在或空字符串
  if (nil == object || 0 == keyPath.length) {
    return;
  }

  //创建一个要监听的属性的_FBKVOInfo属性（里面存放keyPath，context等等）
  _FBKVOInfo *info = [[_FBKVOInfo alloc] initWithController:self keyPath:keyPath options:options context:context];

  //添加监听
  [self _observe:object info:info];
}

////添加多个监听属性（带上下文的...）
- (void)observe:(nullable id)object keyPaths:(NSArray<NSString *> *)keyPaths options:(NSKeyValueObservingOptions)options context:(nullable void *)context
{
  //如果没有keyPaths则报错
  NSAssert(0 != keyPaths.count, @"missing required parameters observe:%@ keyPath:%@", object, keyPaths);

  //如果object为空 OR keyPath数组为空
  if (nil == object || 0 == keyPaths.count) {
    return;
  }

  //for-in 添加
  for (NSString *keyPath in keyPaths) {
    [self observe:object keyPath:keyPath options:options context:context];
  }
}


//移除被观察属性keyPath
- (void)unobserve:(nullable id)object keyPath:(NSString *)keyPath
{
  //创建一个_FBKVOInfo对象
  _FBKVOInfo *info = [[_FBKVOInfo alloc] initWithController:self keyPath:keyPath];

  //移除
  [self _unobserve:object info:info];
}

//移除被观察对象下的所有的被监听的属性
- (void)unobserve:(nullable id)object
{
  if (nil == object) {
    return;
  }

  [self _unobserve:object];
}

//移除所有的监听
- (void)unobserveAll
{
  [self _unobserveAll];
}

@end

NS_ASSUME_NONNULL_END
