#import "CAAnimation+BINExtensions.h"

@interface CAAnimationDelegate : NSObject

@property (nonatomic, weak) id delegate;
@property (nonatomic, copy) CAAnimationStartHandler startHandler;
@property (nonatomic, copy) CAAnimationCompletionHandler completionHandler;

@end

@implementation CAAnimation (BINExtensions)

- (CAAnimationStartHandler)startHandler {
    return [self.delegate isKindOfClass:CAAnimationDelegate.class] ? [self.delegate startHandler] : nil;
}

- (void)setStartHandler:(CAAnimationStartHandler)start {
    if ([self.delegate isKindOfClass:CAAnimationDelegate.class]) {
		[self.delegate setStartHandler:start];
    } else {
        CAAnimationDelegate *delegate = [CAAnimationDelegate new];
        delegate.startHandler = start;
		
		delegate.delegate = self.delegate;
        self.delegate = delegate;
    }
}

- (CAAnimationCompletionHandler)completionHandler {
    return [self.delegate isKindOfClass:CAAnimationDelegate.class] ? [(CAAnimationDelegate *)self.delegate completionHandler] : nil;
}

- (void)setCompletionHandler:(CAAnimationCompletionHandler)completion {
    if ([self.delegate isKindOfClass:CAAnimationDelegate.class]) {
		[(CAAnimationDelegate *)self.delegate setCompletionHandler:completion];
    } else {
        CAAnimationDelegate *delegate = [CAAnimationDelegate new];
        delegate.completionHandler = completion;
		
		delegate.delegate = self.delegate;
        self.delegate = delegate;
    }
}

@end

@implementation CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim {
	if(self.delegate != nil && [self.delegate respondsToSelector:_cmd])
		[self.delegate animationDidStart:anim];
    if(self.startHandler != nil)
        self.startHandler();
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	if(self.delegate != nil && [self.delegate respondsToSelector:_cmd])
		[self.delegate animationDidStop:anim finished:flag];
    if(self.completionHandler != nil)
        self.completionHandler(flag);
}

@end
