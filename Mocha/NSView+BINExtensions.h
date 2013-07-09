/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <AppKit/NSView.h>

/*@interface NSView (BINExtensionsLayer)

// A background color for the view, or nil if none has been set. This property
// is not the same as CALayer.backgroundColor, but does manipulate it.
@property (nonatomic, strong) NSColor *backgroundColor;

// Whether the view's content and subviews clip to its bounds. This property
// is not the same as CALayer.masksToBounds, but does manipulate it. Defaults to NO.
@property (nonatomic, assign) BOOL clipsToBounds;

// The view's affine transform.
@property (nonatomic, strong) NSAffineTransform *transform;

// A radius used to draw rounded corners for the view's background. This property
// is not the same as CALayer.cornerRadius, but does manipulate it.
// Typically, you will want to enable clipsToBounds when setting this property
// to a non-zero value. Defaults to 0.
@property (nonatomic, assign) CGFloat cornerRadius;

// Whether the graphics context for the view's drawing should be cleared to
// transparent black in RBLView's implementation of -drawRect:. Defaults to YES.
@property (nonatomic, assign) BOOL clearsContextBeforeDrawing;

// Whether the view can be interacted with.
@property(nonatomic, assign, getter = isUserInteractionEnabled) BOOL userInteractionEnabled;

// Determines when the backing layer's contents should be redrawn.
//
// If -drawRect: is not overridden, this defaults to
// NSViewLayerContentsRedrawNever. If -drawRect: is overridden, this defaults to
// NSViewLayerContentsRedrawDuringViewResize.
//
// For better performance, subclasses should set the contentsCenter property of
// the backing layer to support scaling, and then change the value of this
// property to NSViewLayerContentsRedrawBeforeViewResize or
// NSViewLayerContentsRedrawOnSetNeedsDisplay.

// Return a custom class for your backing layer.
// This is used if the view is layer-backed or layer-hosted.
+ (Class)layerClass;

// Subclasses may override this method to redraw the given rectangle. Any
// override of this method should invoke super.
// - (void)drawRect:(NSRect)rect;

// Subclasses may override these methods, but must call the super method.
- (void)viewDidMoveToWindow;
- (void)viewDidMoveToSuperview;

@end
//*/

@interface NSView (BINExtensionsLayout)

//- (void)layoutSubviews;

@end

// Adds setters to some properties for convenience.
@interface NSView (BINProperties)

@property (nonatomic, assign) CGPoint center;
//@property (nonatomic, assign) NSInteger tag;
//@property (nonatomic, assign) BOOL needsPanelToBecomeKey;
//@property (nonatomic, assign) BOOL mouseDownCanMoveWindow;
//@property (nonatomic, assign, getter = isOpaque) BOOL opaque;
//@property (nonatomic, assign, getter = isFlipped) BOOL flipped;

@end

@interface NSView (BINExtensions)

@property (nonatomic, readonly) NSImage *snapshot;
@property (nonatomic, readonly) NSView *layerRepresentation;

- (void)scrollPoint:(NSPoint)point animated:(BOOL)animated;
- (void)scrollPoint:(NSPoint)point animated:(BOOL)animated
  completionHandler:(dispatch_block_t)handler;

@end

// Methods in NSView that have been deprecated either informally by Apple,
// or replaced by better, newer (and forward compatible) methods, or methods
// that do not need to be used with the above extensions.
@interface NSView (BINDeprecations)

- (void)getRectsBeingDrawn:(const NSRect **)rects count:(NSInteger *)count DEPRECATED_ATTRIBUTE;
- (BOOL)needsToDrawRect:(NSRect)aRect DEPRECATED_ATTRIBUTE;
- (BOOL)wantsDefaultClipping DEPRECATED_ATTRIBUTE;

- (void)setFrameOrigin:(NSPoint)newOrigin DEPRECATED_ATTRIBUTE;
- (void)setFrameSize:(NSSize)newSize DEPRECATED_ATTRIBUTE;
- (void)setBoundsOrigin:(NSPoint)newOrigin DEPRECATED_ATTRIBUTE;
- (void)setBoundsSize:(NSSize)newSize DEPRECATED_ATTRIBUTE;

