/*
 Copyright (c) 2013, Jonathan Willing. All rights reserved.
 Licensed under the MIT license <http://opensource.org/licenses/MIT>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 documentation files (the "Software"), to deal in the Software without restriction, including without limitation
 the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
 to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 IN THE SOFTWARE.
 */

#import "NSWindow+BINExtensions.h"
#import <objc/runtime.h>

static NSUInteger BINAnimatableWindowOpenTransactions = 0;

static const CGFloat BINAnimatableWindowShadowOpacity = 0.58f;
static const CGSize BINAnimatableWindowShadowOffset = (CGSize){ 0, -30 };
static const CGFloat BINAnimatableWindowShadowRadius = 19.f;
static const CGFloat BINAnimatableWindowShadowHorizontalOutset = 7.f;
static const CGFloat BINAnimatableWindowShadowTopOffset = 14.f;

#define BINAnimatableWindowDefaultAnimationCurve kCAMediaTimingFunctionEaseInEaseOut
#define BINDefaultTimingFunction [CAMediaTimingFunction functionWithName: \
								  BINAnimatableWindowDefaultAnimationCurve]

@interface BINAnimatableWindowContentView : NSView
@end

@interface NSWindow (BINExtensions_Private)

- (NSImage *)imageRepresentationOffscreen:(BOOL)forceOffscreen;

- (void)startLivePreviewTimer;
- (void)stopLivePreviewTimer;

@end

@interface NSWindow (BINExtensionsAccessors)

@property (nonatomic, assign) BOOL livePreview;
@property (nonatomic, assign) BOOL useLayerShadow;
@property (nonatomic, assign) BOOL disableConstrainedWindow;

@property (nonatomic, assign) CVDisplayLinkRef livePreviewTimer;
@property (nonatomic, strong) NSWindow *fullScreenWindow;
@property (nonatomic, strong) CALayer *windowRepresentationLayer;

@end

@implementation NSWindow (BINExtensions)

@dynamic livePreview;
@dynamic useLayerShadow;

#pragma mark - Object Lifecycle

- (instancetype)initWithContentRect:(NSRect)contentRect {
	return [self initWithContentRect:contentRect styleMask:NSWindowStyleClosable | NSWindowStyleMiniaturizable | NSWindowStyleResizable | NSWindowStyleTitled];
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyle)style {
	return [self initWithContentRect:contentRect styleMask:style screen:[NSScreen mainScreen]];
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyle)style
							 screen:(NSScreen *)screen {
	return [self initWithContentRect:contentRect styleMask:style
							 backing:NSBackingStoreBuffered defer:NO screen:screen];
}

#pragma mark - Representation Lifecycle

- (void)initializeWindowRepresentationLayer {
	self.windowRepresentationLayer = [CALayer layer];
	self.windowRepresentationLayer.contentsScale = self.backingScaleFactor;
	
	CGColorRef shadowColor = CGColorCreateGenericRGB(0, 0, 0, BINAnimatableWindowShadowOpacity);
	self.windowRepresentationLayer.shadowColor = shadowColor;
	self.windowRepresentationLayer.shadowOffset = BINAnimatableWindowShadowOffset;
	self.windowRepresentationLayer.shadowRadius = BINAnimatableWindowShadowRadius;
	self.windowRepresentationLayer.shadowOpacity = self.useLayerShadow ? 1.0f : 0.0f;
	CGColorRelease(shadowColor);
	
	CGPathRef shadowPath = CGPathCreateWithRect(self.shadowRect, NULL);
	self.windowRepresentationLayer.shadowPath = shadowPath;
	CGPathRelease(shadowPath);
	
	self.windowRepresentationLayer.contentsGravity = kCAGravityResize;
	self.windowRepresentationLayer.opaque = YES;
}

