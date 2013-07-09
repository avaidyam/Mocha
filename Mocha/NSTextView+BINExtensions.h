/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <AppKit/NSTextView.h>
#import "NSObject+BINExtensions.h"

// Allows NSTextView to draw properly when layer-backed, by forcing pixel
// alignment, and also enables iOS style flashing cursors and insertion
// point custom widths.
@interface NSTextView (BINExtensions)

// FIXME: Doesn't work properly.
@property (nonatomic, assign) BOOL flashInsertionPoint;

@property (nonatomic, assign) CGFloat insertionPointWidth;
@property (nonatomic, strong) NSColor *insertionPointColor;

@end
