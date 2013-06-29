#import "CATransaction+BINExtensions.h"

@implementation CATransaction (BINExtensions)
+ (void)performWithDisabledActions:(void(^)(void))block {
	if ([self disableActions]) {
		block();
	} else {
		[self setDisableActions:YES];
		block();
		[self setDisableActions:NO];
	}
}

@end
