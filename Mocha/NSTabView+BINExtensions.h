/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <AppKit/NSTabView.h>
#import <QuartzCore/CAMediaTimingFunction.h>
#import "NSObject+BINExtensions.h"
#import "NSView+BINExtensions.h"

typedef enum NSTabViewTransitionStyle : NSUInteger {
	NSTabViewTransitionStyleStackHistory DEPRECATED_ATTRIBUTE,
	NSTabViewTransitionStyleStackBook DEPRECATED_ATTRIBUTE,
	NSTabViewTransitionStyleHorizontalStrip
} NSTabViewTransitionStyle;

typedef enum NSTabViewOrientation : NSUInteger {
	NSTabViewOrientationLeftToRight,
	NSTabViewOrientationRightToLeft,
	NSTabViewOrientationTopToBottom,
	NSTabViewOrientationBottomToTop
} NSTabViewOrientation;

// FIXME: NSTabView cannot start new gesture when already within one.
// FIXME: Reversed orientation has improper threshold min/max.
// FIXME: NSNoTabsLineBorder drawing style does not render.
// TODO: Implement the stack-based transition styles.
// TODO: Implement runtime .dataSource page/tab generation.
@interface NSTabView (BINExtensions)

// Setting this property to YES enables animations when
// switching tabs, dictated by the orientation and transition
// style of the animations, and whether a fade is applied.
@property (nonatomic, assign) BOOL animates;

// This enables one-finger (for Magic Mice) and two-finger (for
// Magic Trackpad) gesture navigation to switch between tabs.
// The default value is NO, for backwards expectations.
@property (nonatomic, assign) BOOL gestureNavigation;

// The orientation in which the tabs should be layed out.
// The default value is NSTabViewOrientationLeftToRight.
@property (nonatomic, assign) NSTabViewOrientation orientation;

// The transition style used when transitioning from one tab to another.
// The default value is NSTabViewTransitionStyleHorizontalStrip.
@property (nonatomic, assign) NSTabViewTransitionStyle transitionStyle;

// The duration the animation should be presented in.
// Default value is 0.25f, and if 0.0f is set, the duration defaults.
@property (nonatomic, assign) NSTimeInterval animationDuration;

// The timing function the animation should be presented with.
// Default is kCAMediaTimingFunctionDefault.
// This can also be set using a runtime property `timingFunctionName`,
// but this is one-way, meaning that it cannot be read from.
@property (nonatomic, strong) CAMediaTimingFunction *timingFunction;

// Whether the animation should also fade the current tab out, and
// fade the new tab in with the set animationDuration.
// Defaults to NO.
@property (nonatomic, assign) BOOL applyFadeAnimation;

@end