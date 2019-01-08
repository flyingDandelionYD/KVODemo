//
//  KVOBaseUsesViewController_1.m
//  KVO
//

//

#import "KVOBaseUsesViewController_1.h"
#import "School.h"

@interface KVOBaseUsesViewController_1 ()
@property (nonatomic,strong)School  *myhool;
@end

@implementation KVOBaseUsesViewController_1

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化对象
    self.myhool = [[School alloc]init];
    Person_ *leader  = [[Person_ alloc]init];
    leader.age = 60;
    self.myhool.leader = leader;
    self.myhool.lastTime = 100;
    
    [self addObserver_1];
    
//    [self addObserver_2];
    
//    [self addObserver_3];
    
    Student *stu = [[Student  alloc]init];
    [self.myhool addObserver:stu forKeyPath:@"lastTime" options:NSKeyValueObservingOptionNew context:nil];
    
    //为了测试观察者对象被释放了，再次发送消息，则会崩溃（所以要去移除）（即：add和remove需要成对出现）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [self.myhool removeObserver:stu forKeyPath:@"lastTime"];
    });
}


//observer观察者对象，值变化时通知的对象

//keyPath监听的属性:是字符串，也可以使用对象属性的属性的字符串

/*
 context通知的上下文:
 1.当同一个观察者对同一类的不同对象同一属性
 2.OR不同类的对象的相同属性进行监听时，可以使用改参数进行区分
 */

/*
 NSKeyValueObservingOptions（可以写成“|”的形式哟，来获取前后的变值）
 1.NSKeyValueObservingOptionNew：属性更改的新值
 2.NSKeyValueObservingOptionOld：属性更改前的旧值
 3.NSKeyValueObservingOptionInitial:如果设置了这个值，将会立刻向观察者对象发送一次通知
 4.NSKeyValueObservingOptionPrior:设置了该值后会在属性发生改变前和改变后都通知一次
 */

-(void)addObserver_1{
    [self.myhool addObserver:self forKeyPath:@"lastTime" options:NSKeyValueObservingOptionNew context:@"lastTime"];
    [self.myhool addObserver:self forKeyPath:@"leader.age" options:NSKeyValueObservingOptionOld context:@"leader.age"];
}


-(void)addObserver_2{
    //只监听最基本的属性值的改变
    [self.myhool addObserver:self forKeyPath:@"lastTime" options:NSKeyValueObservingOptionInitial context:@"lastTime"];
    //监听了属性对象里面的属性值的改变
    [self.myhool addObserver:self forKeyPath:@"leader.age" options:NSKeyValueObservingOptionPrior context:@"leader.age"];
}

-(void)addObserver_3{
     //写成“|”的形式哟
     [self.myhool addObserver:self forKeyPath:@"lastTime" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:@"lastTime"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
      NSLog(@"监听到%@的%@属性值改变了 - %@ - %@", object, keyPath, change, context);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.myhool.lastTime = 120;
    self.myhool.leader.age = 180;
}

//移除观察者
-(void)dealloc{
    
    //全部移除：lastTime的监听
    [self.myhool removeObserver:self forKeyPath:@"lastTime"];

    //只移除：上下文为->leader.age的监听
    [self.myhool removeObserver:self forKeyPath:@"leader.age" context:@"leader.age"];
    
#warning - 再次调用会崩溃
//    [self.myhool removeObserver:self forKeyPath:@"leader.age" context:@"leader.age"];
    
    NSLog(@"%s",__FUNCTION__);
}
@end
