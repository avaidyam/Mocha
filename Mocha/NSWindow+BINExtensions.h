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

#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>

// Convenience enum for ordered and congregated window styles.
typedef enum NSWindowStyle : NSUInteger {
    NSWindowStyleBorderless		= NSBorderlessWindowMask,
    NSWindowStyleTitled			= NSTitledWindowMask,
    NSWindowStyleClosable		= NSClosableWindowMask,
    NSWindowStyleMiniaturizable	= NSMiniaturizableWindowMask,
    NSWindowStyleResizable		= NSResizableWindowMask,
    NSWindowStyleTextured		= NSTexturedBackgroundWindowMask,
    NSWindowStyleUnified		= NSUnifiedTitleAndToolbarWindowMask,
    NSWindowStyleFullScreen		= NSFullScreenWindowMask
} NSWindowStyle;

// Allows for an extremely flexible manipulation of a static
// representation of the window. Since it uses a visual representation
// of the window, the window cannot be interacted with while a transform
// is applied, nor is it automatically updated to reflect the window's state.
// 
// FIXME: Apply different shadows based on window type (window, panel, etc.).
// 
@interface NSWindow (BINExtensions)

// This layer can be transformed as much as desired. As soon as the
// property is first used an image representation of the current window's
// state will be grabbed and used for the layer's contents. Because it
// is a static image, it will not reflect the state of the window if it
// changes. The .livePreview property allows per-frame representation
// updates. This layer is shadowPath optimized. If the layer's frame is
// modified, the shadowPath must be manually updated to reflect the change.
@property (nonatomic, assign, readonly) CALayer *layer;

// Returns YES if transforming window layer is in use.
@property (nonatomic, readonly) BOOL layerInUse;

// Enable or disable use of a window shadow.
@property (nonatomic, assign) BOOL useLayerShadow;

// The representation layer will be updated per-frame with a refreshed
// window snapshot if this property is set to YES. Caution: this causes
// an extremely sharp increase in graphics and processor usage.
@property (nonatomic, assign) BOOL livePreview;

// Convenience initializers.
- (instancetype)initWithContentRect:(NSRect)contentRect;
- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyle)style;
- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyle)style
							 screen:(NSScreen *)screen;

// Destroys the layer and fake window. Only necessary for use if the
// layer is animated manually. If the convenience methods are used
// below, calling this is not necessary as it is done automatically.
- (void)destroyTransformingWindow;

// Order a window out with an animation. The `animations` block is
// wrapped in a `CATransaction`, so implicit animations will be enabled.
// Pass in nil for the timing function to default to ease-in-out.
- (void)orderOutWithDuration:(CFTimeInterval)duration
					  timing:(CAMediaTimingFunction *)timingFunction
				  animations:(void (^)(CALayer *windowLayer))animations;

// Order a window out with an animation, automatically cleaning up after completion.
// The delegate of the animation will be changed.
- (void)orderOutWithAnimation:(CAAnimation *)animation;

// Make a window key and visible with an animation. The setup block will
// be performed with implicit animations disabled, so it is an ideal time
// to set the initial state for your animation. Pass in nil for the timing
// function to default to ease-in-out.
- (void)makeKeyAndOrderFrontWithDuration:(CFTimeInterval)duration
								  timing:(CAMediaTimingFunction *)timingFunction
								   setup:(void (^)(CALayer *windowLayer))setup
							  animations:(void (^)(CALayer *layer))animations;

// Make a window key and visible with an animation, automatically
// cleaning up after completion. The delegate of the animation will be changed.
// The opacity of the layer will be set to the passed in opacity before it is shown.
- (void)makeKeyAndOrderFrontWithAnimation:(CAAnimation *)animation
						   initialOpacity:(CGFloat)opacity;

// Sets the window to the frame specified using a layer The animation
// behavior is the same as NSWindow's full-screen animation, which
// cross-fades between the initial and final state images.
- (void)setFrame:(NSRect)frameRect
	withDuration:(CFTimeInterval)duration
		  timing:(CAMediaTimingFunction *)timing;

@end

// Convenience additions. The following non-deprecated methods have been added
// to rectify the return type or arguments of a pre-existing method.
@interface NSWindow (BINAdditions)
- (NSView *)contentView;
- (void)setFrame:(NSRect)frameRect;
@end

// Convenience deprecations. The following methods have been deprecated for one
// of the following reasons: Apple has informally deprecated the method, the method
// contains one or more components unadvisable for usage, or documentation states
// the method should only be used in rare or conditional situations.
@interface NSWindow (BINDeprecations)
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle
backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag DEPRECATED_ATTRIBUTE;
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle
backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen DEPRECATED_ATTRIBUTE;
- (void)setFrame:(NSRect)frameRect display:(BOOL)displayFlag animate:(BOOL)animateFlag DEPRECATED_ATTRIBUTE;
- (NSPoint)convertBaseToScreen:(NSPoint)aPoint DEPRECATED_ATTRIBUTE;
- (NSPoint)convertScreenToBase:(NSPoint)aPoint DEPRECATED_ATTRIBUTE;
- (void)setBackingType:(NSBackingStoreType)bufferingType DEPRECATED_ATTRIBUTE;
- (NSBackingStoreType)backingType DEPRECATED_ATTRIBUTE;
- (void)setPreferredBackingLocation:(NSWindowBackingLocation)backingLocation DEPRECATED_ATTRIBUTE;
- (NSWindowBackingLocation)preferredBackingLocation DEPRECATED_ATTRIBUTE;
- (NSWindowBackingLocation)backingLocation DEPRECATED_ATTRIBUTE;
- (NSWindow *)initWithWindowRef:(void *)windowRef DEPRECATED_ATTRIBUTE;
- (void *)windowRef NS_RETURNS_INNER_POINTER DEPRECATED_ATTRIBUTE;
@end
