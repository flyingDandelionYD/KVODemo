//
//  School.h
//  KVO


#import <Foundation/Foundation.h>
#import "Person_.h"
#import "Student.h"
NS_ASSUME_NONNULL_BEGIN

@interface School : NSObject
@property (nonatomic,strong)  Person_ *leader;
@property (nonatomic,strong)NSMutableArray<Student*> *stuArr;
@property (nonatomic,assign)int  lastTime;
@end

NS_ASSUME_NONNULL_END
