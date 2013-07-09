/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <QuartzCore/CATransaction.h>

@interface CATransaction (BINExtensions)

// Executes a block with actions disabled.
+ (void)performWithDisabledActions:(void(^)(void))block;

@end
