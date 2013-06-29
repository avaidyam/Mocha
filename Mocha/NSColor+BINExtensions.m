#import "NSColor+BINExtensions.h"
#import "NSImage+BINExtensions.h"
#import <objc/runtime.h>

// CGPatterns involve some complex memory management which doesn't mesh well with ARC.
#if __has_feature(objc_arc)
#error "This file cannot be compiled with ARC."
#endif

static void drawCGImagePattern (void *info, CGContextRef context) {
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
	if(!class_getInstanceMethod(NSColor.class, @selector(CGColor))) {
		Method m = class_getInstanceMethod(NSColor.class, @selector(BIN_CGColor));
		class_addMethod(NSColor.class, @selector(CGColor),
						class_getMethodImplementation(NSColor.class, @selector(BIN_CGColor)),
						method_getTypeEncoding(m));
	}
	
	if(!class_getInstanceMethod(NSColor.class, @selector(colorWithCGColor:))) {
		Method m = class_getInstanceMethod(NSColor.class, @selector(BIN_colorWithCGColor:));
		class_addMethod(NSColor.class, @selector(colorWithCGColor:),
						class_getMethodImplementation(NSColor.class, @selector(BIN_colorWithCGColor:)),
						method_getTypeEncoding(m));
	}
	
	if(!class_getInstanceMethod(NSColor.class, @selector(colorWithWhite:alpha:))) {
		Method m = class_getInstanceMethod(NSColor.class, @selector(BIN_colorWithWhite:alpha:));
		class_addMethod(NSColor.class, @selector(colorWithWhite:alpha:),
						class_getMethodImplementation(NSColor.class, @selector(BIN_colorWithWhite:alpha:)),
						method_getTypeEncoding(m));
	}
	
	if(!class_getInstanceMethod(NSColor.class, @selector(colorWithRed:green:blue:alpha:))) {
		Method m = class_getInstanceMethod(NSColor.class, @selector(BIN_colorWithRed:green:blue:alpha:));
		class_addMethod(NSColor.class, @selector(colorWithRed:green:blue:alpha:),
						class_getMethodImplementation(NSColor.class, @selector(BIN_colorWithRed:green:blue:alpha:)),
						method_getTypeEncoding(m));
	}
	
	if(!class_getInstanceMethod(NSColor.class, @selector(colorWithHue:saturation:brightness:alpha:))) {
		Method m = class_getInstanceMethod(NSColor.class, @selector(BIN_colorWithHue:saturation:brightness:alpha:));
		class_addMethod(NSColor.class, @selector(colorWithHue:saturation:brightness:alpha:),
						class_getMethodImplementation(NSColor.class, @selector(BIN_colorWithHue:saturation:brightness:alpha:)),
						method_getTypeEncoding(m));
	}
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
