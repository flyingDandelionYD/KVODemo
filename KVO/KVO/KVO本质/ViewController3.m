//
//  ViewController3.m
//  KVO


#import "ViewController3.h"
#import "myPerson.h"
#import <objc/runtime.h>
#import "NSKVONotifying_myPerson_Test.h"


struct my_class{
    Class isa;
};

@interface ViewController3 ()
@property (nonatomic,strong)myPerson  *p;
@end

@implementation ViewController3

- (void)viewDidLoad {
    [super viewDidLoad];
   
    //0x0000000ffffffff8ULL  0x00007ffffffffff8ULL
    
    self.p  = [[myPerson alloc]init];
    self.p.name = @"jack";
    
    NSLog(@"添加之前“类（isa)“\n%p",object_getClass(self.p)); //self.p->isa
    NSLog(@"添加之前“元类”\n%p",object_getClass(object_getClass(self.p)));
    Class class = object_getClass(self.p);
    Class mclass = object_getClass(object_getClass(self.p));
    struct my_class  *myC = (__bridge struct my_class *)class;
    struct my_class *mMetaC = (__bridge struct my_class *)mclass;
    
   
    //添加KVO监听
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.p addObserver:self forKeyPath:@"name" options:options context:@"name-context"];
    
    NSLog(@"添加之后“类（isa)“\n%p",object_getClass(self.p)); //self.p->isa
    NSLog(@"添加之后“元类”\n%p",object_getClass(object_getClass(self.p)));
    
    Class class2 = object_getClass(self.p);
    Class mclass2 = object_getClass(object_getClass(self.p));
    struct my_class  *myC2 = (__bridge struct my_class *)class2;
    struct my_class *mMetaC2 = (__bridge struct my_class *)mclass2;
  
    NSLog(@"End");
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.p.name = @"Jack2";
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"监听到%@的%@属性值改变了 - %@ - %@", object, keyPath, change, context);
}

- (void)dealloc {
    [self.p removeObserver:self forKeyPath:@"name"];
    NSLog(@"%s-%d",__FUNCTION__,__LINE__);
}

@end

