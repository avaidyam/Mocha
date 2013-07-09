/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import "NSUserDefaults+BINExtensions.h"

@implementation NSUserDefaults (BINExtensions)

+ (instancetype)defaults {
	return [NSUserDefaults standardUserDefaults];
}

- (id)objectForKeyedSubscript:(id)key {
	return [self objectForKey:key];
}

- (void)setObject:(id)newValue forKeyedSubscript:(id)key {
	[self setObject:newValue forKey:key];
}

@end
