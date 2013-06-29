#import <AppKit/AppKit.h>

@interface NSShadow (BINExtensions)

// Returns a shadow with the given shadow radius, offset, and color properties.
+ (NSShadow *)shadowWithRadius:(CGFloat)radius offset:(CGSize)offset color:(NSColor *)color;

@end
