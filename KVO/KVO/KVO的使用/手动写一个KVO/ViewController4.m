//
//  ViewController4.m
//  KVO


#import "ViewController4.h"
#import "NSObject+KVO.h"
#import "myPerson.h"

@interface ViewController4 ()
@property (nonatomic,strong)myPerson  *p;
@end

@implementation ViewController4

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title  = @"手动写一个KVO";
    self.p = [myPerson new];
    self.p.name = @"jack";
    
    [self.p my_ddObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:@"123"];
}

- (void)dealloc {
    [self.p removeObserver:self forKeyPath:@"name"];
    NSLog(@"%s-%d",__FUNCTION__,__LINE__);
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"监听到%@的%@属性值改变了 - %@ - %@", object, keyPath, change, context);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.p.name =  @"lucy";
}
@end
