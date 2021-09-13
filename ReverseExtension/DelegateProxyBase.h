//
//  DelegateProxyBase.h
//  ReverseExtension
//
//  Created by marty-suzuki on 2017/03/01.
//
//

#import <Foundation/Foundation.h>
#import "DenyDelegateMethod.h"

@interface DelegateProxyBase : NSObject
- (nonnull instancetype)initWithDelegates: (NSArray<id> * __nonnull)delegates
                                 denyList: (NSArray<DenyDelegateMethod *> * __nonnull)denyList NS_REFINED_FOR_SWIFT;
@end
