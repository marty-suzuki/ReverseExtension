//
//  DenyDelegateMethod.h
//  ReverseExtension
//
//  Created by marty-suzuki on 2021/09/14.
//

#import <Foundation/Foundation.h>

@interface DenyDelegateMethod : NSObject

@property (readonly, nullable, nonatomic, weak) id delegate;
@property (readonly, nonnull, nonatomic, assign) SEL selector;

- (nonnull instancetype)initWithDelegate: (id __nonnull)delegate
                                selector: (SEL __nonnull)selector;
@end
