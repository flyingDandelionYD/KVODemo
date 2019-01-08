//
//  KVOBaseUsesViewController_13.m
//  KVO
//


/*
 我们自己写一个来进行添加和删除的控制（替换系统的方法）
 */
#import "KVOBaseUsesViewController_13.h"
#import "Person_.h"
#import "NSObject+myKVO2.h"

@interface KVOBaseUsesViewController_13()
@property (nonatomic,strong)Person_*p;
@end

@implementation KVOBaseUsesViewController_13

- (void)viewDidLoad {
    [super viewDidLoad];
    self.p = [Person_ new];
    [self.p addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew context:@"1"];
    [self.p addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew context:@"2"];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.p.age = 10;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"监听到%@的%@属性值改变了 - %@ - %@", object, keyPath, change, context);
}

-(void)dealloc{
    [self.p removeObserver:self forKeyPath:@"age" context:@"1"];
    [self.p removeObserver:self forKeyPath:@"age" context:@"2"];
    [self.p removeObserver:self forKeyPath:@"age" context:@"1"];
    
    /*这样写会炸的哟，因为只叫唤了：removeObserver:forKeyPath:context:的方法
    [self.p removeObserver:self forKeyPath:@"age"];
    [self.p removeObserver:self forKeyPath:@"age"];
    [self.p removeObserver:self forKeyPath:@"age"];
     */
}
@end

