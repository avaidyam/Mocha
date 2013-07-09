/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import "NSCache+BINExtensions.h"

@implementation NSCache (BINExtensions)

+ (instancetype)cacheWithName:(NSString *)name countLimit:(NSUInteger)countLimit {
	NSCache *cache = [self.class new];
	cache.name = name;
	cache.countLimit = countLimit;
	return cache;
}

- (id)objectForKeyedSubscript:(id)key {
	return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id)key {
	[self setObject:obj forKey:key];
}

@end
