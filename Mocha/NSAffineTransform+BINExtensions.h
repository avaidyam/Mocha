/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <Foundation/NSAffineTransform.h>

@interface NSAffineTransform (BINExtensions)

// Returns a CGAffineTransform with the receiving NSAffineTransform.
@property (nonatomic, readonly) CGAffineTransform CGAffineTransform;
 
// Returns an NSAffineTransform with the passed CGAffineTransform.
+ (NSAffineTransform *)transformWithCGAffineTransform:(CGAffineTransform)transform;

@end
