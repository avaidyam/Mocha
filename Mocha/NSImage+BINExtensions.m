/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import "NSImage+BINExtensions.h"
#import "NSColor+BINExtensions.h"
#import <AppKit/NSGraphicsContext.h>
#import <objc/runtime.h>

@implementation NSValue (BINEdgeInsetsExtensions)

+ (NSValue *)valueWithEdgeInsets:(NSEdgeInsets)insets {
	return [NSValue valueWithBytes:&insets objCType:@encode(NSEdgeInsets)];
}

- (NSEdgeInsets)edgeInsetsValue {
	NSEdgeInsets insets = NSEdgeInsetsZero;
	[self getValue:&insets];
	return insets;
}

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma clang diagnostic ignored "-Wobjc-property-implementation"
@implementation NSImage (BINExtensions)

@dynamic capInsets;
static const char *capInsets_key = "capInsets_key";
- (NSEdgeInsets)capInsets {
	return [objc_getAssociatedObject(self, capInsets_key) edgeInsetsValue];
}
- (void)setCapInsets:(NSEdgeInsets)capInsets {
	objc_setAssociatedObject(self, capInsets_key, [NSValue valueWithEdgeInsets:capInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load {
	[self attemptToSwapInstanceMethod:@selector(drawInRect:fromRect:operation:fraction:respectFlipped:hints:)
						   withPrefix:MochaPrefix];
	[self attemptToSwapInstanceMethod:@selector(isEqual:)
						   withPrefix:MochaPrefix];
	[self attemptToAddInstanceMethod:@selector(drawInRect:)
						  withPrefix:MochaPrefix];
	[self attemptToAddClassMethod:@selector(imageWithSize:flipped:drawingHandler:)
					   withPrefix:MochaPrefix];
}

+ (instancetype)imageWithCGImage:(CGImageRef)cgImage {
	CGSize size = CGSizeMake(CGImageGetWidth(cgImage), CGImageGetHeight(cgImage));
	return [[self alloc] initWithCGImage:cgImage size:size];
}

- (CGImageRef)CGImage {
	return [self CGImageForProposedRect:NULL context:nil hints:nil];
}

- (CGImageRef)CGImageForProposedRect:(CGRect *)rectPtr CGContext:(CGContextRef)context {
	NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
	return [self CGImageForProposedRect:rectPtr context:graphicsContext hints:nil];
}

- (void)drawAtPoint:(CGPoint)point {
	[self drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

- (void)BIN_drawInRect:(CGRect)rect {
	[self drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver
			fraction:1 respectFlipped:YES hints:nil];
}

+ (instancetype)BIN_imageWithSize:(NSSize)size flipped:(BOOL)flip drawingHandler:(BOOL (^)(NSRect dstRect))handler {
	NSImage *image = [[self alloc] initWithSize:size];
	[image addRepresentation:[[NSCustomImageRep alloc] initWithSize:size flipped:flip drawingHandler:handler]];
	return image;
}

#warning "This method does not function properly."
- (void)BIN_drawInRect:(NSRect)dstRect fromRect:(NSRect)srcRect operation:(NSCompositingOperation)op
			  fraction:(CGFloat)alpha respectFlipped:(BOOL)respectFlipped hints:(NSDictionary *)hints {
	
	//if(NSEdgeInsetsEqualToEdgeInsets(self.capInsets, NSEdgeInsetsZero))
		return [self BIN_drawInRect:dstRect fromRect:srcRect operation:op fraction:alpha
					 respectFlipped:respectFlipped hints:hints];
	
	if(NSIsEmptyRect(dstRect))
		dstRect = CGContextGetClipBoundingBox(NSGraphicsContext.currentContext.graphicsPort);
	CGImageRef image = [self CGImageForProposedRect:&dstRect context:NSGraphicsContext.currentContext hints:hints];
	NSAssert(image != NULL, @"Could not get CGImage of %@ for resizing", self);
	
	CGFloat widthScale = CGImageGetWidth(image) / self.size.width;
	CGFloat heightScale = CGImageGetHeight(image) / self.size.height;
	
	NSEdgeInsets insets = self.capInsets;
	if(CGRectIsEmpty(srcRect))
		CGImageRetain(image);
	else {
		CGRect scaledRect = CGRectMake(srcRect.origin.x * widthScale, srcRect.origin.y * heightScale,
									   srcRect.size.width * widthScale, srcRect.size.height * heightScale);
		image = CGImageCreateWithImageInRect(image, scaledRect);
		if(image == NULL)
			return;
		
		insets.left = fmax(0, insets.left - CGRectGetMinX(srcRect));
		insets.bottom = fmax(0, insets.bottom - CGRectGetMinY(srcRect));
		
		CGFloat srcRightInset = self.size.width - CGRectGetMaxX(srcRect);
		insets.right = fmax(0, insets.right - srcRightInset);
		
		CGFloat srcTopInset = self.size.height - CGRectGetMaxY(srcRect);
		insets.top = fmax(0, insets.top - srcTopInset);
	}
	
	NSImage *topLeft = nil, *topEdge = nil, *topRight = nil;
	NSImage *leftEdge = nil, *center = nil, *rightEdge = nil;
	NSImage *bottomLeft = nil, *bottomEdge = nil, *bottomRight = nil;
	CGFloat verticalEdgeLength = fmax(0, self.size.height - insets.top - insets.bottom);
	CGFloat horizontalEdgeLength = fmax(0, self.size.width - insets.left - insets.right);
	
	NSImage *(^imageWithRect)(CGRect) = ^NSImage * (CGRect rect) {
		CGRect scaledRect = NSMakeRect(rect.origin.x * widthScale, rect.origin.y * heightScale,
									   rect.size.width * widthScale, rect.size.height * heightScale);
		CGImageRef part = CGImageCreateWithImageInRect(image, scaledRect);
		if (part == NULL)
			return nil;
		
		NSImage *image = [[NSImage alloc] initWithCGImage:part size:rect.size];
		CGImageRelease(part);
		return image;
	};
	
	if(verticalEdgeLength > 0) {
		if(insets.left > 0)
			leftEdge = imageWithRect(NSMakeRect(0, insets.bottom, insets.left, verticalEdgeLength));
		if(insets.right > 0)
			rightEdge = imageWithRect(NSMakeRect(self.size.width - insets.right, insets.bottom,
												 insets.right, verticalEdgeLength));
	}
	
	if(horizontalEdgeLength > 0) {
		if(insets.bottom > 0)
			bottomEdge = imageWithRect(NSMakeRect(insets.left, 0, horizontalEdgeLength, insets.bottom));
		if(insets.top > 0)
			topEdge = imageWithRect(NSMakeRect(insets.left, self.size.height - insets.top,
											   horizontalEdgeLength, insets.top));
	}
	
	if(insets.left > 0 && insets.top > 0)
		topLeft = imageWithRect(NSMakeRect(0, self.size.height - insets.top, insets.left, insets.top));
	if(insets.left > 0 && insets.bottom > 0)
		bottomLeft = imageWithRect(NSMakeRect(0, 0, insets.left, insets.bottom));
	if(insets.right > 0 && insets.top > 0)
		topRight = imageWithRect(NSMakeRect(self.size.width - insets.right, self.size.height - insets.top,
											insets.right, insets.top));
	if(insets.right > 0 && insets.bottom > 0)
		bottomRight = imageWithRect(NSMakeRect(self.size.width - insets.right, 0,
											   insets.right, insets.bottom));
	
	CGRect centerRect = NSMakeRect(insets.left, insets.bottom, horizontalEdgeLength, verticalEdgeLength);
	if(centerRect.size.width > 0 && centerRect.size.height > 0)
		center = imageWithRect(centerRect);
	CGImageRelease(image);
	
	BOOL flipped = NO;
	if(respectFlipped)
		flipped = [NSGraphicsContext.currentContext isFlipped];
	
	if(topLeft != nil || bottomRight != nil)
		NSDrawNinePartImage(dstRect, bottomLeft, bottomEdge, bottomRight, leftEdge, center,
							rightEdge, topLeft, topEdge, topRight, op, alpha, flipped);
	else if (leftEdge != nil)
		NSDrawThreePartImage(dstRect, leftEdge, center, rightEdge, NO, op, alpha, flipped);
	else NSDrawThreePartImage(dstRect, (flipped ? bottomEdge : topEdge), center,
							  (flipped ? topEdge : bottomEdge), YES, op, alpha, flipped);
}

- (BOOL)BIN_isEqual:(NSImage *)image {
	if(![self BIN_isEqual:image])
		return NO;
	return NSEdgeInsetsEqualToEdgeInsets(self.capInsets, image.capInsets);
}

@end

@implementation NSCustomImageRep (BINExtensions)

static const char *drawingHandler_key = "drawingHandler_key";
static const char *flipped_key = "flipped_key";

+ (void)load {
	[self attemptToSwapInstanceMethod:@selector(draw)
						   withPrefix:MochaPrefix];
	[self attemptToAddInstanceMethod:@selector(drawingHandler)
						  withPrefix:MochaPrefix];
	[self attemptToAddInstanceMethod:@selector(initWithSize:flipped:drawingHandler:)
						  withPrefix:MochaPrefix];
}

- (id)initWithSize_BIN:(NSSize)size flipped:(BOOL)flip drawingHandler:(BOOL (^)(NSRect dstRect))handle {
	if((self = [super init])) {
		objc_setAssociatedObject(self, drawingHandler_key, handle, OBJC_ASSOCIATION_COPY);
		objc_setAssociatedObject(self, flipped_key, @(flip), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		self.size = size;
	}
	return self;
}

- (BOOL (^)(NSRect dstRect))BIN_drawingHandler {
	return objc_getAssociatedObject(self, drawingHandler_key);
}

- (BOOL)BIN_draw {
	if(self.drawingHandler != nil) {
		BOOL flip = [objc_getAssociatedObject(self, flipped_key) boolValue];
		NSGraphicsContext *old = [NSGraphicsContext currentContext];
		
		NSGraphicsContext *ctx = [NSGraphicsContext graphicsContextWithGraphicsPort:old.graphicsPort flipped:flip];
		[NSGraphicsContext setCurrentContext:ctx];
		self.drawingHandler((NSRect){NSZeroPoint, self.size});
		[NSGraphicsContext setCurrentContext:old];
		
		return YES;
	} else return [self BIN_draw];
}

@end
#pragma clang diagnostic pop
