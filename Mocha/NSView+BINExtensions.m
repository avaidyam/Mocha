#import "NSView+BINExtensions.h"
#import "NSColor+BINExtensions.h"
#import "NSAffineTransform+BINExtensions.h"
#import <objc/runtime.h>

@interface NSView (BINExtensionsPrivate)

@property (nonatomic, strong) NSMutableDictionary *layerFlags;

@end

@implementation NSView (BINExtensionsPrivate)

@dynamic layerFlags;
static const char *layerFlags_key = "layerFlags_key";
- (NSMutableDictionary *)layerFlags {
	NSMutableDictionary *dict = objc_getAssociatedObject(self, layerFlags_key);
	if(dict == nil)
		self.layerFlags = dict = @{}.mutableCopy;
	return dict;
}
- (void)setLayerFlags:(NSMutableDictionary *)layerFlags {
	objc_setAssociatedObject(self, layerFlags_key, layerFlags, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static IMP NSViewDrawRectIMP;
+ (void)initialize {
	if(self != [NSView class])
		return;
	NSViewDrawRectIMP = [self instanceMethodForSelector:@selector(drawRect:)];
}
+ (BOOL)doesCustomDrawing {
	return [self instanceMethodForSelector:@selector(drawRect:)] != NSViewDrawRectIMP;
}

- (void)setKeyEquivalent:(NSString *)equiv {
	// Unimplemented. Fixes a few AppKit issues.
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p>{ frame = %@, layer = <%@: %p> }",
			self.class, self, NSStringFromRect(self.frame), self.layer.class, self.layer];
}

@end

@implementation NSView (BINProperties)

- (void)setTag:(NSInteger)tag {
	self.layerFlags[@"tag"] = @(tag);
}

- (void)setNeedsPanelToBecomeKey:(BOOL)value {
	self.layerFlags[@"needsPanelToBecomeKey"] = @(value);
}

- (void)setMouseDownCanMoveWindow:(BOOL)value {
	self.layerFlags[@"mouseDownCanMoveWindow"] = @(value);
}

- (void)setOpaque:(BOOL)value {
	self.layerFlags[@"opaque"] = @(value);
}

- (void)setFlipped:(BOOL)value {
	if(value == self.flipped)
		return;
	self.layerFlags[@"flipped"] = @(value);
	self.needsDisplay = YES;
}

- (NSPoint)center {
	return CGPointMake(NSMidX(self.frame), NSMidY(self.frame));
}

- (void)setCenter:(NSPoint)center {
	NSRect f = self.frame;
	f.origin = CGPointMake(center.x - f.size.width * 0.5, center.y - f.size.height * 0.5);
	self.frame = f;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (NSInteger)tag {
	return [self.layerFlags[@"tag"] integerValue];
}

- (BOOL)needsPanelToBecomeKey {
	return [self.layerFlags[@"needsPanelToBecomeKey"] integerValue];
}

- (BOOL)mouseDownCanMoveWindow {
	return [self.layerFlags[@"mouseDownCanMoveWindow"] integerValue];
}

- (BOOL)isOpaque {
	return [self.layerFlags[@"opaque"] boolValue];
}

/*- (BOOL)isFlipped {
	return [self.layerFlags[@"flipped"] boolValue];
}//*/

#pragma clang diagnostic pop

@end

@implementation NSView (BINExtensionsLayout)

+ (void)load {
	NSError *error = nil;
	if(![NSView exchangeInstanceMethod:@selector(layout)
							withMethod:@selector(BIN_layout)
								 error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
}

// Necessary for -layout to be consistently invoked.
+ (BOOL)requiresConstraintBasedLayout {
	return YES;
}

- (void)BIN_layout {
	[self BIN_layout];
	[self layoutSubviews];
}

- (void)layoutSubviews {
	// Unimplemented for subclassing.
}

@end

/*@implementation NSView (BINExtensionsLayer)

+ (void)load {
	NSError *error = nil;
	if(![NSView exchangeInstanceMethod:@selector(drawRect:)
							withMethod:@selector(BIN_drawRect:)
								 error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
	
	error = nil;
	if(![NSView exchangeInstanceMethod:@selector(hitTest:)
							withMethod:@selector(BIN_hitTest:)
								 error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
	
	error = nil;
	if(![NSView exchangeInstanceMethod:@selector(setLayer:)
							withMethod:@selector(BIN_setLayer:)
								 error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
}

- (id)initWithFrame_BIN:(NSRect)frame {
	if((self = [self initWithFrame_BIN:frame])) {
		//self.wantsLayer = YES;
		self.userInteractionEnabled = YES;
		self.layerContentsPlacement = NSViewLayerContentsPlacementScaleAxesIndependently;
		self.clearsContextBeforeDrawing = YES;
		
		if (self.class.doesCustomDrawing) {
			// Use more conservative defaults if -drawRect: is overridden, to ensure
			// correct drawing. Callers or subclasses can override these defaults
			// to optimize for performance instead.
			self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawDuringViewResize;
		} else {
			self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawNever;
		}
	}
	return self;
}

- (NSColor *)backgroundColor {
	return self.layerFlags[@"backgroundColor"];
}

- (void)setBackgroundColor:(NSColor *)color {
	self.layerFlags[@"backgroundColor"] = color;
	[self applyLayerProperties];
}

- (CGFloat)cornerRadius {
	return [self.layerFlags[@"cornerRadius"] floatValue];
}

- (void)setCornerRadius:(CGFloat)radius {
	self.layerFlags[@"cornerRadius"] = @(radius);
	[self applyLayerProperties];
}

- (BOOL)clipsToBounds {
	return [self.layerFlags[@"clipsToBounds"] boolValue];
}

- (void)setClipsToBounds:(BOOL)value {
	self.layerFlags[@"clipsToBounds"] = @(value);
	[self applyLayerProperties];
}

- (BOOL)clearsContextBeforeDrawing {
	return [self.layerFlags[@"clearsContextBeforeDrawing"] boolValue];
}

- (void)setClearsContextBeforeDrawing:(BOOL)value {
	self.layerFlags[@"clearsContextBeforeDrawing"] = @(value);
}

- (NSAffineTransform *)transform {
	return self.layerFlags[@"transform"];
}

- (void)setTransform:(NSAffineTransform *)transform {
	self.layerFlags[@"transform"] = transform;
	[self applyLayerProperties];
}

- (BOOL)isUserInteractionEnabled {
	return [self.layerFlags[@"userInteractionEnabled"] boolValue];
}

- (void)setUserInteractionEnabled:(BOOL)value {
	self.layerFlags[@"userInteractionEnabled"] = @(value);
}

// FIXME: Context Clearance flag doesn't work.
- (void)BIN_drawRect:(NSRect)rect {
	//if(self.clearsContextBeforeDrawing && !self.opaque)
	//	CGContextClearRect(NSGraphicsContext.currentContext.graphicsPort, rect);
}

// FIXME: User Interaction flag doesn't work.
- (NSView *)BIN_hitTest:(NSPoint)aPoint {
	//if(!self.userInteractionEnabled || self.hidden || (self.alphaValue <= 0.0f))
	//	return nil;
	return [self BIN_hitTest:aPoint];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (void)viewDidMoveToSuperview {
	[self applyLayerProperties];
}

- (void)viewDidMoveToWindow {
	[self applyLayerProperties];
}

- (CALayer *)makeBackingLayer {
	return [self.class.layerClass layer];
}

#pragma clang diagnostic pop

+ (Class)layerClass {
	return NSClassFromString(@"_NSViewBackingLayer");
}

- (void)applyLayerProperties {
	self.layer.cornerRadius = self.cornerRadius;
	self.layer.masksToBounds = self.clipsToBounds;
	//self.layer.opaque = self.opaque;
	if(self.backgroundColor)
		self.layer.backgroundColor = self.backgroundColor.CGColor;
	if(self.transform)
		self.layer.affineTransform = self.transform.CGAffineTransform;
}

- (void)BIN_setLayer:(CALayer *)layer {
	[self BIN_setLayer:layer];
	[self applyLayerProperties];
}

@end//*/

@implementation NSView (BINExtensions)

- (NSImage *)snapshot {
	NSBitmapImageRep *rep = [self bitmapImageRepForCachingDisplayInRect:self.bounds];
	rep.size = self.bounds.size;
	[self cacheDisplayInRect:self.bounds toBitmapImageRep:rep];
	
	NSImage *image = [[NSImage alloc] initWithSize:self.bounds.size];
	[image addRepresentation:rep];
	return image;
}

- (NSView *)layerRepresentation {
	NSView *repView = [[NSView alloc] initWithFrame:self.frame];
	repView.wantsLayer = YES;
	repView.layer.contents = self.snapshot;
	[repView display];
	return repView;
}


- (void)scrollPoint:(NSPoint)point animated:(BOOL)animated {
	[self scrollPoint:point animated:animated completionHandler:nil];
}

- (void)scrollPoint:(NSPoint)point animated:(BOOL)animated
  completionHandler:(dispatch_block_t)handler {
	if(!animated) return [self scrollPoint:point];
	
	NSClipView *clipView = self.enclosingScrollView.contentView;
    NSPoint constrainedPoint = [clipView constrainScrollPoint:point];
	[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
		context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		
		clipView.animator.boundsOrigin = constrainedPoint;
	} completionHandler:handler];
    [self.enclosingScrollView reflectScrolledClipView:clipView];
	
}

@end
