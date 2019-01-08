//
//  KVOBaseUsesViewController_6.m
//  KVO
//


#import "KVOBaseUsesViewController_6.h"

@interface Test_6 : NSObject
@property (nonatomic,strong)NSString  *name;
@property (nonatomic,assign)double  height;
@end

@implementation Test_6

/*关闭自动通知 */
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    return ![key isEqualToString:@"name"];
}

- (void)setName:(NSString *)name{
    [self willChangeValueForKey:@"name"];
    [self willChangeValueForKey:@"height"];
    _name = name;
    _height = _height++;
    [self didChangeValueForKey:@"name"];
    [self didChangeValueForKey:@"height"];
}
@end

@interface KVOBaseUsesViewController_6 ()
@property (nonatomic,strong)Test_6  *test;
@end

@implementation KVOBaseUsesViewController_6

- (void)viewDidLoad {
    [super viewDidLoad];
    self.test = [[Test_6 alloc]init];
    
    [self.test addObserver:self forKeyPath:@"name" options:(NSKeyValueObservingOptionNew) context:nil];
    [self.test addObserver:self forKeyPath:@"height" options:(NSKeyValueObservingOptionNew) context:nil];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"监听到%@的%@属性值改变了 - %@ - %@", object, keyPath, change, context);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.test.name = @"Lucky";
}


-(void)dealloc{
    [self.test removeObserver:self forKeyPath:@"name"];
    [self.test removeObserver:self forKeyPath:@"height"];
}
@end

