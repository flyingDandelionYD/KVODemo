//
//  ViewController.m
//  KVO
//


#import "ViewController.h"

@interface Person : NSObject{
    @public
    int _age;
}
@property (nonatomic,strong)NSString  *name;
@property (nonatomic,assign)CGFloat  height;
@end

@implementation Person
@end


@interface ViewController ()
@property (nonatomic,strong)Person  *person1;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.person1 = [[Person alloc]init];
    self.person1.name = @"Jack";
    self.person1.height  = 175;
    self.person1->_age = 18;
   
     //添加KVO监听
     NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
     [self.person1 addObserver:self forKeyPath:@"height" options:options context:@"height-contenxt"];
     [self.person1 addObserver:self forKeyPath:@"name" options:options context:@"name-contenxt"];
     [self.person1 addObserver:self forKeyPath:@"_age" options:options context:@"_age-contenxt"];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.person1.name = @"Jack2";
    self.person1.height = 180;
    self.person1->_age = 20;
}

// 当监听对象的属性值发生改变时，就会调用
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
     NSLog(@"监听到%@的%@属性值改变了 - %@ - %@", object, keyPath, change, context);
}

- (void)dealloc {
    [self.person1 removeObserver:self forKeyPath:@"height"];
    [self.person1 removeObserver:self forKeyPath:@"name"];
}
@end
