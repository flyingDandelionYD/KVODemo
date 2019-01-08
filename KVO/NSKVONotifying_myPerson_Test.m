//
//  NSKVONotifying_myPerson_Test.m
//  KVO
//


#import "NSKVONotifying_myPerson_Test.h"

@implementation NSKVONotifying_myPerson_Test
-(void)setName:(NSString *)name{
    _NSSetObjectValueAndNotify();
}

void _NSSetObjectValueAndNotify(){
    /*
    [self willChangeValueForKey:@"name"];
    [super setAge:age];
    [self didChangeValueForKey:@"name"];
     */
}

/*
-(void)willChangeValueForKey:(NSString*)key{
    
}

- (void)didChangeValueForKey:(NSString *)key
{
     // 通知监听器，某某属性值发生了改变
     [oberser observeValueForKeyPath:key ofObject:self change:nil context:nil];
}
*/


//内部实现，隐藏了NSKVONotifying_myPerson类的存在
-(Class)class{
   return [myPerson class];
}

-(void)dealloc{
    
}

- (BOOL)_isKVOA
{
    return YES;
}
@end
