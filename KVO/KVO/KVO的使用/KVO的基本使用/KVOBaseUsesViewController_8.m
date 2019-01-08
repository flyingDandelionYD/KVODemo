//
//  KVOBaseUsesViewController_8.m
//  KVO
//


#import "KVOBaseUsesViewController_8.h"

@interface Calculator : NSObject
@property (nonatomic, assign) double x;
@property (nonatomic, assign) double y;
@property (nonatomic, readonly,assign) double result;
@end

@implementation Calculator
-(double)result{
    return self.x + self.y;
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"result"]) {
        return [NSSet setWithObjects:@"x", @"y", nil];
    }else {
        return [super keyPathsForValuesAffectingValueForKey:key];
    }
}
@end

@interface KVOBaseUsesViewController_8 ()
@property (nonatomic,strong)Calculator  *calculator;
@end

@implementation KVOBaseUsesViewController_8

- (void)viewDidLoad {
    [super viewDidLoad];
    self.calculator = [Calculator new];
    
    [self.calculator addObserver:self forKeyPath:@"result" options:(NSKeyValueObservingOptionNew) context:nil];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.calculator.x = 10;
    NSLog(@"改变了x，结果%f",self.calculator.result);
    
    [NSThread sleepForTimeInterval:5];
    self.calculator.y = 20;
    NSLog(@"改变了y，结果%f",self.calculator.result);
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"监听到%@的%@属性值改变了 - %@ - %@", object, keyPath, change, context);
    
}

-(void)dealloc{
    [self.calculator removeObserver:self forKeyPath:@"result"];
}
@end
