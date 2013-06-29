#import "NSShadow+BINExtensions.h"

@interface NSBezierPath (BINExtensions)

@property (nonatomic, readonly) CGPathRef CGPath CF_RETURNS_RETAINED;

// Converts a CGPathRef into an NSBezierPath object and back.
+ (NSBezierPath *)bezierPathWithCGPath:(CGPathRef)pathRef;

// Fills the given shadow inside the bezier path.
- (void)fillWithInnerShadow:(NSShadow *)shadow;

// Draws a blurred "shadow" inside the bezier path with a color and radius.
- (void)drawBlurWithColor:(NSColor *)color radius:(CGFloat)radius;

// Strokes the bezier path on the inside or inside a clipped
// rectangle within the path, instead of the standard outside stroke.
- (void)strokeInside;
- (void)strokeInsideWithinRect:(NSRect)clipRect;

@end