#import "NSTimer+BINExtensions.h"

@implementation NSTimer (BINExtensions)

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

@end
