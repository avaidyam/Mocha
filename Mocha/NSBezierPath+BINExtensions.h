/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <AppKit/NSBezierPath.h>

@interface NSBezierPath (BINExtensions)

// Returns a CGPath with the receiving NSBezierPath.
@property (nonatomic, readonly) CGPathRef CGPath CF_RETURNS_RETAINED;

// Returns an NSBezierPath with the passed CGPath.
+ (NSBezierPath *)bezierPathWithCGPath:(CGPathRef)pathRef;

@end