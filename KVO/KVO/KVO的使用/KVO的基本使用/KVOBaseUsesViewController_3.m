//
//  KVOBaseUsesViewController_3.m
//  KVO
//


#import "KVOBaseUsesViewController_3.h"

@interface Boy : NSObject
@property (nonatomic,strong)NSString  *name;
@end

@implementation Boy
/*关闭自动通知 */
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    return ![key isEqualToString:@"name"];
}

/* 手动发送通知 */
- (void)setName:(NSString *)name{
    [self willChangeValueForKey:@"name"];
    _name = name;
    NSLog(@"在改变呢");
    [self didChangeValueForKey:@"name"];
    NSLog(@"已经改变了值");
}
@end


@interface KVOBaseUsesViewController_3 ()
@property (nonatomic,strong)Boy  *myBoy;
@end

@implementation KVOBaseUsesViewController_3

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myBoy = [[Boy alloc]init];
    
    [self.myBoy addObserver:self forKeyPath:@"name" options:(NSKeyValueObservingOptionNew) context:nil];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
     NSLog(@"监听到%@的%@属性值改变了 - %@ - %@", object, keyPath, change, context);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.myBoy.name = @"Lucky";
}
-(void)dealloc{
    [self.myBoy removeObserver:self forKeyPath:@"name" ];
}

@end



