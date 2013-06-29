#import "NSImage+BINExtensions.h"
#import "NSColor+BINExtensions.h"
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
	if(!class_getInstanceMethod(NSImage.class, @selector(imageWithSize:flipped:drawingHandler:))) {
		Method m = class_getInstanceMethod(NSImage.class, @selector(BIN_imageWithSize:flipped:drawingHandler:));
		class_addMethod(NSImage.class, @selector(imageWithSize:flipped:drawingHandler:),
						class_getMethodImplementation(NSImage.class, @selector(BIN_imageWithSize:flipped:drawingHandler:)),
						method_getTypeEncoding(m));
	}
	
	if(!class_getInstanceMethod(NSImage.class, @selector(drawInRect:))) {
		Method m = class_getInstanceMethod(NSImage.class, @selector(BIN_drawInRect:));
		class_addMethod(NSImage.class, @selector(drawInRect:),
						class_getMethodImplementation(NSImage.class, @selector(BIN_drawInRect:)),
						method_getTypeEncoding(m));
	}
	
	NSError *error = nil;
	if(![NSImage exchangeInstanceMethod:@selector(drawInRect:fromRect:operation:fraction:respectFlipped:hints:)
							 withMethod:@selector(BIN_drawInRect:fromRect:operation:fraction:respectFlipped:hints:)
								  error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
	
	error = nil;
	if(![NSImage exchangeInstanceMethod:@selector(isEqual:)
							 withMethod:@selector(BIN_isEqual:)
								  error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
}

+ (NSImage *)imageWithCGImage:(CGImageRef)cgImage {
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
	[self drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
}

+ (instancetype)BIN_imageWithSize:(NSSize)size flipped:(BOOL)flip drawingHandler:(BOOL (^)(NSRect dstRect))handler {
	NSImage *image = [[self alloc] initWithSize:size];
	[image addRepresentation:[[NSCustomImageRep alloc] initWithSize:size flipped:flip drawingHandler:handler]];
	return image;
}

- (void)BIN_drawInRect:(NSRect)dstRect fromRect:(NSRect)srcRect operation:(NSCompositingOperation)op fraction:(CGFloat)alpha
		respectFlipped:(BOOL)respectFlipped hints:(NSDictionary *)hints {
	if(self.capInsets.top == 0 && self.capInsets.bottom == 0 &&
	   self.capInsets.left == 0 && self.capInsets.right == 0)
		return [self BIN_drawInRect:dstRect fromRect:srcRect operation:op fraction:alpha
					 respectFlipped:respectFlipped hints:hints];
	
	if(NSIsEmptyRect(dstRect)) {
		CGContextRef context = NSGraphicsContext.currentContext.graphicsPort;
		dstRect = CGContextGetClipBoundingBox(context);
	}
	CGImageRef image = [self CGImageForProposedRect:&dstRect context:NSGraphicsContext.currentContext hints:hints];
	NSAssert(image != NULL, @"Could not get CGImage of %@ for resizing", self);
	
	// Calculate scale factors from the pixel-independent representation to the
	// specific one we're using for this context.
	CGFloat widthScale = CGImageGetWidth(image) / self.size.width;
	CGFloat heightScale = CGImageGetHeight(image) / self.size.height;
	
	NSEdgeInsets insets = self.capInsets;
	if(CGRectIsEmpty(srcRect)) {
		// Match the image creation that occurs in the 'else' clause.
		CGImageRetain(image);
	} else {
		CGRect scaledRect = CGRectMake(srcRect.origin.x * widthScale, srcRect.origin.y * heightScale, srcRect.size.width * widthScale, srcRect.size.height * heightScale);
		image = CGImageCreateWithImageInRect(image, scaledRect);
		if(image == NULL)
			return;
		
		// Reduce insets to account for taking only part of the original image.
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
	
	NSImage *(^imageWithRect)(CGRect) = ^ id (CGRect rect) {
		CGRect scaledRect = CGRectMake(rect.origin.x * widthScale, rect.origin.y * heightScale, rect.size.width * widthScale, rect.size.height * heightScale);
		CGImageRef part = CGImageCreateWithImageInRect(image, scaledRect);
		if (part == NULL) return nil;
		
		NSImage *image = [[NSImage alloc] initWithCGImage:part size:rect.size];
		CGImageRelease(part);
		
		return image;
	};
	
	if (verticalEdgeLength > 0) {
		if (insets.left > 0) {
			CGRect partRect = CGRectMake(0, insets.bottom, insets.left, verticalEdgeLength);
			leftEdge = imageWithRect(partRect);
		}
		
		if (insets.right > 0) {
			CGRect partRect = CGRectMake(self.size.width - insets.right, insets.bottom, insets.right, verticalEdgeLength);
			rightEdge = imageWithRect(partRect);
		}
	}
	
	if (horizontalEdgeLength > 0) {
		if (insets.bottom > 0) {
			CGRect partRect = CGRectMake(insets.left, 0, horizontalEdgeLength, insets.bottom);
			bottomEdge = imageWithRect(partRect);
		}
		
		if (insets.top > 0) {
			CGRect partRect = CGRectMake(insets.left, self.size.height - insets.top, horizontalEdgeLength, insets.top);
			topEdge = imageWithRect(partRect);
		}
	}
	
	if (insets.left > 0 && insets.top > 0) {
		CGRect partRect = CGRectMake(0, self.size.height - insets.top, insets.left, insets.top);
		topLeft = imageWithRect(partRect);
	}
	
	if (insets.left > 0 && insets.bottom > 0) {
		CGRect partRect = CGRectMake(0, 0, insets.left, insets.bottom);
		bottomLeft = imageWithRect(partRect);
	}
	
	if (insets.right > 0 && insets.top > 0) {
		CGRect partRect = CGRectMake(self.size.width - insets.right, self.size.height - insets.top, insets.right, insets.top);
		topRight = imageWithRect(partRect);
	}
	
	if (insets.right > 0 && insets.bottom > 0) {
		CGRect partRect = CGRectMake(self.size.width - insets.right, 0, insets.right, insets.bottom);
		bottomRight = imageWithRect(partRect);
	}
	
	CGRect centerRect = CGRectMake(insets.left, insets.bottom, horizontalEdgeLength, verticalEdgeLength);
	if (centerRect.size.width > 0 && centerRect.size.height > 0) {
		center = imageWithRect(centerRect);
	}
	
	CGImageRelease(image);
	
	BOOL flipped = NO;
	if (respectFlipped) {
		flipped = [NSGraphicsContext.currentContext isFlipped];
	}
	
	if (topLeft != nil || bottomRight != nil) {
		NSDrawNinePartImage(dstRect, bottomLeft, bottomEdge, bottomRight, leftEdge, center, rightEdge, topLeft, topEdge, topRight, op, alpha, flipped);
	} else if (leftEdge != nil) {
		// Horizontal three-part image.
		NSDrawThreePartImage(dstRect, leftEdge, center, rightEdge, NO, op, alpha, flipped);
	} else {
		// Vertical three-part image.
		NSDrawThreePartImage(dstRect, (flipped ? bottomEdge : topEdge), center, (flipped ? topEdge : bottomEdge), YES, op, alpha, flipped);
	}
	return;
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
- (BOOL (^)(NSRect dstRect))BIN_drawingHandler {
	return objc_getAssociatedObject(self, drawingHandler_key);
}

+ (void)load {
	NSError *error = nil;
	if(![NSCustomImageRep exchangeInstanceMethod:@selector(draw)
									  withMethod:@selector(BIN_draw)
										   error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
	
	if(!class_getInstanceMethod(NSImage.class, @selector(drawingHandler))) {
		Method m = class_getInstanceMethod(NSImage.class, @selector(BIN_drawingHandler));
		class_addMethod(NSImage.class, @selector(drawingHandler),
						class_getMethodImplementation(NSImage.class, @selector(BIN_drawingHandler)),
						method_getTypeEncoding(m));
	}
	
	if(!class_getInstanceMethod(NSImage.class, @selector(initWithSize:flipped:drawingHandler:))) {
		Method m = class_getInstanceMethod(NSImage.class, @selector(initWithSize_BIN:flipped:drawingHandler:));
		class_addMethod(NSImage.class, @selector(initWithSize:flipped:drawingHandler:),
						class_getMethodImplementation(NSImage.class, @selector(initWithSize_BIN:flipped:drawingHandler:)),
						method_getTypeEncoding(m));
	}
}


- (id)initWithSize_BIN:(NSSize)size flipped:(BOOL)flip drawingHandler:(BOOL (^)(NSRect dstRect))handle {
	if((self = [super init])) {
		objc_setAssociatedObject(self, drawingHandler_key, handle, OBJC_ASSOCIATION_COPY);
		objc_setAssociatedObject(self, flipped_key, @(flip), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		self.size = size;
	}
	return self;
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