- (void)initializeFullScreenWindow {
	self.fullScreenWindow = [[NSWindow alloc] initWithContentRect:self.screen.frame
														styleMask:NSBorderlessWindowMask
														  backing:NSBackingStoreBuffered
															defer:NO screen:self.screen];
	self.fullScreenWindow.animationBehavior = NSWindowAnimationBehaviorNone;
	self.fullScreenWindow.backgroundColor = [NSColor clearColor];
	self.fullScreenWindow.movableByWindowBackground = NO;
	self.fullScreenWindow.ignoresMouseEvents = YES;
	self.fullScreenWindow.level = self.level;
	self.fullScreenWindow.hasShadow = NO;
	self.fullScreenWindow.opaque = NO;
	self.fullScreenWindow.contentView = [[BINAnimatableWindowContentView alloc] initWithFrame:[self.fullScreenWindow.contentView bounds]];
}


#pragma mark - Read-only Properties

- (CALayer *)layer {
	[self setupIfNeeded];
	return self.windowRepresentationLayer;
}

- (BOOL)layerInUse {
	return self.windowRepresentationLayer != nil;
}

- (CGRect)bounds {
	return (CGRect){ .size = self.frame.size };
}

- (CGRect)shadowRect {
	CGRect rect = CGRectInset(self.bounds, -BINAnimatableWindowShadowHorizontalOutset, 0);
	rect.size.height += BINAnimatableWindowShadowTopOffset;
	return rect;
}

#pragma mark - Representation Setup

- (void)setupIfNeeded {
	[self setupIfNeededWithSetupBlock:nil];
}

- (void)setupIfNeededWithSetupBlock:(void(^)(CALayer *))setupBlock {
	if(self.windowRepresentationLayer != nil)
		return;
	
	[self initializeFullScreenWindow];
	[self initializeWindowRepresentationLayer];
	
	[[self.fullScreenWindow.contentView layer] addSublayer:self.windowRepresentationLayer];
	self.windowRepresentationLayer.frame = self.frame;
	
	// Begin a non-animated transaction to ensure that the
	// layer's contents are set before we get rid of the real window.
	[CATransaction begin]; {
		[CATransaction setDisableActions:YES];
		self.windowRepresentationLayer.contents = [self imageRepresentationOffscreen:NO];
		
		// The setup block is called when we are ordering in. We want this
		// non-animated and done before the the fake window is shown, so we
		// do in in the same transaction.
		if(setupBlock != nil)
			setupBlock(self.windowRepresentationLayer);
	} [CATransaction commit];
	[self.fullScreenWindow makeKeyAndOrderFront:nil];
	
	// Effectively hide the original window. If we are ordering in,
	// the window will become visible again once the fake window is destroyed.
	self.alphaValue = 0.f;
}

