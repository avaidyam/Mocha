/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import "NSAffineTransform+BINExtensions.h"

@implementation NSAffineTransform (BINExtensions)

+ (NSAffineTransform *)transformWithCGAffineTransform:(CGAffineTransform)transform {
	NSAffineTransform *affineTransform = [NSAffineTransform transform];
	affineTransform.transformStruct = (NSAffineTransformStruct) {
		.m11 = transform.a,
		.m12 = transform.b,
		.m21 = transform.c,
		.m22 = transform.d,
		.tX = transform.tx,
		.tY = transform.ty
	};
	return affineTransform;
}

- (CGAffineTransform)CGAffineTransform {
	NSAffineTransformStruct transform = self.transformStruct;
	return (CGAffineTransform) {
		.a = transform.m11,
		.b = transform.m12,
		.c = transform.m21,
		.d = transform.m22,
		.tx = transform.tX,
		.ty = transform.tY
	};
}

@end


