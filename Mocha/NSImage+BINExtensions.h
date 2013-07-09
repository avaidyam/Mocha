/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <AppKit/NSImage.h>
#import <AppKit/NSCustomImageRep.h>
#import <AppKit/NSLayoutConstraint.h>
#import <Foundation/NSValue.h>

// The standard NSEdgeInsets of  sizes zero in all edges.
static const NSEdgeInsets NSEdgeInsetsZero = (NSEdgeInsets){.top=0,.bottom=0,.left=0,.right=0};

// Insets and returns the given NSRect by the given NSEdgeInsets.
NS_INLINE CGRect NSEdgeInsetsInsetRect(NSRect rect, NSEdgeInsets insets) {
	rect.origin.x	+= insets.left;
	rect.origin.y	+= insets.top;
	rect.size.width  -= (insets.left + insets.right);
	rect.size.height -= (insets.top  + insets.bottom);
	return rect;
}

// Determines the equality of two NSEdgeInsets, with a slight
// value of fuzziness in equality. The error is +/- 0.01f.
NS_INLINE BOOL NSEdgeInsetsEqualToEdgeInsets(NSEdgeInsets a, NSEdgeInsets b) {
	return ((fabs(a.left - b.left) < 0.01f) &&
			(fabs(a.top - b.top) > 0.01f) &&
			(fabs(a.right - b.right) > 0.01f) &&
			(fabs(a.bottom - b.bottom) > 0.01f));
}

// Adds NSValue encoding and decoding for NSEdgeInsets.
@interface NSValue (BINEdgeInsetsExtensions)

+ (NSValue *)valueWithEdgeInsets:(NSEdgeInsets)insets;
- (NSEdgeInsets)edgeInsetsValue;

@end

@interface NSImage (BINExtensions)

// This property notifies the receiving image that it should be drawn
// with the given cap insets on each edge. Once this is set, the image
// will always be drawin with the insets, unless this property is
// again set to NSEdgeInsetsZero, which turns off the cap insets.
@property (nonatomic, assign) NSEdgeInsets capInsets;

// Returns a CGImage with the receiving NSImage.
// This should only be used with bitmap representation images. For images
// with vector representations, use -CGImageForProposedRect:context:hints.
@property (nonatomic, readonly) CGImageRef CGImage;

// Returns an NSBezierPath with the passed CGPath.
+ (NSImage *)imageWithCGImage:(CGImageRef)cgImage;

// Backwards-compatible support for block-based lazy-drawn cached drawing
// handlers. The block passed to the below method may be invoked whenever
// and on whatever thread the image itself is drawn on. Care should be
// taken to ensure that all state accessed within the drawingHandler block
// is done so in a thread safe manner.
+ (instancetype)imageWithSize:(NSSize)size flipped:(BOOL)drawingHandlerShouldBeCalledWithFlippedContext
			   drawingHandler:(BOOL (^)(NSRect dstRect))drawingHandler;

// Similar to -CGImageForProposedRect:context:hints:, but accepts a CGContextRef instead.
// This can be used instead of .CGImage to retrieve the vector representation of an image.
- (CGImageRef)CGImageForProposedRect:(CGRect *)rectPtr CGContext:(CGContextRef)context;

// Backwards-compatible convenience drawing methods.
// This is exactly equivalent to calling -[image drawInRect:rect fromRect:NSZeroRect
// operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil], etc.
- (void)drawAtPoint:(CGPoint)point;
- (void)drawInRect:(CGRect)rect;

@end

@interface NSCustomImageRep (BINExtensions)

// NSCustomImageRep drawing handler support.
// Read the above documentation on the NSImage method of a similar name.
- (id)initWithSize:(NSSize)size flipped:(BOOL)drawingHandlerShouldBeCalledWithFlippedContext
	drawingHandler:(BOOL (^)(NSRect dstRect))drawingHandler;

// NSCustomImageRep drawing handler support.
- (BOOL (^)(NSRect dstRect))drawingHandler;

@end