- (NSImage *)imageRepresentationOffscreen:(BOOL)forceOffscreen {
	CGRect originalWindowFrame = self.frame;
	BOOL onScreen = self.isVisible;
	
	if (!onScreen || forceOffscreen) {
		// So the window is closed, and we need to get a screenshot
		// of it without flashing. First, we find the frame that covers
		// all the connected screens.
		CGRect allWindowsFrame = CGRectZero;
		for(NSScreen *screen in [NSScreen screens])
            allWindowsFrame = NSUnionRect(allWindowsFrame, screen.frame);
		
		// Position our window to the very right-most corner out
		// of visible range, plus padding for the shadow.
		CGRect frame = (CGRect) {
			.origin.x = CGRectGetWidth(allWindowsFrame) + 2 * BINAnimatableWindowShadowRadius,
			.size = originalWindowFrame.size
		};
		
		// This is where things get nasty. Against what the documentation
		// states, windows seem to be constrained to the screen, so we override
		// `constrainFrameRect:toScreen:` to return the original frame, which 
		// allows us to put the window off-screen.
		self.disableConstrainedWindow = YES;
		
		self.alphaValue = 0.f;
		if(!onScreen)
			[self makeKeyAndOrderFront:nil];
		[self setFrame:frame display:NO];
		self.disableConstrainedWindow = NO;
	}
	
	// If we are ordering ourself in, we will be off-screen and will not be visible.
	self.alphaValue = 1.f;
	
	// Grab the image representation of the window, without the shadows.
	CGImageRef imageRef = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, (CGWindowID)self.windowNumber, kCGWindowImageBoundsIgnoreFraming);
	
	// So there's a problem. As it turns out, CGWindowListCreateImage() returns a CGImageRef
	// that apparently is backed by pixels that don't actually exist until they are queried.
	//
	// This is a significant problem, because what we actually want to do is to grab the image
	// from the window, then set its alpha to 0. But if the actual pixels haven't been grabbed
	// yet, then by the time we actually use them sometime later in the run loop the alpha of
	// the window will have already gone flying off into the distance and we're left with a
	// completely transparent image. That's no good.
	//
	// So here's a very nasty workaround. What we're doing is actually forcing the real pixels
	// to get copied over from the WindowServer by actually drawing them into another context
	// that has settings optimized for use with Core Animation. This isn't too wasteful, and it's
	// far better than actually copying over all of the real pixel data.
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
	CGContextRef context = CGBitmapContextCreate(NULL, imageSize.width, imageSize.height, 8, 0,
												 [[NSColorSpace deviceRGBColorSpace] CGColorSpace], kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
    
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO]];
	NSImage *oldImage = [[NSImage alloc] initWithCGImage:imageRef size:CGSizeZero];
	[oldImage drawInRect:NSMakeRect(0, 0, imageSize.width, imageSize.height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
	[NSGraphicsContext restoreGraphicsState];
	
	CGImageRef copiedImageRef = CGBitmapContextCreateImage(context);
	NSImage *image = [[NSImage alloc] initWithCGImage:copiedImageRef size:CGSizeZero];
	
	CGImageRelease(imageRef);
	CGImageRelease(copiedImageRef);
	CGContextRelease(context);
	
	// If we weren't originally on the screen, there's a good
	// chance we shouldn't be visible yet.
	if (!onScreen || forceOffscreen)
		self.alphaValue = 0.f;
	
	// If we moved the window offscreen to get the screenshot,
	// we want to move back to the original frame.
	if(!CGRectEqualToRect(originalWindowFrame, self.frame))
		[self setFrame:originalWindowFrame display:NO];
	
	return image;
}

#pragma mark - Live Preview

static CVReturn BINWindowAnimationLayerTimer(CVDisplayLinkRef displayLink, const CVTimeStamp* now,
											 const CVTimeStamp *outputTime, CVOptionFlags flagsIn,
											 CVOptionFlags *flagsOut, void *context) {
	NSWindow *self = (__bridge id)context;
	
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	self.windowRepresentationLayer.contents = [self imageRepresentationOffscreen:NO];
	[CATransaction commit];
	
    return kCVReturnSuccess;
}

- (void)startLivePreviewTimer {
	CVDisplayLinkRef link = self.livePreviewTimer;
	
	if((link == nil || !CVDisplayLinkIsRunning(link)) && self.livePreview) {
		CVDisplayLinkCreateWithActiveCGDisplays(&link);
		CVDisplayLinkSetOutputCallback(link, &BINWindowAnimationLayerTimer, (__bridge void *)self);
		CVDisplayLinkStart(link);
		self.livePreviewTimer = link;
	}
}

- (void)stopLivePreviewTimer {
	CVDisplayLinkRef link = self.livePreviewTimer;
    if(link != nil && CVDisplayLinkIsRunning(link)) {
        CVDisplayLinkStop(link);
		CVDisplayLinkRelease(link);
        self.livePreviewTimer = nil;
    }
}

#pragma mark -  Method Overrides

+ (void)load {
    Method originalMethod = class_getInstanceMethod(self, @selector(constrainFrameRect:toScreen:));
    Method overrideMethod = class_getInstanceMethod(self, @selector(BIN_constrainFrameRect:toScreen:));
	
    if (class_addMethod(self, @selector(constrainFrameRect:toScreen:),
						method_getImplementation(overrideMethod),
						method_getTypeEncoding(overrideMethod))) {
		class_replaceMethod(self, @selector(BIN_constrainFrameRect:toScreen:),
							method_getImplementation(originalMethod),
							method_getTypeEncoding(originalMethod));
    } else {
		method_exchangeImplementations(originalMethod, overrideMethod);
    }
}

- (NSRect)BIN_constrainFrameRect:(NSRect)frameRect toScreen:(NSScreen *)screen {
	return (self.disableConstrainedWindow ? frameRect : [self BIN_constrainFrameRect:frameRect toScreen:screen]);
}

- (void)setFrame:(NSRect)frameRect {
	[self setFrame:frameRect display:YES];
}

#pragma mark - Convenience Animations

// The fake window is in the exact same position as the real
// one, so we can safely order ourself out.
- (void)orderOutWithDuration:(CFTimeInterval)duration
					  timing:(CAMediaTimingFunction *)timing
				  animations:(void (^)(CALayer *))animations {
	[self setupIfNeeded];
	[self orderOut:nil];
	[self performAnimations:animations withDuration:duration timing:timing];
}

- (void)orderOutWithAnimation:(CAAnimation *)animation {
	[self setupIfNeeded];
	[self orderOut:nil];
	[self performAnimation:animation forKey:@"BINOrderOut"];
}

// Avoid unnecessary layout passes if we're already visible when
// this method is called. This could take place if the window
// is still being animated out, but the user suddenly changes
// their mind and the window needs to come back on screen again.
- (void)makeKeyAndOrderFrontWithDuration:(CFTimeInterval)duration
								  timing:(CAMediaTimingFunction *)timing
								   setup:(void (^)(CALayer *))setup
							  animations:(void (^)(CALayer *))animations {
	[self setupIfNeededWithSetupBlock:setup];
	
	if(!self.isVisible)
		[self makeKeyAndOrderFront:nil];
	[self performAnimations:animations withDuration:duration timing:timing];
}

- (void)makeKeyAndOrderFrontWithAnimation:(CAAnimation *)animation initialOpacity:(CGFloat)opacity {
	[self setupIfNeededWithSetupBlock:^(CALayer *layer) {
		layer.opacity = opacity;
	}];
	
	if(!self.isVisible)
		[self makeKeyAndOrderFront:nil];
	[self performAnimation:animation forKey:@"BINMakeKeyAndOrderFront"];
}

- (void)setFrame:(NSRect)frameRect
	withDuration:(CFTimeInterval)duration
		  timing:(CAMediaTimingFunction *)timing {
	[self setupIfNeeded];
	[self setFrame:frameRect display:YES animate:NO];
	
	// We need to explicitly animate the shadow path to reflect the new size.
	CGPathRef shadowPath = CGPathCreateWithRect(self.shadowRect, NULL);
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
	animation.fromValue = (id)self.windowRepresentationLayer.shadowPath;
	animation.toValue = (__bridge id)(shadowPath);
	animation.duration = duration;
	animation.timingFunction = timing ?: BINDefaultTimingFunction;
	
	[self.windowRepresentationLayer addAnimation:animation forKey:@"shadowPath"];
	self.windowRepresentationLayer.shadowPath = shadowPath;
	CGPathRelease(shadowPath);
	
	NSImage *finalState = [self imageRepresentationOffscreen:YES];
	[self performAnimations:^(CALayer *layer) {
		self.windowRepresentationLayer.frame = frameRect;
		self.windowRepresentationLayer.contents = finalState;
	} withDuration:duration timing:timing];
}

- (void)performAnimations:(void (^)(CALayer *layer))animations
			 withDuration:(CFTimeInterval)duration
				   timing:(CAMediaTimingFunction *)timing {
	[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
		context.duration = duration;
		context.timingFunction = timing ?: BINDefaultTimingFunction;
		
		animations(self.windowRepresentationLayer);
		BINAnimatableWindowOpenTransactions++;
	} completionHandler:^{
		[self destroyTransformingWindowIfNeeded];
	}];
}

