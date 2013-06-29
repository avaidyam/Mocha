#import <QuartzCore/QuartzCore.h>

// Extends CATransaction with useful block-based features.
@interface CATransaction (BINExtensions)

// Executes a block with actions disabled.
// This will have the effect of suppressing animation.
+ (void)performWithDisabledActions:(void(^)(void))block;

@end
