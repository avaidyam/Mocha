/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import "NSClipView+BINExtensions.h"
#import "NSObject+BINExtensions.h"
#import <AppKit/NSScrollView.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSScreen.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSAnimationContext.h>
#import <QuartzCore/CVDisplayLink.h>
#import <QuartzCore/CAScrollLayer.h>
#import "CATransaction+BINExtensions.h"
#import <objc/runtime.h>

@interface NSScrollView (BINExtensions)

/* Allow the user to magnify the scrollview. Note: this does not prevent the developer from manually adjusting the magnification value. If magnification exceeds either the maximum or minimum limits for magnification, and allowsMagnification is YES, the scroll view temporarily animates the content magnification just past those limits before returning to them. The default value is NO.
 */
@property BOOL allowsMagnification NS_AVAILABLE_MAC(10_8);

/* This value determines how much the content is currently scaled. To animate the magnification, use the object's animator. The default value is 1.0 */
@property CGFloat magnification NS_AVAILABLE_MAC(10_8);

/* This value determines how large the content can be magnified. It must be greater than or equal to the minimum magnification. The default value is 4.0.
 */
@property CGFloat maxMagnification NS_AVAILABLE_MAC(10_8);

/* This value determines how small the content can be magnified. The default value is 0.25.
 */
@property CGFloat minMagnification NS_AVAILABLE_MAC(10_8);

/* Magnify content view proportionally such that the entire rect (in content view space) fits centered in the scroll view. The resulting magnification value is clipped to the minMagnification and maxMagnification values. To animate the magnification, use the object's animator.
 */
- (void)BIN_magnifyToFitRect:(NSRect)rect;

/* Scale the content view such that the passed in point (in content view space) remains at the same screen location once the scaling is completed. The resulting magnification value is clipped to the minMagnification and maxMagnification values. To animate the magnification, use the object's animator.
 */
- (void)BIN_setMagnification:(CGFloat)magnification centeredAtPoint:(NSPoint)point;

@end

@implementation NSClipView (BINExtensions)

@dynamic layer;

+ (void)load {
	[self attemptToSwapInstanceMethod:@selector(initWithFrame:)
						   withPrefix:MochaPrefix];
	[self attemptToSwapInstanceMethod:@selector(initWithCoder:)
						   withPrefix:MochaPrefix];
}

- (id)initWithFrame_BIN:(NSRect)frame {
	self = [self initWithFrame_BIN:frame];
	if (self == nil) return nil;
	self.wantsLayer = YES;
	return self;
}

- (id)initWithCoder_BIN:(NSCoder *)aDecoder {
	self = [self initWithCoder_BIN:aDecoder];
	if (self == nil) return nil;
	self.wantsLayer = YES;
	return self;
}

- (CALayer *)makeBackingLayer {
	CAScrollLayer *layer = [CAScrollLayer layer];
	self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawNever;
	self.backgroundColor = [NSColor clearColor];
	self.opaque = NO;
	return layer;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (NSColor *)backgroundColor {
	return self.layer.backgroundColor ? [NSColor colorWithCGColor:self.layer.backgroundColor] : nil;
}

- (void)setBackgroundColor:(NSColor *)color {
	self.layer.backgroundColor = color.CGColor;
}

- (BOOL)isOpaque {
	return self.layer.opaque;
}

- (void)setOpaque:(BOOL)opaque {
	self.layer.opaque = opaque;
}
#pragma clang diagnostic pop

@end

#import <QuartzCore/QuartzCore.h>

@implementation NSScrollView (BINExtensions)

//- (void)awakeFromNib {
//	[self BIN_setMagnification:2.5];
	//[self setMagnification:1.0 centeredAtPoint:NSZeroPoint];
//}

- (void)BIN_magnifyToFitRect:(NSRect)rect {
//	NSRect visibleRect = self.documentVisibleRect;
}

- (void)BIN_setMagnification:(CGFloat)magnification {
	[self BIN_setMagnification:magnification
			   centeredAtPoint:NSMakePoint(NSMidX(self.frame), NSMidY(self.frame))];
}

- (void)BIN_setMagnification:(CGFloat)magnification centeredAtPoint:(NSPoint)point {
	self.magnification = magnification;
    NSClipView *clipView = self.contentView;
    NSRect clipViewBounds = clipView.bounds;
	
    float xFraction = (point.x - clipViewBounds.origin.x) / clipViewBounds.size.width;
    float yFraction = (point.y - clipViewBounds.origin.y) / clipViewBounds.size.height;
	
    clipViewBounds.size.width = clipView.frame.size.width / magnification;
    clipViewBounds.size.height = clipView.frame.size.height / magnification;
	
    clipViewBounds.origin.x = point.x - (xFraction * clipViewBounds.size.width);
    clipViewBounds.origin.y = point.y - (yFraction * clipViewBounds.size.height);
	
	[clipView.layer setBounds:clipViewBounds];
    [clipView setBounds:clipViewBounds];
}

@end
