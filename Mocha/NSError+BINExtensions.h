/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <Foundation/NSError.h>

@interface NSError (BINExtensions)

// Returns the stack trace from right before the error was created.
@property (nonatomic, readonly) NSArray *callStackSymbols;

@end
