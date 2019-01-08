//
//  NSObject+KVO.m
//  KVO


#import "NSObject+KVO.h"
#import <objc/runtime.h>
#import <objc/message.h>


@implementation NSObject (KVO)
-(void)my_ddObserver:(NSObject*)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context{
    //动态添加一个类
    NSString *originClassName = NSStringFromClass([self class]);
    
    //苹果创建的是 NSKVONotifying_  为前缀的
    NSString *newClassName = [@"myKVONotifying_" stringByAppendingString:originClassName];
    
    
    const char *newName = [newClassName UTF8String];
    
    // 继承自当前类，创建一个子类
    Class kvoClass = objc_allocateClassPair([self class], newName, 0);
    
    // 添加setter方法
    class_addMethod(kvoClass, @selector(setName:), (IMP)setName, "v@:@@");
    
    //注册新添加的这个类
    objc_registerClassPair(kvoClass);
    
    // 修改isa,本质就是改变当前对象的类名
    object_setClass(self, kvoClass);
    
    // 保存观察者属性到当前类中
    objc_setAssociatedObject(self, (__bridge const void *)@"observer", observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

#pragma mark - 重写父类方法
void setName(id self, SEL _cmd, NSString *name) {
    
    // 保存当前KVO的类
    Class kvoClass = [self class];
    
    // 将self的isa指针指向父类myPerson，调用父类setter方法
    object_setClass(self, class_getSuperclass([self class]));
    
#warning -- 这边方法会报错：build Settings 里面搜索enable strict 修改为NO即可
    // 调用父类setter方法，重新复制
    objc_msgSend(self, @selector(setName:), name);
    
    // 取出myKVO_Person观察者
    id objc = objc_getAssociatedObject(self, (__bridge const void *)@"observer");

    
    // 通知观察者，执行通知方法
    //这里是直接重新写的setName方法，所以很容易知道是 “name”
    objc_msgSend(objc, @selector(observeValueForKeyPath:ofObject:change:context:), @"name", self, @{@"kind":@"kind_value",@"new":@"new_value",@"old":@"old_value"}, @"这里是监听的上下文环境");
    
    // 重新修改为myKVO_Person类
    object_setClass(self, kvoClass);
    
}
@end
