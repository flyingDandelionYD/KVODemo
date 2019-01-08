//
//  KVOBaseUsesViewController_14.m
//  KVO
//


#import "KVOBaseUsesViewController_14.h"
#import "KVOBaseUsesViewController_14_2.h"
#import <KVOController/KVOController.h>

@interface Student_1 : NSObject
@end

@implementation Student_1
-(void)propertyHasChanged:(id)sender{
    NSLog(@"属性改变啦：%@",sender);
}
@end

@interface TestModel : NSObject
@property (nonatomic,strong)NSString  *name;
@property (nonatomic,assign)int  age;
@end

@implementation TestModel
@end


@interface KVOBaseUsesViewController_14 ()
@property (nonatomic,strong)TestModel  *t;
@property (nonatomic,strong)FBKVOController *fbKVOController;
@property (nonatomic,strong)Student_1  *stu;
@end

@implementation KVOBaseUsesViewController_14

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *jumpBtn = [UIButton new];
    jumpBtn.frame = CGRectMake(20, 100, 150, 80);
    [self.view  addSubview:jumpBtn];
    [jumpBtn setTitle:@"跳转VC" forState:UIControlStateNormal];
    [jumpBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [jumpBtn addTarget:self action:@selector(jump) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    self.t  = [[TestModel alloc]init];
    
    //初始化：方式1 (类方法)
//    self.fbKVOController = [FBKVOController controllerWithObserver:self];
    
//    Student_1 *stu = [Student_1 new];
//    self.fbKVOController = [FBKVOController  controllerWithObserver:stu];
    
    
//    self.stu = [Student_1 new];
//    self.fbKVOController = [FBKVOController  controllerWithObserver:self.stu];
    
    //初始化：方式2 （实例方法）
//    self.fbKVOController = [[FBKVOController   alloc]initWithObserver:self];
    
    //初始化：方式3 （实例方法） 持有 默认YES
    self.fbKVOController = [[FBKVOController   alloc]initWithObserver:self retainObserved:YES];
    
    //初始化：方式4 （实例方法） 不持有
//      self.fbKVOController = [[FBKVOController   alloc]initWithObserver:self retainObserved:NO];

    
    //监听：方式1 通过SEL来监听
//    [self.fbKVOController observe:self.t keyPath:@"name" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld action:@selector(propertyHasChanged:)];
//
    
    //监听：方式2 通过block来监听
//    [self.fbKVOController observe:self.t keyPath:@"age" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
//          NSLog(@"监听者%@监听到%@的属性值改变了 - %@",observer, object, change);
//    }];
    
    
    //监听：方式3 带上下文 实现：observeValueForKeyPath方法来监听
//    [self.fbKVOController observe:self.t keyPath:@"age" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:@"theWay3"];
    
    //监听：方式4  可以监听多个属性 通过SEL来监听
//    [self.fbKVOController observe:self.t keyPaths:@[@"name",@"age"] options:NSKeyValueObservingOptionNew |NSKeyValueObservingOptionOld action:@selector(propertyHasChanged:)];

    
    //监听：方式5  可以监听多个属性 通过block监听
//    [self.fbKVOController observe:self.t keyPaths:@[@"name",@"age"] options:NSKeyValueObservingOptionNew |NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
//          NSLog(@"监听者%@监听到%@的属性值改变了 - %@",observer, object, change);
//    }];
    
     //监听：方式6  可以监听多个属性 带上下文 实现：observeValueForKeyPath方法来监听
//    [self.fbKVOController observe:self.t keyPaths:@[@"name",@"age"] options:NSKeyValueObservingOptionNew |NSKeyValueObservingOptionOld context:@"theWay6"];
    
    NSLog(@"------END------");
    
    
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
     NSLog(@"监听到%@的%@属性值改变了 - %@ - %@", object, keyPath, change, context);
}

-(void)propertyHasChanged:(id)sender{
    NSLog(@"属性改变啦：%@",sender);
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.t.name = @"Lucy";
    self.t.age = 18;
}

-(void)jump{
    KVOBaseUsesViewController_14_2* vc2 = [KVOBaseUsesViewController_14_2 new];
    vc2.vc1 = self;
    [self.fbKVOController observe:vc2 keyPath:@"vc1.t.name" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld action:@selector(propertyHasChanged:)];
    [self.navigationController pushViewController:vc2 animated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.t.name = @"Jack";
        self.t.age = 16;
    });
}

-(void)dealloc{
    
    //注销方式1
//    [self.fbKVOController unobserve:self.t keyPath:@"name"];
//    [self.fbKVOController unobserve:self.t keyPath:@"name"];
    
    //注销方式2
//    [self.fbKVOController unobserve:self.t];
//    [self.fbKVOController unobserve:self.t];
    
    //注销方式3
    [self.fbKVOController unobserveAll];
    
    NSLog(@"%s",__FUNCTION__);
}
@end
