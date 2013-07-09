/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import "NSShadow+BINExtensions.h"

@implementation NSShadow (BINExtensions)

+ (NSShadow *)shadowWithRadius:(CGFloat)radius offset:(CGSize)offset color:(NSColor *)color {
	NSShadow *shadow = [[self.class alloc] init];
	shadow.shadowBlurRadius = radius;
	shadow.shadowOffset = offset;
	shadow.shadowColor = color;
	return shadow;
}

@end
