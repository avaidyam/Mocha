/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import "NSProcessInfo+BINExtensions.h"
#import <Foundation/NSDictionary.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSString.h>
#import <IOKit/pwr_mgt/IOPMLib.h>

@interface BINActivityAssertion : NSObject

@property (assign, readonly) NSActivityOptions options;
@property (assign, readonly) BOOL ended;
@property (copy,   readonly) NSString *reason;
@property (assign, readonly) IOPMAssertionID displaySleepAssertionID;
@property (assign, readonly) IOPMAssertionID systemSleepAssertionID;

- (instancetype)initWithActivityOptions:(NSActivityOptions)options reason:(NSString *)reason;
- (void)end;

@end

@implementation NSProcessInfo (BINExtensions)

+ (void)load {
	[self attemptToAddInstanceMethod:@selector(beginActivityWithOptions:reason:)
						  withPrefix:MochaPrefix];
	[self attemptToAddInstanceMethod:@selector(endActivity:)
						  withPrefix:MochaPrefix];
	[self attemptToAddInstanceMethod:@selector(performActivityWithOptions:reason:block:)
						  withPrefix:MochaPrefix];
}

- (id<NSObject>)BIN_beginActivityWithOptions:(NSActivityOptions)options reason:(NSString *)reason {
	return [[BINActivityAssertion alloc] initWithActivityOptions:options reason:reason];
}

- (void)BIN_endActivity:(id<NSObject>)activity {
	if(![(BINActivityAssertion *)activity ended])
		[(BINActivityAssertion *)activity end];
}

- (void)BIN_performActivityWithOptions:(NSActivityOptions)options reason:(NSString *)reason block:(void (^)())block {
	id activity = [self beginActivityWithOptions:options reason:reason];
	if(block) block();
	[self endActivity:activity];
}

@end

@implementation BINActivityAssertion

- (instancetype)initWithActivityOptions:(NSActivityOptions)options reason:(NSString *)reason {
	if((self = [super init])) {
		_options = options;
		_reason = reason;
		
		if(self.options & NSActivityIdleDisplaySleepDisabled) {
			IOPMAssertionCreateWithName(kIOPMAssertionTypePreventUserIdleDisplaySleep,
										kIOPMAssertionLevelOn, (__bridge CFStringRef)self.reason,
										&_displaySleepAssertionID);
		}
		
		if(self.options & NSActivityIdleSystemSleepDisabled) {
			IOPMAssertionCreateWithName(kIOPMAssertionTypePreventUserIdleSystemSleep,
										kIOPMAssertionLevelOn, (__bridge CFStringRef)self.reason,
										&_systemSleepAssertionID);
		}
		
		if(self.options & NSActivitySuddenTerminationDisabled)
			[[NSProcessInfo processInfo] disableSuddenTermination];
		if(self.options & NSActivityAutomaticTerminationDisabled)
			[[NSProcessInfo processInfo] disableAutomaticTermination:self.reason];
	}
	return self;
}

- (void)end {
	if(self.options & NSActivityIdleDisplaySleepDisabled)
		IOPMAssertionRelease(_displaySleepAssertionID);
	if(self.options & NSActivityIdleSystemSleepDisabled)
		IOPMAssertionRelease(_systemSleepAssertionID);
	
	if(self.options & NSActivitySuddenTerminationDisabled)
		[[NSProcessInfo processInfo] enableSuddenTermination];
	if(self.options & NSActivityAutomaticTerminationDisabled)
		[[NSProcessInfo processInfo] enableAutomaticTermination:self.reason];
	
	_ended = YES;
}

- (void)dealloc {
	[self end];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<NSActivity: %@>", self.reason];
}

@end
