/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import "NSPopover+BINExtensions.h"
#import <AppKit/NSView.h>
#import <objc/runtime.h>
#import "NSObject+BINExtensions.h"

@implementation NSPopover (BINExtensions)

+ (void)load {
	[self attemptToSwapInstanceMethod:@selector(showRelativeToRect:ofView:preferredEdge:)
						   withPrefix:MochaPrefix];
}

@dynamic relativePositioningView;
static const char *relativePositioningView_key = "relativePositioningView_key";
- (NSView *)relativePositioningView {
	return objc_getAssociatedObject(self, relativePositioningView_key);
}
- (void)setRelativePositioningView:(NSView *)relativePositioningView {
	objc_setAssociatedObject(self, relativePositioningView_key, relativePositioningView, OBJC_ASSOCIATION_ASSIGN);
}

@dynamic preferredEdge;
static const char *preferredEdge_key = "preferredEdge_key";
- (NSRectEdge)preferredEdge {
	return [objc_getAssociatedObject(self, preferredEdge_key) unsignedIntegerValue];
}
- (void)setPreferredEdge:(NSRectEdge)preferredEdge {
	objc_setAssociatedObject(self, preferredEdge_key, @(preferredEdge), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)show:(id)sender {
	NSRect positioning = self.positioningRect;
	if(NSEqualRects(positioning, NSZeroRect))
		positioning = self.relativePositioningView.bounds;
	
	[self showRelativeToRect:positioning
					  ofView:self.relativePositioningView
			   preferredEdge:self.preferredEdge];
}

- (void)toggle:(id)sender {
	if(self.shown)
		[self performClose:sender];
	else [self show:sender];
}

- (void)BIN_showRelativeToRect:(NSRect)positioningRect ofView:(NSView *)positioningView preferredEdge:(NSRectEdge)preferredEdge {
	self.preferredEdge = preferredEdge;
	self.relativePositioningView = positioningView;
	[self BIN_showRelativeToRect:positioningRect ofView:positioningView preferredEdge:preferredEdge];
}

@end
