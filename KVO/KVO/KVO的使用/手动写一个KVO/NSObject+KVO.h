//
//  NSObject+KVO.h
//  KVO


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KVO)
//给NSObject类添加一个监听的方法 
-(void)my_ddObserver:(NSObject*)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;
@end

NS_ASSUME_NONNULL_END
