#import "NSBezierPath+BINExtensions.h"
#import <objc/runtime.h>

static void BIN_CGPathCallback(void *info, const CGPathElement *element) {
	NSBezierPath *path = (__bridge NSBezierPath *)(info);
	CGPoint *points = element->points;
	
	switch (element->type) {
		case kCGPathElementMoveToPoint: {
			[path moveToPoint:NSMakePoint(points[0].x, points[0].y)];
			break;
		} case kCGPathElementAddLineToPoint: {
			[path lineToPoint:NSMakePoint(points[0].x, points[0].y)];
			break;
		} case kCGPathElementAddQuadCurveToPoint: {
			NSPoint currentPoint = [path currentPoint];
			NSPoint interpolatedPoint = NSMakePoint((currentPoint.x + 2*points[0].x) / 3,
													(currentPoint.y + 2*points[0].y) / 3);
			[path curveToPoint:NSMakePoint(points[1].x, points[1].y)
				 controlPoint1:interpolatedPoint
				 controlPoint2:interpolatedPoint];
			break;
		} case kCGPathElementAddCurveToPoint: {
			[path curveToPoint:NSMakePoint(points[2].x, points[2].y)
				 controlPoint1:NSMakePoint(points[0].x, points[0].y)
				 controlPoint2:NSMakePoint(points[1].x, points[1].y)];
			break;
		} case kCGPathElementCloseSubpath: {
			[path closePath];
			break;
		}
	}
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma clang diagnostic ignored "-Wobjc-property-implementation"
@implementation NSBezierPath (BINExtensions)

+ (void)load {
	if(!class_getInstanceMethod(NSBezierPath.class, @selector(CGPath))) {
		Method m = class_getInstanceMethod(NSBezierPath.class, @selector(BIN_CGPath));
		class_addMethod(NSColor.class, @selector(CGPath),
						class_getMethodImplementation(NSBezierPath.class, @selector(BIN_CGPath)),
						method_getTypeEncoding(m));
	}
	
	if(!class_getInstanceMethod(NSBezierPath.class, @selector(bezierPathWithCGPath:))) {
		Method m = class_getInstanceMethod(NSBezierPath.class, @selector(BIN_bezierPathWithCGPath:));
		class_addMethod(NSColor.class, @selector(bezierPathWithCGPath:),
						class_getMethodImplementation(NSBezierPath.class, @selector(BIN_bezierPathWithCGPath:)),
						method_getTypeEncoding(m));
	}
}

+ (NSBezierPath *)BIN_bezierPathWithCGPath:(CGPathRef)pathRef {
	NSBezierPath *path = [NSBezierPath bezierPath];
	CGPathApply(pathRef, (__bridge void *)(path), BIN_CGPathCallback);
	return path;
}

- (CGPathRef)BIN_CGPath CF_RETURNS_RETAINED {
	CGPathRef immutablePath = NULL;
	NSInteger numElements = [self elementCount];
	
	if(numElements > 0) {
		CGMutablePathRef path = CGPathCreateMutable();
		NSPoint points[3];
		BOOL didClosePath = YES;
		
		for(int i = 0; i < numElements; i++) {
			switch ([self elementAtIndex:i associatedPoints:points]) {
				case NSMoveToBezierPathElement:
					CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
					break;
				case NSLineToBezierPathElement:
					CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
					didClosePath = NO;
					break;
				case NSCurveToBezierPathElement:
					CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
										  points[1].x, points[1].y,
										  points[2].x, points[2].y);
					didClosePath = NO;
					break;
				case NSClosePathBezierPathElement:
					CGPathCloseSubpath(path);
					didClosePath = YES;
					break;
			}
		}
		
		if(!didClosePath)
			CGPathCloseSubpath(path);
		
		immutablePath = CGPathCreateCopy(path);
		CGPathRelease(path);
	}
	
	return immutablePath;
}

- (void)fillWithInnerShadow:(NSShadow *)shadow {
	NSSize offset = shadow.shadowOffset;
	NSSize originalOffset = offset;
	CGFloat radius = shadow.shadowBlurRadius;
	NSRect bounds = NSInsetRect(self.bounds, -(fabs(offset.width) + radius), -(fabs(offset.height) + radius));
	offset.height += bounds.size.height;
	shadow.shadowOffset = offset;
	
	NSAffineTransform *transform = [NSAffineTransform transform];
	if ([[NSGraphicsContext currentContext] isFlipped])
		[transform translateXBy:0 yBy:bounds.size.height];
	else
		[transform translateXBy:0 yBy:-bounds.size.height];
	
	NSBezierPath *drawingPath = [NSBezierPath bezierPathWithRect:bounds];
	[drawingPath setWindingRule:NSEvenOddWindingRule];
	[drawingPath appendBezierPath:self];
	[drawingPath transformUsingAffineTransform:transform];
	
	[NSGraphicsContext saveGraphicsState];
	[self addClip];
	[shadow set];
	
	[[NSColor blackColor] set];
	[drawingPath fill];
	[NSGraphicsContext restoreGraphicsState];
	
	shadow.shadowOffset = originalOffset;
}

- (void)drawBlurWithColor:(NSColor *)color radius:(CGFloat)radius {
	NSRect bounds = NSInsetRect(self.bounds, -radius, -radius);
	NSShadow *shadow = [NSShadow shadowWithRadius:radius offset:NSMakeSize(0, bounds.size.height) color:color];
	
	NSBezierPath *path = [self copy];
	NSAffineTransform *transform = [NSAffineTransform transform];
	if([[NSGraphicsContext currentContext] isFlipped])
		[transform translateXBy:0 yBy:bounds.size.height];
	else
		[transform translateXBy:0 yBy:-bounds.size.height];
	[path transformUsingAffineTransform:transform];
	
	[NSGraphicsContext saveGraphicsState];
	[shadow set];
	[[NSColor blackColor] set];
	
	NSRectClip(bounds);
	[path fill];
	[NSGraphicsContext restoreGraphicsState];
}

- (void)strokeInside {
	[self strokeInsideWithinRect:NSZeroRect];
}

- (void)strokeInsideWithinRect:(NSRect)clipRect {
	CGFloat lineWidth = self.lineWidth;
	
	[NSGraphicsContext saveGraphicsState];
	self.lineWidth *= 2.0f;
	[self setClip];
	
	if (clipRect.size.width > 0.0 && clipRect.size.height > 0.0)
		[NSBezierPath clipRect:clipRect];
	
	[self stroke];
	[NSGraphicsContext restoreGraphicsState];
	
	self.lineWidth = lineWidth;
}
#pragma clang diagnostic pop

@end
