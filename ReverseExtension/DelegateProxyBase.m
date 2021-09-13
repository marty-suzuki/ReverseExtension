//
//  DelegateProxyBase.m
//  ReverseExtension
//
//  Created by marty-suzuki on 2017/03/01.
//
//

#import "DelegateProxyBase.h"

@interface DelegateProxyBase ()
@property (nonnull, nonatomic, strong) NSHashTable<NSObject *> *delegates;
@property (nonnull, nonatomic, strong) NSMapTable<NSString *, id> *denyDictionary;
@end

@implementation DelegateProxyBase

- (instancetype)initWithDelegates: (NSArray<id> *)delegates
                        denyList: (NSArray<DenyDelegateMethod *> *)denyList {
    self = [super init];
    if (self) {
        NSMapTable<NSString *, id> *denyDictionary = [NSMapTable strongToWeakObjectsMapTable];
        for (DenyDelegateMethod *denyDelegateMethod in denyList) {
            NSString *key = NSStringFromSelector(denyDelegateMethod.selector);
            [denyDictionary setObject:denyDelegateMethod.delegate forKey:key];
        }
        self.denyDictionary = denyDictionary;
        self.delegates = [NSHashTable weakObjectsHashTable];
        for (id delegate in delegates) {
            if (![delegate isKindOfClass:[NSObject class]]) { continue; }
            [self.delegates addObject: delegate];
        }
    }
    return self;
}

- (id)denyDelegateForSelector:(SEL)aSelector {
    return [self.denyDictionary objectForKey:NSStringFromSelector(aSelector)];
}

- (BOOL)isDenyDelegateForSelector:(SEL)aSelector delegate:(id)delegate {
    id denyDelegate = [self denyDelegateForSelector:aSelector];
    return denyDelegate != nil && [delegate isEqual: denyDelegate];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    for (NSObject *delegate in self.delegates) {
        if ([delegate isKindOfClass:[NSNull class]]) {
            continue;
        }

        if ([delegate respondsToSelector:aSelector]) {
            if ([self isDenyDelegateForSelector:aSelector delegate:delegate]) {
                continue;
            }
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
            if ([self isDenyDelegateForSelector:aSelector delegate:delegate]) {
                continue;
            }
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
            if ([self isDenyDelegateForSelector:anInvocation.selector delegate:delegate]) {
                continue;
            }
            [anInvocation invokeWithTarget:delegate];
        }
    }
}

@end
