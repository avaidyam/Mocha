#import "NSTabView+BINExtensions.h"
#import <objc/runtime.h>

@implementation NSTabView (BINExtensions)

+ (void)load {
	NSError *error = nil;
	if(![NSTabView exchangeInstanceMethod:@selector(selectTabViewItem:)
							   withMethod:@selector(BIN_selectTabViewItem:)
									error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
	
	error = nil;
	if(![NSTabView exchangeInstanceMethod:@selector(drawRect:)
							   withMethod:@selector(BIN_drawRect:)
									error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
}

@dynamic animates;
static const char *animates_key = "animates_key";
- (BOOL)animates {
	return [objc_getAssociatedObject(self, animates_key) boolValue];
}
- (void)setAnimates:(BOOL)animates {
	objc_setAssociatedObject(self, animates_key, @(animates), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@dynamic gestureNavigation;
static const char *gestureNavigation_key = "gestureNavigation_key";
- (BOOL)gestureNavigation {
	return [objc_getAssociatedObject(self, gestureNavigation_key) boolValue];
}
- (void)setGestureNavigation:(BOOL)gestureNavigation {
	objc_setAssociatedObject(self, gestureNavigation_key, @(gestureNavigation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@dynamic orientation;
static const char *orientation_key = "orientation_key";
- (NSTabViewOrientation)orientation {
	return [objc_getAssociatedObject(self, orientation_key) unsignedIntegerValue];
}
- (void)setOrientation:(NSTabViewOrientation)orientation {
	objc_setAssociatedObject(self, orientation_key, @(orientation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@dynamic transitionStyle;
static const char *transitionStyle_key = "transitionStyle_key";
- (NSTabViewTransitionStyle)transitionStyle {
	return [objc_getAssociatedObject(self, transitionStyle_key) unsignedIntegerValue];
}
- (void)setTransitionStyle:(NSTabViewTransitionStyle)transitionStyle {
	objc_setAssociatedObject(self, transitionStyle_key, @(transitionStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@dynamic animationDuration;
static const char *animationDuration_key = "animationDuration_key";
- (NSTimeInterval)animationDuration {
	return [objc_getAssociatedObject(self, animationDuration_key) doubleValue];
}
- (void)setAnimationDuration:(NSTimeInterval)animationDuration {
	objc_setAssociatedObject(self, animationDuration_key, @(animationDuration), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@dynamic timingFunction;
static const char *timingFunction_key = "timingFunction_key";
- (CAMediaTimingFunction *)timingFunction {
	return objc_getAssociatedObject(self, timingFunction_key);
}
- (void)setTimingFunction:(CAMediaTimingFunction *)timingFunction {
	objc_setAssociatedObject(self, timingFunction_key, timingFunction, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)timingFunctionName {
	return @"";
}
- (void)setTimingFunctionName:(NSString *)timingFunctionName {
	self.timingFunction = [CAMediaTimingFunction functionWithName:timingFunctionName];
}

@dynamic applyFadeAnimation;
static const char *applyFadeAnimation_key = "applyFadeAnimation_key";
- (BOOL)applyFadeAnimation {
	return [objc_getAssociatedObject(self, applyFadeAnimation_key) boolValue];
}
- (void)setApplyFadeAnimation:(BOOL)applyFadeAnimation {
	objc_setAssociatedObject(self, applyFadeAnimation_key, @(applyFadeAnimation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)initWithFrame_BIN:(NSRect)frameRect {
	if((self = [self initWithFrame_BIN:frameRect])) {
		self.acceptsTouchEvents = YES;
	}
	return self;
}

- (id)initWithCoder_BIN:(NSCoder *)aDecoder {
	if((self = [self initWithCoder_BIN:aDecoder])) {
		self.acceptsTouchEvents = YES;
	}
	return self;
}

- (void)BIN_selectTabViewItem:(NSTabViewItem *)tabViewItem {
	if([self.selectedTabViewItem isEqual:tabViewItem])
		return;
	if([self indexOfTabViewItem:tabViewItem] == NSNotFound)
		return;
	if(!self.animates)
		return [self BIN_selectTabViewItem:tabViewItem];
	
	id delegate = self.delegate;
	self.delegate = nil;
	if([delegate respondsToSelector:@selector(tabView:shouldSelectTabViewItem:)] &&
	   ![delegate tabView:self shouldSelectTabViewItem:tabViewItem])
		return;
	if([delegate respondsToSelector:@selector(tabView:willSelectTabViewItem:)])
		[delegate tabView:self willSelectTabViewItem:tabViewItem];
	
	BOOL increasing = ([self indexOfTabViewItem:self.selectedTabViewItem] > [self indexOfTabViewItem:tabViewItem]);
	BOOL leftRight = self.orientation == NSTabViewOrientationLeftToRight ||
					 self.orientation == NSTabViewOrientationRightToLeft;
	BOOL reversed = self.orientation == NSTabViewOrientationRightToLeft ||
					self.orientation == NSTabViewOrientationBottomToTop;
	CGFloat direction = (increasing ? -1.0f : 1.0f) * (reversed ? -1.0f : 1.0f);
	
	NSView *host = [self.selectedTabViewItem.view superview];
	[tabViewItem.view setFrame:self.contentRect];
	NSView *removeRepresentation = [self.selectedTabViewItem.view layerRepresentation];
	NSView *addRepresentation = [tabViewItem.view layerRepresentation];
	
	NSRect frame = addRepresentation.frame;
	if(leftRight)
		frame.origin.x += addRepresentation.bounds.size.width * direction;
	else frame.origin.y += addRepresentation.bounds.size.height * direction;
	addRepresentation.frame = frame;
	if(self.applyFadeAnimation)
		addRepresentation.alphaValue = 0.0f;
	
	[host addSubview:removeRepresentation];
	[host addSubview:addRepresentation];
	
	[self.selectedTabViewItem.view removeFromSuperview];
	[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
		if(self.animationDuration > 0.0f)
			context.duration = self.animationDuration;
		if(self.timingFunction != nil)
			context.timingFunction = self.timingFunction;
		
		NSRect animated = removeRepresentation.frame;
		if(leftRight)
			animated.origin.x -= removeRepresentation.bounds.size.width * direction;
		else animated.origin.y -= removeRepresentation.bounds.size.height * direction;
		
		[removeRepresentation.animator setFrame:animated];
		[addRepresentation.animator setFrame:self.contentRect];
		
		if(self.applyFadeAnimation) {
			[removeRepresentation.animator setAlphaValue:0.0f];
			[addRepresentation.animator setAlphaValue:1.0f];
		}
	} completionHandler:^{
		if([host.subviews indexOfObjectIdenticalTo:tabViewItem.view] == NSNotFound)
			[host addSubview:tabViewItem.view];
		
		[removeRepresentation removeFromSuperview];
		[addRepresentation removeFromSuperview];
		
		// Should not call delegate methods or replace subviews!
		[self BIN_selectTabViewItem:tabViewItem];
		
		if([delegate respondsToSelector:@selector(tabView:didSelectTabViewItem:)])
			[delegate tabView:self didSelectTabViewItem:tabViewItem];
		self.delegate = delegate;
	}];
}

- (void)BIN_drawRect:(NSRect)dirtyRect {
	if(self.tabViewType != NSNoTabsLineBorder)
		return [self BIN_drawRect:dirtyRect];
	
	CGContextClearRect([[NSGraphicsContext currentContext] graphicsPort], self.bounds);
	NSGradient *gradient = [[NSGradient alloc] initWithColors:@[[NSColor colorWithCalibratedWhite:0.95 alpha:0.0],
																[NSColor colorWithCalibratedWhite:0.90 alpha:0.0]]];
	[gradient drawInRect:self.bounds angle:90.0f];
}

- (BOOL)wantsScrollEventsForSwipeTrackingOnAxis:(NSEventGestureAxis)axis {
	BOOL horizontalOrientation = (self.orientation == NSTabViewOrientationLeftToRight ||
								  self.orientation == NSTabViewOrientationRightToLeft);
	if(axis == NSEventGestureAxisHorizontal && horizontalOrientation)
		return YES;
	else if(axis == NSEventGestureAxisVertical && !horizontalOrientation)
		return YES;
	return NO;
}

- (void)scrollWheel:(NSEvent *)event {
	BOOL horizontalEvent = (fabsf(event.scrollingDeltaX) >= fabsf(event.scrollingDeltaY));
	BOOL horizontalOrientation = (self.orientation == NSTabViewOrientationLeftToRight ||
								  self.orientation == NSTabViewOrientationRightToLeft);
	BOOL reversed = (self.orientation == NSTabViewOrientationRightToLeft ||
					 self.orientation == NSTabViewOrientationBottomToTop);
    if(![NSEvent isSwipeTrackingFromScrollEventsEnabled] || !self.gestureNavigation)
		return;
	if(event.type != NSScrollWheel || event.phase != NSEventPhaseBegan)
		return;
	if((horizontalEvent && !horizontalOrientation) || (!horizontalEvent && horizontalOrientation))
		return;
	
	id delegate = self.delegate;
	self.delegate = nil;
	NSView *host = [self.selectedTabViewItem.view superview];
	NSRect hostRect = [self.selectedTabViewItem.view frame];
	
	NSInteger currentIndex = [self indexOfTabViewItem:self.selectedTabViewItem] + 1;
    CGFloat thresholdMin = (reversed ? currentIndex - 1 : self.tabViewItems.count - currentIndex);
    CGFloat thresholdMax = (reversed ? self.tabViewItems.count - currentIndex : currentIndex - 1);
	//NSLog(@"min %f curr %ld max %f", thresholdMin, currentIndex, thresholdMax);
	
	__block NSTabViewItem *tabViewItem = nil;
    __block BOOL animationCancelled = NO;
	__block NSView *addRepresentation = nil;
	__block NSView *removeRepresentation = nil;
	
    [event trackSwipeEventWithOptions:NSEventSwipeTrackingLockDirection | NSEventSwipeTrackingClampGestureAmount
			 dampenAmountThresholdMin:-thresholdMin max:thresholdMax
                         usingHandler:^(CGFloat gestureAmount, NSEventPhase phase, BOOL complete, BOOL *stop)
	{
		if(animationCancelled) {
			*stop = YES;
			complete = YES;
			goto completed;
		}
		
		CGFloat contentWidth = hostRect.size.width;
		CGFloat gestureLength = (contentWidth * gestureAmount) * (reversed ? -1.0f : 1.0f);
		CGFloat newContentWidth = contentWidth * (gestureAmount < 0.0f ? 1 : -1) * (reversed ? -1.0f : 1.0f);
		
		if(phase == NSEventPhaseBegan) {
			NSInteger nextIndex = (currentIndex - 1) + (gestureAmount < 0.0f ? 1 : -1);
			if(nextIndex >= 0 && nextIndex < self.numberOfTabViewItems)
				tabViewItem = [self tabViewItemAtIndex:nextIndex];
			
			if([delegate respondsToSelector:@selector(tabView:shouldSelectTabViewItem:)] &&
			   ![delegate tabView:self shouldSelectTabViewItem:tabViewItem]) {
				*stop = YES;
				return;
			}
			
			if([delegate respondsToSelector:@selector(tabView:willSelectTabViewItem:)])
				[delegate tabView:self willSelectTabViewItem:tabViewItem];
			[tabViewItem.view setFrame:hostRect];
			
			removeRepresentation = [self.selectedTabViewItem.view layerRepresentation];
			addRepresentation = [tabViewItem.view layerRepresentation];
			
			NSRect frame = addRepresentation.frame;
			if(horizontalOrientation)
				frame.origin.x += contentWidth + hostRect.origin.x;
			else frame.origin.y += contentWidth + hostRect.origin.y;
			addRepresentation.frame = frame;
			if(self.applyFadeAnimation)
				addRepresentation.alphaValue = 0.0f;
			
			[host addSubview:removeRepresentation];
			[host addSubview:addRepresentation];
			[self.selectedTabViewItem.view removeFromSuperview];
		}
		
		NSRect updated = removeRepresentation.frame;
		if(horizontalOrientation)
			updated.origin.x = gestureLength + hostRect.origin.x;
		else updated.origin.y = gestureLength + hostRect.origin.y;
		removeRepresentation.frame = updated;
		
		updated = addRepresentation.frame;
		if(horizontalOrientation)
			updated.origin.x = newContentWidth + gestureLength + hostRect.origin.x;
		else updated.origin.y = newContentWidth + gestureLength + hostRect.origin.y;
		addRepresentation.frame = updated;
		
		if(self.applyFadeAnimation) {
			[removeRepresentation setAlphaValue:1.0f - fabsf(gestureAmount)];
			[addRepresentation setAlphaValue:fabsf(gestureAmount)];
		}
		
	completed:
		if(complete) {
			BOOL noTabViewItem = (tabViewItem == nil);
			tabViewItem = tabViewItem ?: self.selectedTabViewItem;
			if([host.subviews indexOfObjectIdenticalTo:tabViewItem.view] == NSNotFound)
				[host addSubview:tabViewItem.view];
			
			[removeRepresentation removeFromSuperview];
			[addRepresentation removeFromSuperview];
			
			// Should not call delegate methods or replace subviews!
			[self BIN_selectTabViewItem:tabViewItem];
			
			if(!noTabViewItem && [delegate respondsToSelector:@selector(tabView:didSelectTabViewItem:)])
				[delegate tabView:self didSelectTabViewItem:tabViewItem];
			self.delegate = delegate;
		}
	}];
}

@end