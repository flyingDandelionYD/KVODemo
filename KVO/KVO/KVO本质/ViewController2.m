//
//  ViewController2.m
//  KVO
//


#import "ViewController2.h"
#import "myPerson.h"
#import <objc/runtime.h>
#import "NSKVONotifying_myPerson_Test.h"

@interface ViewController2 ()
@property (nonatomic,strong)myPerson  *p;
@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"KVO本质";
    
    self.p  = [[myPerson alloc]init];
    self.p.name = @"jack";
    
    NSLog(@"添加之前“类（isa)“\n%p",object_getClass(self.p)); //self.p->isa
    NSLog(@"添加之前的name的set方法\n%p",[self.p methodForSelector:@selector(setName:)]);
    NSLog(@"添加之前属性和属性值:%@",[self getAllPropertiesAndVaules:self.p]);
    [self printMethodNamesOfClass:object_getClass(self.p)];
    NSLog(@"添加之前成员变量：%@",[self getIvarlists:object_getClass(self.p)]);
    

    
    //添加KVO监听
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.p addObserver:self forKeyPath:@"name" options:options context:@"name-context"];

    NSLog(@"添加之后“类（isa)“\n%p",object_getClass(self.p)); //self.p->isa
    NSLog(@"添加之后的name的set方法\n%p",[self.p methodForSelector:@selector(setName:)]);
    NSLog(@"添加之后属性和属性值:%@",[self getAllPropertiesAndVaules:self.p]);
    [self printMethodNamesOfClass:object_getClass(self.p)];
    NSLog(@"添加之后成员变量：%@",[self getIvarlists:object_getClass(self.p)]);
    
    [self printMethodNamesOfClass:[NSKVONotifying_myPerson_Test class]];
    
    NSLog(@"End");
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.p.name = @"Jack2";
    
}

// 当监听对象的属性值发生改变时，就会调用
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"监听到%@的%@属性值改变了 - %@ - %@", object, keyPath, change, context);
}

- (void)dealloc {
    [self.p removeObserver:self forKeyPath:@"name"];
    NSLog(@"%s-%d",__FUNCTION__,__LINE__);
}

- (void)printMethodNamesOfClass:(Class)cls
{
    unsigned int count;
    // 获得方法数组
    Method *methodList = class_copyMethodList(cls, &count);
    // 存储方法名
    NSMutableString *methodNames = [NSMutableString string];
    
    // 遍历所有的方法
    for (int i = 0; i < count; i++) {
        // 获得方法
        Method method = methodList[i];
        // 获得方法名
        NSString *methodName = NSStringFromSelector(method_getName(method));
        // 拼接方法名
        [methodNames appendString:methodName];
        [methodNames appendString:@", "];
    }
    
    // 释放
    free(methodList);
    
    // 打印方法名
    NSLog(@"%@ %@", cls, methodNames);
}


/* 获取对象的所有属性和属性内容 */
-(NSDictionary *)getAllPropertiesAndVaules:(id)instance
{
    NSMutableDictionary *propsDic = [NSMutableDictionary dictionary];
    unsigned int outCount;
    objc_property_t *properties =class_copyPropertyList([instance class], &outCount);
    for ( int i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [instance valueForKey:(NSString *)propertyName];
        if (propertyValue) {
            [propsDic setObject:propertyValue forKey:propertyName];
        }
    }
    free(properties);
    return propsDic;
}

-(NSArray*)getIvarlists:(Class)cls{
    NSMutableArray  *tempArr = [NSMutableArray array];
    // 成员变量的数量
    unsigned int outCount = 0;
    
    // 获得所有的成员变量
    // ivars是一个指向成员变量的指针
    // ivars默认指向第0个成员变量（最前面）
    Ivar *ivars = class_copyIvarList(cls, &outCount);
    
    // 遍历所有的成员变量
    for (int i = 0; i<outCount; i++) {
        // 取出i位置对应的成员变量
        //            Ivar ivar = *(ivars + i);
        Ivar ivar = ivars[i];
        // 获得成员变量的名字
        [tempArr addObject:[NSString stringWithFormat:@"%s",ivar_getName(ivar)]];
    }
    
    // 如果函数名中包含了copy\new\retain\create等字眼，那么这个函数返回的数据就需要手动释放
    free(ivars);
    return  tempArr.copy;
}
@end
