/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <AppKit/NSGradient.h>
#import <CoreGraphics/CGContext.h>

// NSGradient extensions to allow the drawing of conical gradients.
// Not to be confused with radial gradients, a conical gradient
// is a centrally-"spun" fan of shaded colors.
@interface NSGradient (BINExtensions)

- (void)drawConicalInRect:(NSRect)rect;
- (void)drawConicalInBezierPath:(NSBezierPath *)path;

@end

// Applies light linear noise in a rectangle at a certain
// opacity. For a light noise, 0.1 - 0.2 is a good value.
extern void CGContextApplyNoise(CGContextRef context, CGRect rect, CGFloat opacity);

// Draws a conical gradient, a feature that Quartz does not
// natively support, in a given rectangle, defined by an
// array of NSColors, and an array of NSNumber locations for
// the gradient stops. The array counts must match up.
extern void CGContextDrawConicalGradient(CGContextRef context, CGRect rect, NSArray *colors, NSArray *locations);
