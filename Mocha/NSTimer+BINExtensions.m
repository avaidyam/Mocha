/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import "NSTimer+BINExtensions.h"
#import "NSObject+BINExtensions.h"

@implementation NSTimer (BINExtensions)

+ (void)load {
	[self attemptToAddInstanceMethod:@selector(tolerance)
						  withPrefix:MochaPrefix];
	[self attemptToAddInstanceMethod:@selector(setTolerance:)
						  withPrefix:MochaPrefix];
}

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval
										 block:(void (^)(NSTimer *timer))block
									   repeats:(BOOL)repeat {
	
	return [self scheduledTimerWithTimeInterval:timeInterval
										 target:self selector:@selector(BIN_executeTimerBlock:)
									   userInfo:[block copy] repeats:repeat];
}

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)timeInterval
								block:(void (^)(NSTimer *timer))block
							  repeats:(BOOL)repeat {
	
	return [self timerWithTimeInterval:timeInterval
								target:self selector:@selector(BIN_executeTimerBlock:)
							  userInfo:[block copy] repeats:repeat];
}

+ (void)BIN_executeTimerBlock:(NSTimer *)timer {
	if(!timer.userInfo)
		return;
	
	void (^block)(NSTimer *) = (void (^)(NSTimer *))timer.userInfo;
	block(timer);
}

- (NSTimeInterval)BIN_tolerance {
	return 0.0f; // Unimplemented.
}

- (void)BIN_setTolerance:(NSTimeInterval)tolerance {
	// Unimplemented.
}

@end
