//
//  ExceptionHandler.m
//  Pods
//
//  Created by marty-suzuki on 2017/03/02.
//
//

#import "ExceptionHandler.h"

NSString *const NSExceptionReasonKey = @"NSExceptionReasonKey";
NSString *const NSExceptionNameKey = @"NSExceptionNameKey";
NSInteger const NSExceptionCode = -9999;

@implementation ExceptionHandler

static NSString *const kNSExceptionDomainError = @"NSExceptionDomainError";

+ (BOOL)catchExceptionWithTryBlock:(__attribute__((noescape)) void(^ _Nonnull)())tryBlock error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    @try {
        tryBlock();
        return YES;
    } @catch (NSException *exception) {
        NSMutableDictionary *dict = nil;
        if (exception.userInfo != nil) {
            dict = [[NSMutableDictionary alloc] initWithDictionary:exception.userInfo];
        } else {
            dict = [NSMutableDictionary dictionary];
        }
        if (exception.reason != nil) {
            dict[NSExceptionReasonKey] = exception.reason;
        }
        if (exception.name != nil) {
            dict[NSExceptionNameKey] = exception.name;
        }
        *error = [NSError errorWithDomain:kNSExceptionDomainError code:NSExceptionCode userInfo:dict];
        return NO;
    }
}

@end
