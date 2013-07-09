/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <AppKit/NSShadow.h>

@interface NSShadow (BINExtensions)

// Returns a shadow with the given shadow radius, offset, and color properties.
+ (NSShadow *)shadowWithRadius:(CGFloat)radius offset:(CGSize)offset color:(NSColor *)color;

@end
