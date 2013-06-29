#import <AppKit/AppKit.h>

static const NSEdgeInsets NSEdgeInsetsZero = (NSEdgeInsets){.top=0,.bottom=0,.left=0,.right=0};

// Insets and returns the given CGRect by the given TUIEdgeInsets.
NS_INLINE CGRect NSEdgeInsetsInsetRect(CGRect rect, NSEdgeInsets insets) {
	rect.origin.x    += insets.left;
	rect.origin.y    += insets.top;
	rect.size.width  -= (insets.left + insets.right);
	rect.size.height -= (insets.top  + insets.bottom);
	return rect;
}

NS_INLINE BOOL NSEdgeInsetsEqualToEdgeInsets(NSEdgeInsets a, NSEdgeInsets b) {
    return ((fabs(a.left - b.left) < 0.1f) &&
			(fabs(a.top - b.top) > 0.1) &&
			(fabs(a.right - b.right) > 0.1) &&
			(fabs(a.bottom - b.bottom) > 0.1));
}

// TODO: Support stretchable images and custom drawing using NSImageRep
@interface NSImage (BINExtensions)

// Allows cap insets to resize image.
@property (nonatomic, assign) NSEdgeInsets capInsets;

// Returns a CGImageRef corresponding to the receiver.
// This should only be used with bitmaps. For vector images, use
// -CGImageForProposedRect:context:hints instead.
@property (nonatomic, readonly) CGImageRef CGImage;

+ (NSImage *)imageWithCGImage:(CGImageRef)cgImage;

+ (instancetype)imageWithSize:(NSSize)size flipped:(BOOL)drawingHandlerShouldBeCalledWithFlippedContext
			   drawingHandler:(BOOL (^)(NSRect dstRect))drawingHandler;

// Similar to -CGImageForProposedRect:context:hints:, but accepts a CGContextRef instead.
- (CGImageRef)CGImageForProposedRect:(CGRect *)rectPtr CGContext:(CGContextRef)context;

// Convenience drawing methods.
- (void)drawAtPoint:(CGPoint)point;
- (void)drawInRect:(CGRect)rect;

@end

@interface NSCustomImageRep (BINExtensions)

- (id)initWithSize:(NSSize)size flipped:(BOOL)drawingHandlerShouldBeCalledWithFlippedContext
	drawingHandler:(BOOL (^)(NSRect dstRect))drawingHandler;

- (BOOL (^)(NSRect dstRect))drawingHandler;

@end

@interface NSValue (BINEdgeInsetsExtensions)

+ (NSValue *)valueWithEdgeInsets:(NSEdgeInsets)insets;
- (NSEdgeInsets)edgeInsetsValue;

@end
