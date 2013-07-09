/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import "NSColor+BINExtensions.h"
#import "NSImage+BINExtensions.h"
#import <AppKit/NSColorSpace.h>
#import <objc/runtime.h>

#if __has_feature(objc_arc)
#error "This file cannot be compiled with ARC."
#endif

static void drawCGImagePattern(void *info, CGContextRef context) {
	CGImageRef image = info;

	size_t width = CGImageGetWidth(image);
	size_t height = CGImageGetHeight(image);

	CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
}

static void releasePatternInfo (void *info) {
	CFRelease(info);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma clang diagnostic ignored "-Wobjc-property-implementation"
@implementation NSColor (BINExtensions)

+ (void)load {
	[NSColor attemptToAddInstanceMethod:@selector(CGColor) withPrefix:MochaPrefix];
	[NSColor attemptToAddClassMethod:@selector(colorWithCGColor:) withPrefix:MochaPrefix];
	
	[NSColor attemptToAddClassMethod:@selector(colorWithWhite:alpha:) withPrefix:MochaPrefix];
	[NSColor attemptToAddClassMethod:@selector(colorWithRed:green:blue:alpha:) withPrefix:MochaPrefix];
	[NSColor attemptToAddClassMethod:@selector(colorWithHue:saturation:brightness:alpha:) withPrefix:MochaPrefix];
}

+ (NSColor *)BIN_colorWithCGColor:(CGColorRef)color {
	if (!color)
		return nil;

	CGColorSpaceRef colorSpaceRef = CGColorGetColorSpace(color);

	NSColorSpace *colorSpace = [[NSColorSpace alloc] initWithCGColorSpace:colorSpaceRef];
	NSColor *result = [self colorWithColorSpace:colorSpace components:CGColorGetComponents(color) count:(size_t)CGColorGetNumberOfComponents(color)];
	[colorSpace release];

	return result;
}

- (CGColorRef)BIN_CGColor {
	if ([self.colorSpaceName isEqualToString:NSPatternColorSpace]) {
		CGImageRef patternImage = self.patternImage.CGImage;
		if (!patternImage)
			return NULL;

		size_t width = CGImageGetWidth(patternImage);
		size_t height = CGImageGetHeight(patternImage);

		CGRect patternBounds = CGRectMake(0, 0, width, height);
		CGPatternRef pattern = CGPatternCreate(
			(void *)CFRetain(patternImage),
			patternBounds,
			CGAffineTransformIdentity,
			width,
			height,
			kCGPatternTilingConstantSpacingMinimalDistortion,
			YES,
			&(CGPatternCallbacks){
				.version = 0,
				.drawPattern = &drawCGImagePattern,
				.releaseInfo = &releasePatternInfo
			}
		);

		CGColorSpaceRef colorSpaceRef = CGColorSpaceCreatePattern(NULL);

		CGColorRef result = CGColorCreateWithPattern(colorSpaceRef, pattern, (CGFloat[]){ 1.0 });

		CGColorSpaceRelease(colorSpaceRef);
		CGPatternRelease(pattern);

		return (CGColorRef)[(id)result autorelease];
	}

	NSColorSpace *colorSpace = [NSColorSpace genericRGBColorSpace];
	NSColor *color = [self colorUsingColorSpace:colorSpace];

	NSInteger count = [color numberOfComponents];
	CGFloat components[count];
	[color getComponents:components];

	CGColorSpaceRef colorSpaceRef = colorSpace.CGColorSpace;
	CGColorRef result = CGColorCreate(colorSpaceRef, components);

	return (CGColorRef)[(id)result autorelease];
}

+ (NSColor *)BIN_colorWithWhite:(CGFloat)w alpha:(CGFloat)a {
	return [self colorWithCalibratedWhite:w alpha:a];
}

+ (NSColor *)BIN_colorWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)a {
	return [self colorWithCalibratedRed:r green:g blue:b alpha:a];
}

+ (NSColor *)BIN_colorWithHue:(CGFloat)h saturation:(CGFloat)s brightness:(CGFloat)b alpha:(CGFloat)a {
	return [self colorWithCalibratedHue:h saturation:s brightness:b alpha:a];
}

@end
#pragma clang diagnostic pop
