//
//  KVOBaseUsesViewController_10.m
//  KVO
//


#import "KVOBaseUsesViewController_10.h"
#import "Person_.h"

@interface KVOBaseUsesViewController_10()
@property (nonatomic,strong)Person_*p;
@end

@implementation KVOBaseUsesViewController_10

- (void)viewDidLoad {
    [super viewDidLoad];
    self.p = [Person_ new];
    [self.p addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew context:nil];
    [self.p addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew context:nil];
    id info = self.p.observationInfo;
    NSLog(@"%@", [info description]);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.p.age = 10;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
     NSLog(@"监听到%@的%@属性值改变了 - %@ - %@", object, keyPath, change, context);
}

-(void)dealloc{
    [self.p removeObserver:self forKeyPath:@"age"];
    [self.p removeObserver:self forKeyPath:@"age"];
    
    //添加了2次 就移除2次（多一次会炸）
    //[self.p removeObserver:self forKeyPath:@"age"];
}
@end
