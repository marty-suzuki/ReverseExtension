//
//  ExceptionHandler.h
//  Pods
//
//  Created by marty-suzuki on 2017/03/02.
//
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *_Nonnull const NSExceptionReasonKey;
FOUNDATION_EXPORT NSString *_Nonnull const NSExceptionNameKey;
FOUNDATION_EXPORT NSInteger const NSExceptionCode;

@interface ExceptionHandler : NSObject
+ (BOOL)catchExceptionWithTryBlock:(__attribute__((noescape)) void(^ _Nonnull)())tryBlock error:(NSError * _Nullable __autoreleasing * _Nullable)error;
@end
