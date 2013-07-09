/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import "NSTextView+BINExtensions.h"
#import <AppKit/NSGraphicsContext.h>
#import <AppKit/NSAnimationContext.h>
#import <QuartzCore/QuartzCore.h>
#import "NSColor+BINExtensions.h"
#import <objc/runtime.h>

#define BINCursorColor [NSColor colorWithDeviceRed:0.125 green:0.627 blue:0.918 alpha:1.000]

@interface NSTextView (BINExtensionsPrivate)

@property (nonatomic, strong) NSView *caret;

@property (nonatomic, assign) BOOL flashInsertionPoint;

@property (nonatomic, assign) NSRange previousCaretRange;
@property (nonatomic, assign) CGFloat insertionPointWidth;

@end

@implementation NSTextView (BINExtensionsPrivate)

@dynamic caret;
static const char *caret_key = "caret_key";
- (NSView *)caret {
	return objc_getAssociatedObject(self, caret_key);
}
- (void)setCaret:(NSView *)caret {
	objc_setAssociatedObject(self, caret_key, caret, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@dynamic previousCaretRange;
static const char *previousCaretRange_key = "previousCaretRange_key";
- (NSRange)previousCaretRange {
	return [objc_getAssociatedObject(self, previousCaretRange_key) rangeValue];
}
- (void)setPreviousCaretRange:(NSRange)previousCaretRange {
	objc_setAssociatedObject(self, previousCaretRange_key, [NSValue valueWithRange:previousCaretRange], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@dynamic flashInsertionPoint;
static const char *flashInsertionPoint_key = "flashInsertionPoint_key";
- (BOOL)flashInsertionPoint {
	return [objc_getAssociatedObject(self, flashInsertionPoint_key) boolValue];
}
- (void)setFlashInsertionPoint:(BOOL)flashInsertionPoint {
	objc_setAssociatedObject(self, flashInsertionPoint_key, @(flashInsertionPoint), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@dynamic insertionPointWidth;
static const char *insertionPointWidth_key = "insertionPointWidth_key";
- (CGFloat)insertionPointWidth {
	return [objc_getAssociatedObject(self, insertionPointWidth_key) floatValue];
}
- (void)setInsertionPointWidth:(CGFloat)insertionPointWidth {
	objc_setAssociatedObject(self, insertionPointWidth_key, @(insertionPointWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation NSTextView (BINExtensions)

@dynamic flashInsertionPoint;
@dynamic insertionPointWidth;
@dynamic insertionPointColor;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
+ (void)load {
	[self attemptToSwapInstanceMethod:@selector(drawRect:)
						   withPrefix:MochaPrefix];
	[self attemptToSwapInstanceMethod:@selector(initWithFrame:)
						   withPrefix:MochaPrefix];
	
	if(MochaPlatform10_8) {
		[self attemptToSwapInstanceMethod:@selector(drawInsertionPointInRect:color:turnedOn:)
							   withPrefix:MochaPrefix];
		[self attemptToSwapInstanceMethod:@selector(_drawInsertionPointInRect:color:)
							   withPrefix:MochaPrefix];
	}
}
#pragma clang diagnostic pop

- (id)initWithFrame_BIN:(NSRect)frame {
	if((self = [self initWithFrame_BIN:frame])) {
		self.insertionPointWidth = 2.0f;
		self.insertionPointColor = BINCursorColor;
	}
	return self;
}

- (void)BIN_drawRect:(NSRect)dirtyRect {
	if(self.opaqueAncestor == nil) {
		CGContextRef context = [NSGraphicsContext currentContext].graphicsPort;
		CGContextSetAllowsAntialiasing(context, YES);
		CGContextSetAllowsFontSmoothing(context, YES);
		CGContextSetAllowsFontSubpixelPositioning(context, YES);
		CGContextSetAllowsFontSubpixelQuantization(context, YES);
		CGContextSetShouldAntialias(context, YES);
		CGContextSetShouldSmoothFonts(context, NO);
		CGContextSetShouldSubpixelPositionFonts(context, YES);
		CGContextSetShouldSubpixelQuantizeFonts(context, YES);
	}
	
	self.frame = [self.superview backingAlignedRect:self.frame options:NSAlignAllEdgesNearest];
	[self BIN_drawRect:dirtyRect];
}

- (void)BIN_assureCaretDisplay {
	if(self.caret == nil) {
		self.caret = [NSView new];
		self.caret.wantsLayer = YES;
		self.caret.layer.backgroundColor = BINCursorColor.CGColor;
		[self addSubview:self.caret];
	}
	
	// The 10.8+ NSTextLayer invalidates sublayers automatically; prevent that.
	if(self.layer != nil)
		[self.layer addSublayer:self.caret.layer];
	self.caret.layer.backgroundColor = self.insertionPointColor.CGColor;
}

- (void)BIN_relocateCaretToFrame:(NSRect)frame {
	frame.size.width = self.insertionPointWidth;
	self.caret.frame = frame;
}

- (void)BIN_adjustCaret:(BOOL)animate hidden:(BOOL)hidden opacity:(CGFloat)opacity {
	self.caret.hidden = hidden;
	
	if(animate) {
		[[NSAnimationContext currentContext] setDuration:0.1f];
		[self.caret.animator setAlphaValue:opacity];
	} else self.caret.alphaValue = opacity;
}

/*- (void)BIN_viewWillMoveToWindow:(NSWindow *)window {
	[self BIN_viewWillMoveToWindow:window];
	
	if(window.isKeyWindow) {
		[self addSubview:cursor];
	} else {
		[cursor removeFromSuperview];
	}
}//*/

/*static CAAnimation *BINFlashingCursorAnimation() {
	CAKeyframeAnimation *flash = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
	flash.values = @[@1.0f, @1.0f, @1.0f, @1.0f, @1.0,
					 @0.5f, @0.0f, @0.0f, @0.0f, @1.0];
	flash.repeatCount = HUGE_VALF;
	flash.duration = 1.0f;
	return flash;
}//*/

- (void)BIN_drawInsertionPointInRect:(NSRect)frame color:(NSColor *)color turnedOn:(BOOL)turnedOn {
	[self BIN_assureCaretDisplay];
	[self BIN_relocateCaretToFrame:frame];
	
	if(turnedOn) {
		if(self.previousCaretRange.location == [self.selectedRanges[0] rangeValue].location) {
			[self BIN_adjustCaret:YES hidden:NO opacity:1.0f];
		} else {
			[self BIN_adjustCaret:NO hidden:NO opacity:1.0f];
		}
	} else {
		if([self.selectedRanges[0] rangeValue].length == 0) {
			[self BIN_adjustCaret:YES hidden:NO opacity:0.0f];
		} else {
			[self BIN_adjustCaret:NO hidden:YES opacity:1.0f];
		}
	}
	
	self.previousCaretRange = [self.selectedRanges[0] rangeValue];
}

- (void)BIN__drawInsertionPointInRect:(NSRect)frame color:(NSColor *)color {
	[self BIN_assureCaretDisplay];
	
	if(frame.origin.x != self.caret.frame.origin.x)
		[self BIN_adjustCaret:YES hidden:NO opacity:1.0f];
	
	[self BIN_relocateCaretToFrame:frame];
	self.previousCaretRange = [self.selectedRanges[0] rangeValue];
}

@end
