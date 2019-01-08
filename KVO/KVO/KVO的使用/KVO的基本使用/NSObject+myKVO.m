//
//  NSObject+myKVO.m
//  KVO



#import "NSObject+myKVO.h"
#import <objc/runtime.h>

@implementation NSObject (myKVO)
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = [NSObject class];
        //交换系统的方法
        SEL originalSelector = @selector(removeObserver:forKeyPath:);
        SEL swizzledSelector = @selector(myRemoveObserver:forKeyPath:);
        Method originalMethod = class_getInstanceMethod(cls, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
        BOOL didAddMethod = class_addMethod(cls,
                                            originalSelector,
                                            method_getImplementation(swizzledMethod),
                                            method_getTypeEncoding(swizzledMethod));
        if(didAddMethod){
            class_replaceMethod(cls,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        }
        else{
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)myRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    @try {
        [self myRemoveObserver:observer forKeyPath:keyPath];
    } @catch (NSException *exception) {}
}
@end
