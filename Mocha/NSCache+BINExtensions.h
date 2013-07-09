/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <Foundation/NSCache.h>

@interface NSCache (BINExtensions)

// Simpler class method to create and return a configured NSCache.
+ (instancetype)cacheWithName:(NSString *)name countLimit:(NSUInteger)countLimit;

// The following methods are mapped to NSCache objectWithKey:
// and setObject:forKey: methods to allow the Modern Objective-C
// subscripting syntax. (ex. self.cache[@"myKey"] = @"Hi";)
- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id)key;

@end
