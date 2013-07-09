/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <Foundation/NSUserDefaults.h>

@interface NSUserDefaults (BINExtensions)

// Simpler singleton method to return the standard NSUserDefaults.
+ (instancetype)defaults;

// The following methods are mapped to NSUserDefaults objectWithKey:
// and setObject:forKey: methods to allow the Modern Objective-C
// subscripting syntax. (ex. self.defaults[@"myKey"] = @"Hi";)
- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id)key;

@end

