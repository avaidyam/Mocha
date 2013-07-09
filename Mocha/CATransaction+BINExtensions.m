/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

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
