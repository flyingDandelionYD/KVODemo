//
//  KVOBaseUsesViewController_9.m
//  KVO
//


#import "KVOBaseUsesViewController_9.h"
#import "Person_.h"

@interface KVOBaseUsesViewController_9 ()
@property (nonatomic,strong)Person_*p;
@end

@implementation KVOBaseUsesViewController_9

- (void)viewDidLoad {
    [super viewDidLoad];
    self.p = [Person_ new];
    [self.p addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew context:nil];
    id info = self.p.observationInfo;
    NSLog(@"%@", [info description]);
}

-(void)dealloc{
    [self.p removeObserver:self forKeyPath:@"age"];
}
@end