- (void)performAnimation:(CAAnimation *)animation forKey:(NSString *)key {
	animation.delegate = self;
	animation.removedOnCompletion = NO;
	[self.windowRepresentationLayer addAnimation:animation forKey:key];
	
	BINAnimatableWindowOpenTransactions++;
}

// Called when the window is animated using CAAnimations.
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	[self destroyTransformingWindowIfNeeded];
}

#pragma mark - Window Lifecycle

// Calls `-destroyTransformingWindow` only when the running
// animation count is zero. If there are zero pending operations remaining,
// we can safely assume that it is time for the window to be destroyed.
- (void)destroyTransformingWindowIfNeeded {
	BINAnimatableWindowOpenTransactions--;
	
	if (BINAnimatableWindowOpenTransactions == 0) {
		[self destroyTransformingWindow];
	}
}

// Called when the ordering methods are complete. If the layer is used
// manually, this should be called when animations are complete.
- (void)destroyTransformingWindow {
	self.alphaValue = 1.f;
	
	[self.windowRepresentationLayer removeFromSuperlayer];
	self.windowRepresentationLayer.contents = nil;
	self.windowRepresentationLayer = nil;
	
	[self.fullScreenWindow orderOut:nil];
	self.fullScreenWindow = nil;
}

#pragma mark - 

