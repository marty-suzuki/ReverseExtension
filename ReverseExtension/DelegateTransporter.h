//
//  DelegateTransporter.h
//  ReverseExtension
//
//  Created by marty-suzuki on 2017/03/01.
//
//

#import <Foundation/Foundation.h>

@interface DelegateTransporter : NSObject
- (nonnull instancetype)initWithDelegates:(NSArray<id> * __nonnull)delegates NS_REFINED_FOR_SWIFT;
@end
