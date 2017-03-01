//
//  DelegateTransporter.m
//  ReverseExtension
//
//  Created by marty-suzuki on 2017/03/01.
//
//

#import "DelegateTransporter.h"

@interface DelegateTransporter ()
@property (nonnull, nonatomic, strong) NSHashTable<NSObject *> *delegates;
@end

@implementation DelegateTransporter

- (instancetype)initWithDelegates:(NSArray<id> *)delegates {
    self = [super init];
    if (self) {
        self.delegates = [NSHashTable weakObjectsHashTable];
        for (id delegate in delegates) {
            if (![delegate isKindOfClass:[NSObject class]]) { continue; }
            [self.delegates addObject: delegate];
        }
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    for (NSObject *delegate in self.delegates) {
        if ([delegate isKindOfClass:[NSNull class]]) {
            continue;
        }
        if ([delegate respondsToSelector:aSelector]) {
            return YES;
        }
    }
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    for (NSObject *delegate in self.delegates) {
        if ([delegate isKindOfClass:[NSNull class]]) {
            continue;
        }
        if ([delegate respondsToSelector:aSelector]) {
            return [delegate methodSignatureForSelector:aSelector];
        }
    }
    return nil;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    for (NSObject *delegate in self.delegates) {
        if ([delegate isKindOfClass:[NSNull class]]) {
            continue;
        }
        if ([delegate respondsToSelector:anInvocation.selector]) {
            [anInvocation invokeWithTarget:delegate];
        }
    }
}

@end
