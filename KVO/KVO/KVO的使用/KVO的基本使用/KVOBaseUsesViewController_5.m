//
//  KVOBaseUsesViewController_5.m
//  KVO
//


#import "KVOBaseUsesViewController_5.h"

@interface Test : NSObject
@property (nonatomic,strong)NSString  *name;
@end

@implementation Test

/*关闭自动通知 */
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    return ![key isEqualToString:@"name"];
}

/* 过滤 */
- (void)setName:(NSString *)name{
    if (![name isEqualToString:_name]){ //相同的话就不发送
        [self willChangeValueForKey:@"name"];
        _name = name;
        [self didChangeValueForKey:@"name"];
    }
}

@end

@interface KVOBaseUsesViewController_5 ()
@property (nonatomic,strong)Test  *test;
@end

@implementation KVOBaseUsesViewController_5

- (void)viewDidLoad {
    [super viewDidLoad];
    self.test = [[Test alloc]init];
    
    [self.test addObserver:self forKeyPath:@"name" options:(NSKeyValueObservingOptionNew) context:nil];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"监听到%@的%@属性值改变了 - %@ - %@", object, keyPath, change, context);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.test.name = @"Lucky";
}


-(void)dealloc{
    [self.test removeObserver:self forKeyPath:@"name"];
}
@end
