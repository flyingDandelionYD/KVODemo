//
//  NSObject+myKVO2.m
//  KVO
//


#import "NSObject+myKVO2.h"
#import <objc/runtime.h>

@implementation NSObject (myKVO2)
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = [NSObject class];
        //交换系统的方法
        SEL originalSelector = @selector(removeObserver:forKeyPath:context:);
        SEL swizzledSelector = @selector(myRemoveObserver:forKeyPath:options:context:);
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
        
        
        //交换系统的方法
        SEL originalSelector2 = @selector(addObserver:forKeyPath:options:context:);
        SEL swizzledSelector2 = @selector(myAddObserver:forKeyPath:options:context:);
        Method originalMethod2 = class_getInstanceMethod(cls, originalSelector2);
        Method swizzledMethod2 = class_getInstanceMethod(cls, swizzledSelector2);
        BOOL didAddMethod2 = class_addMethod(cls,
                                            originalSelector,
                                            method_getImplementation(swizzledMethod2),
                                            method_getTypeEncoding(swizzledMethod2));
        if(didAddMethod2){
            class_replaceMethod(cls,
                                swizzledSelector2,
                                method_getImplementation(originalMethod2),
                                method_getTypeEncoding(originalMethod2));
        }
        else{
            method_exchangeImplementations(originalMethod2, swizzledMethod2);
        }
    });
}


- (void)myRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    if ([self hasContainedObserver:observer forKeyPath:keyPath context:context]) {
        [self myRemoveObserver:observer forKeyPath:keyPath options:options context:context];
    }
}

-(void)myAddObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    if (![self hasContainedObserver:observer forKeyPath:keyPath context:context]) {
        [self myAddObserver:observer forKeyPath:keyPath options:options context:context];
    }
}

-(BOOL)hasContainedObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context{
    id observationInfo = self.observationInfo;
    if (observationInfo) {
        NSArray *observances = [observationInfo valueForKey:@"_observances"];
        for (id observance in observances) {
            NSObject *_observer = [observance valueForKey:@"_observer"];
            NSString *_keyPath = [[observance valueForKeyPath:@"_property"] valueForKeyPath:@"_keyPath"];
            Ivar _contextIvar = class_getInstanceVariable([observance class], "_context");
            void *_context = (__bridge void *)(object_getIvar(observance, _contextIvar));
            if (_observer == observer && [_keyPath isEqualToString:keyPath] && _context == context) return YES;
        }
    }
    return NO;
}
@end