- (void)setFrameRotation:(CGFloat)angle DEPRECATED_ATTRIBUTE;
- (CGFloat)frameRotation DEPRECATED_ATTRIBUTE;
- (void)setFrameCenterRotation:(CGFloat)angle DEPRECATED_ATTRIBUTE;
- (CGFloat)frameCenterRotation DEPRECATED_ATTRIBUTE;
- (void)setBoundsRotation:(CGFloat)angle DEPRECATED_ATTRIBUTE;
- (CGFloat)boundsRotation DEPRECATED_ATTRIBUTE;
- (void)translateOriginToPoint:(NSPoint)translation DEPRECATED_ATTRIBUTE;
- (void)scaleUnitSquareToSize:(NSSize)newUnitSize DEPRECATED_ATTRIBUTE;
- (void)rotateByAngle:(CGFloat)angle DEPRECATED_ATTRIBUTE;
- (BOOL)isRotatedFromBase DEPRECATED_ATTRIBUTE;
- (BOOL)isRotatedOrScaledFromBase DEPRECATED_ATTRIBUTE;

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize DEPRECATED_ATTRIBUTE;
- (void)resizeWithOldSuperviewSize:(NSSize)oldSize DEPRECATED_ATTRIBUTE;
- (void)setAutoresizesSubviews:(BOOL)flag DEPRECATED_ATTRIBUTE;
- (BOOL)autoresizesSubviews DEPRECATED_ATTRIBUTE;

- (void)sortSubviewsUsingFunction:(NSComparisonResult (*)(id, id, void *))compare
context:(void *)context DEPRECATED_ATTRIBUTE;
- (NSRect)centerScanRect:(NSRect)aRect DEPRECATED_ATTRIBUTE;
- (BOOL)shouldDrawColor DEPRECATED_ATTRIBUTE;

- (NSInteger)gState DEPRECATED_ATTRIBUTE;
- (void)allocateGState DEPRECATED_ATTRIBUTE;
- (oneway void)releaseGState DEPRECATED_ATTRIBUTE;
- (void)setUpGState DEPRECATED_ATTRIBUTE;
- (void)renewGState DEPRECATED_ATTRIBUTE;
- (BOOL)canDraw DEPRECATED_ATTRIBUTE;

- (void)addCursorRect:(NSRect)aRect cursor:(NSCursor *)anObj DEPRECATED_ATTRIBUTE;
- (void)removeCursorRect:(NSRect)aRect cursor:(NSCursor *)anObj DEPRECATED_ATTRIBUTE;
- (void)discardCursorRects DEPRECATED_ATTRIBUTE;
- (void)resetCursorRects DEPRECATED_ATTRIBUTE;
- (NSTrackingRectTag)addTrackingRect:(NSRect)aRect owner:(id)anObject
userData:(void *)data assumeInside:(BOOL)flag DEPRECATED_ATTRIBUTE;
- (void)removeTrackingRect:(NSTrackingRectTag)tag DEPRECATED_ATTRIBUTE;

- (void)setToolTip:(NSString *)string DEPRECATED_ATTRIBUTE;
- (NSString *)toolTip DEPRECATED_ATTRIBUTE;
- (NSToolTipTag)addToolTipRect:(NSRect)aRect owner:(id)anObject userData:(void *)data DEPRECATED_ATTRIBUTE;
- (void)removeToolTip:(NSToolTipTag)tag DEPRECATED_ATTRIBUTE;
- (void)removeAllToolTips DEPRECATED_ATTRIBUTE;

- (void)displayIfNeededIgnoringOpacity DEPRECATED_ATTRIBUTE;;
- (void)displayRect:(NSRect)rect DEPRECATED_ATTRIBUTE;;
- (void)displayIfNeededInRect:(NSRect)rect DEPRECATED_ATTRIBUTE;;
- (void)displayRectIgnoringOpacity:(NSRect)rect DEPRECATED_ATTRIBUTE;;
- (void)displayIfNeededInRectIgnoringOpacity:(NSRect)rect DEPRECATED_ATTRIBUTE;;
- (void)setNeedsDisplayInRect:(NSRect)invalidRect DEPRECATED_ATTRIBUTE;
- (BOOL)lockFocusIfCanDraw DEPRECATED_ATTRIBUTE;
- (BOOL)lockFocusIfCanDrawInContext:(NSGraphicsContext *)context DEPRECATED_ATTRIBUTE;
- (void)displayRectIgnoringOpacity:(NSRect)aRect inContext:(NSGraphicsContext *)context DEPRECATED_ATTRIBUTE;
- (void)translateRectsNeedingDisplayInRect:(NSRect)clipRect by:(NSSize)delta DEPRECATED_ATTRIBUTE;

@end
