//
//  KVOBaseUsesViewController_7.m
//  KVO
//


#import "KVOBaseUsesViewController_7.h"

@interface Girl_7 : NSObject
@property (nonatomic,strong)NSMutableArray  *clothes;
@end

@implementation Girl_7
//关闭自动通知
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    return ![key isEqualToString:@"clothes"];
}

-(void)removeClothesAtIndexes:(NSIndexSet *)indexes{
    NSLog(@"准备发送通知");
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"clothes"];
    [_clothes  removeObjectsAtIndexes:indexes];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"clothes"];
    NSLog(@"已经发送通知");
}
@end


@interface KVOBaseUsesViewController_7 ()
@property (nonatomic,strong)Girl_7  *girl;
@end

@implementation KVOBaseUsesViewController_7

- (void)viewDidLoad {
    [super viewDidLoad];
    self.girl = [[Girl_7 alloc]init];
    self.girl.clothes  = @[@"010101",@"000",@"111"].mutableCopy;
    [self.girl addObserver:self forKeyPath:@"clothes" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld  context:nil];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self makeChange_1];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"监听到%@的%@属性值改变了 - %@ - %@", object, keyPath, change, context);
    NSArray *newArray = change[NSKeyValueChangeNewKey];
    NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];
    __block NSInteger i = 0;
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"下标 : %ld, 新值 : %@", idx, newArray[i]);
        i++;
    }];
}

-(void)makeChange_1{
    [self.girl removeClothesAtIndexes:[NSIndexSet indexSetWithIndex:0]];
    NSLog(@"结果：%@",self.girl.clothes);
}

-(void)dealloc{
    [self.girl removeObserver:self forKeyPath:@"clothes"];
}
@end
