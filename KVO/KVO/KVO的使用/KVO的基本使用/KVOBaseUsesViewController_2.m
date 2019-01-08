//
//  KVOBaseUsesViewController_2.m
//  KVO
//


#import "KVOBaseUsesViewController_2.h"
#import "School.h"

@interface KVOBaseUsesViewController_2 ()
@property (nonatomic,strong)School  *myhool;
@end

@implementation KVOBaseUsesViewController_2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化对象
    self.myhool = [[School alloc]init];
    Person_ *leader  = [[Person_ alloc]init];
    leader.age = 60;
    self.myhool.leader = leader;
    
    [self.myhool addObserver:self forKeyPath:@"leader.age" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:@"leader.age"];
    
}

//观察者监听的方法
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
#warning 对于NSKeyValueChangeKey里面的详细说明，后面会详细说明
    NSLog(@"监听到%@的%@属性值改变了 - %@ - %@", object, keyPath, change, context);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.myhool.leader.age = 180;
}

-(void)dealloc{
    [self.myhool removeObserver:self forKeyPath:@"leader.age" context:@"leader.age"];
}

@end
