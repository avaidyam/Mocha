#import <Foundation/Foundation.h>

@interface NSTimer (BINExtensions)

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval
										 block:(void (^)(NSTimer *timer))block
									   repeats:(BOOL)repeat;

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)timeInterval
								block:(void (^)(NSTimer *timer))block
							  repeats:(BOOL)repeat;

@end
