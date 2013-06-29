#import <AppKit/AppKit.h>
#import "NSObject+BINExtensions.h"

/*
 * Extensions to NSColor that add interoperability with CGColor for 10.7-
 */
@interface NSColor (BINExtensions)

// The CGColor corresponding to the receiver.
@property (nonatomic, readonly) CGColorRef CGColor;

// Returns an NSColor corresponding to the given CGColor.
+ (NSColor *)colorWithCGColor:(CGColorRef)color;

// Convenience methods.
+ (NSColor *)colorWithWhite:(CGFloat)w alpha:(CGFloat)a;
+ (NSColor *)colorWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)a;
+ (NSColor *)colorWithHue:(CGFloat)h saturation:(CGFloat)s brightness:(CGFloat)b alpha:(CGFloat)a;

@end
