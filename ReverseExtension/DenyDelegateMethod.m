//
//  DenyDelegateMethod.m
//  ReverseExtension
//
//  Created by marty-suzuki on 2021/09/14.
//

#import "DenyDelegateMethod.h"

@interface DenyDelegateMethod ()
@property (readwrite, nullable, nonatomic, weak) id delegate;
@property (readwrite, nonnull, nonatomic, assign) SEL selector;
@end

@implementation DenyDelegateMethod

- (instancetype)initWithDelegate: (id)delegate
                        selector: (SEL)selector {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.selector = selector;
    }
    return self;
}

@end
