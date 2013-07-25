/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <AppKit/NSClipView.h>

@class CAScrollLayer;

@interface  NSClipView (BINExtensions)

// The backing layer for this view.
@property (nonatomic, strong) CAScrollLayer *layer;

// Whether the content in this view is opaque. Defaults to NO.
@property (nonatomic, getter = isOpaque) BOOL opaque;

@end
