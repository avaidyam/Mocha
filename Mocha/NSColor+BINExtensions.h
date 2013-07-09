/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <AppKit/NSColor.h>
#import "NSObject+BINExtensions.h"

@interface NSColor (BINExtensions)

// Returns a CGColor with the receiving NSColor.
@property (nonatomic, readonly) CGColorRef CGColor;

// Returns an NSColor with the passed CGColor.
+ (NSColor *)colorWithCGColor:(CGColorRef)color;

// Backwards-compatible support for new NSColor convenience methods.
+ (NSColor *)colorWithWhite:(CGFloat)white alpha:(CGFloat)alpha;
+ (NSColor *)colorWithRed:(CGFloat)red green:(CGFloat)green
					 blue:(CGFloat)blue alpha:(CGFloat)alpha;
+ (NSColor *)colorWithHue:(CGFloat)hue saturation:(CGFloat)saturation
			   brightness:(CGFloat)brightness alpha:(CGFloat)alpha;

@end