@end

@implementation NSWindow (BINExtensionsAccessors)

#pragma mark - Property Accessors

static const char *livePreview_key = "livePreview_key";
- (BOOL)livePreview {
	return [objc_getAssociatedObject(self, livePreview_key) boolValue];
}
- (void)setLivePreview:(BOOL)livePreview {
	objc_setAssociatedObject(self, livePreview_key, @(livePreview), OBJC_ASSOCIATION_ASSIGN);
	
	if(livePreview)
		[self startLivePreviewTimer];
	else [self stopLivePreviewTimer];
}

static const char *useLayerShadow_key = "useLayerShadow_key";
- (BOOL)useLayerShadow {
	return [objc_getAssociatedObject(self, useLayerShadow_key) boolValue];
}
- (void)setUseLayerShadow:(BOOL)useLayerShadow {
	objc_setAssociatedObject(self, useLayerShadow_key, @(useLayerShadow), OBJC_ASSOCIATION_ASSIGN);
}

@dynamic disableConstrainedWindow;
static const char *disableConstrainedWindow_key = "disableConstrainedWindow_key";
- (BOOL)disableConstrainedWindow {
	return [objc_getAssociatedObject(self, disableConstrainedWindow_key) boolValue];
}
- (void)setDisableConstrainedWindow:(BOOL)disableConstrainedWindow {
	objc_setAssociatedObject(self, disableConstrainedWindow_key, @(disableConstrainedWindow), OBJC_ASSOCIATION_ASSIGN);
}

@dynamic fullScreenWindow;
static const char *fullScreenWindow_key = "fullScreenWindow_key";
- (NSWindow *)fullScreenWindow {
	return objc_getAssociatedObject(self, fullScreenWindow_key);
}
- (void)setFullScreenWindow:(NSWindow *)fullScreenWindow {
	objc_setAssociatedObject(self, fullScreenWindow_key, fullScreenWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@dynamic windowRepresentationLayer;
static const char *windowRepresentationLayer_key = "windowRepresentationLayer_key";
- (CALayer *)windowRepresentationLayer {
	return objc_getAssociatedObject(self, windowRepresentationLayer_key);
}
- (void)setWindowRepresentationLayer:(CALayer *)windowRepresentationLayer {
	objc_setAssociatedObject(self, windowRepresentationLayer_key, windowRepresentationLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@dynamic livePreviewTimer;
static const char *livePreviewTimer_key = "livePreviewTimer_key";
- (CVDisplayLinkRef)livePreviewTimer {
	return [objc_getAssociatedObject(self, livePreviewTimer_key) pointerValue];
}
- (void)setLivePreviewTimer:(CVDisplayLinkRef)livePreviewTimer {
	objc_setAssociatedObject(self, livePreviewTimer_key, [NSValue valueWithPointer:livePreviewTimer], OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - 

@end

@implementation BINAnimatableWindowContentView

#pragma mark - Layer Hosting

// Create a layer-hosting view to allow safe sublayer heirarchies.
- (id)initWithFrame:(NSRect)frameRect {
	if ((self = [super initWithFrame:frameRect])) {
		self.layer = [CALayer layer];
		self.wantsLayer = YES;
		self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawNever;
	}
	return self;
}

#pragma mark -

@end