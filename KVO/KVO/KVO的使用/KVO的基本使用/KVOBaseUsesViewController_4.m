//
//  KVOBaseUsesViewController4.m
//  KVO
//


//https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueObserving/Articles/KVOCompliance.html#//apple_ref/doc/uid/20002178-BAJEAIEE

#import "KVOBaseUsesViewController_4.h"


@interface Girl : NSObject
@property (nonatomic,strong)NSMutableArray  *clothes;
@end

@implementation Girl
@end


@interface KVOBaseUsesViewController_4 ()
@property (nonatomic,strong)Girl  *girl;
@end

@implementation KVOBaseUsesViewController_4

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //集合：NSMutableArray、NSMutableSet和NSMutableOrderedSet
    self.girl = [[Girl alloc]init];
     self.girl.clothes  = @[@"010101",@"000",@"111"].mutableCopy;
    [self.girl addObserver:self forKeyPath:@"clothes" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld  context:nil];
    
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self makeChange_1];
    
    [self makeChange_2];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
     NSLog(@"监听到%@的%@属性值改变了 - %@ - %@", object, keyPath, change, context);
    
     if([keyPath isEqualToString:@"clothes"]) {
         
         /*NSKeyValueChangeKindKey:
          *NSKeyValueChange枚举相关的值:如下
          
          enum {
          NSKeyValueChangeSetting = 1, //设置一个新值。被监听的属性可以是一个对象，也可以是一对一关系的属性或一对多关系的属性。
          NSKeyValueChangeInsertion = 2,// 表示一个对象被插入到一对多关系的属性。
          NSKeyValueChangeRemoval = 3,// 表示一个对象被从一对多关系的属性中移除。
          NSKeyValueChangeReplacement = 4 // 表示一个对象在一对多的关系的属性中被替换
          };typedef NSUInteger NSKeyValueChange;
          
          */
         NSNumber *kindStr =  change[NSKeyValueChangeKindKey];
         NSLog(@"属性变化的类型:%@",kindStr);
         
         
         
         /*NSKeyValueChangeOldKey:
          *属性的旧值。当NSKeyValueChangeKindKey是 NSKeyValueChangeSetting，
          *且添加观察的方法设置了NSKeyValueObservingOptionOld时，我们能获取到属性的旧值。
          *如果NSKeyValueChangeKindKey是NSKeyValueChangeRemoval或者NSKeyValueChangeReplacement，
          *且指定了NSKeyValueObservingOptionOld时，则我们能获取到一个NSArray对象，包含被移除的对象或
          *被替换的对象
          */
         NSArray *oldArray = change[NSKeyValueChangeOldKey];
         NSLog(@"旧值：%@",oldArray);
         
         /*NSKeyValueChangeNewKey:
          *属性的新值。当NSKeyValueChangeKindKey是 NSKeyValueChangeSetting，
          *且添加观察的方法设置了NSKeyValueObservingOptionNew时，我们能获取到属性的新值。
          *如果NSKeyValueChangeKindKey是NSKeyValueChangeInsertion或者NSKeyValueChangeReplacement，
          *且指定了NSKeyValueObservingOptionNew时，则我们能获取到一个NSArray对象，包含被插入的对象或
          *用于替换其它对象的对象。
          */
        NSArray *newArray = change[NSKeyValueChangeNewKey];
         
         /*NSKeyValueChangeIndexesKey:
          *如果NSKeyValueChangeKindKey的值是NSKeyValueChangeInsertion、NSKeyValueChangeRemoval
          *或者NSKeyValueChangeReplacement，则这个key对应的值是一个NSIndexSet对象，
          *包含了被插入、移除或替换的对象的索引
          */
        NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];
        __block NSInteger i = 0;
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"下标 : %ld, 新值 : %@", idx, newArray[i]);
            i++;
        }];
    }
    
}


-(void)makeChange_1{
    [self.girl.clothes addObject:@"222"];//根本不会触发监听（属性内部的集合里面的值不会监听到）
}

-(void)makeChange_2{
    NSMutableArray *arrM = [self.girl mutableArrayValueForKey:@"clothes"];
    NSLog(@"原始arrM = %@",arrM);
    [arrM addObject:@"222"];
    NSLog(@"添加之后arrM = %@",arrM);
    [arrM insertObject:@"333" atIndex:0];
    NSLog(@"插入之后arrM = %@",arrM);
    [arrM removeObject:@"111"];
    NSLog(@"移除之后arrM = %@",arrM);
    [arrM replaceObjectAtIndex:0 withObject:@"444"];
    NSLog(@"替换之后arrM = %@",arrM);
    //数组的其他方法...
}

-(void)dealloc{
    [self.girl removeObserver:self forKeyPath:@"clothes"];
}
@end
