#import <AppKit/AppKit.h>

/* DRAWING CONICAL GRADIENTS */
@interface NSGradient (BINExtensions)

- (void)drawConicalInRect:(NSRect)rect;
- (void)drawConicalInBezierPath:(NSBezierPath *)path;

@end

// Applies light linear noise in a rectangle at a certain
// opacity. For a light noise, 0.1 - 0.2 is a good value.
extern void CGContextApplyNoise(CGContextRef context, CGRect rect, CGFloat opacity);

// Draws a conical gradient, a feature that Quartz does not
// natively support, in a given rectangle, defined by an
// array of UIColors, and an array of NSNumber locations for
// the gradient stops. The array counts must match up.
extern void CGContextDrawConicalGradient(CGContextRef context, CGRect rect, NSArray *colors, NSArray *locations);
