/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <Foundation/NSTimer.h>

// This category adds NSTimer block support. The methods follow the
// same syntax and semantics as the existing target/action-based ones.
@interface NSTimer (BINExtensions)

// This property is unimplemented prior to 10.9.
@property (nonatomic, assign) NSTimeInterval tolerance;

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval
										 block:(void (^)(NSTimer *timer))block
									   repeats:(BOOL)repeat;

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)timeInterval
								block:(void (^)(NSTimer *timer))block
							  repeats:(BOOL)repeat;

@end
