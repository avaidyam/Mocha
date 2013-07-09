/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <Foundation/NSProcessInfo.h>
#import "NSObject+BINExtensions.h"

#if !MOCHA_10_9
typedef NS_OPTIONS(uint64_t, NSActivityOptions) {
	
    // Used for activities that require the screen to stay powered on.
	// Be sure not to forget to end activities that include this option.
    NSActivityIdleDisplaySleepDisabled = (1ULL << 40),
    
    // Used for activities that require the computer to not idle sleep. This is included in NSActivityUserInitiated.
	// Be sure not to forget to end activities that include this option.
    NSActivityIdleSystemSleepDisabled = (1ULL << 20),
    
    // Prevents sudden termination. This is included in NSActivityUserInitiated.
    NSActivitySuddenTerminationDisabled = (1ULL << 14),
    
    // Prevents automatic termination. This is included in NSActivityUserInitiated.
    NSActivityAutomaticTerminationDisabled = (1ULL << 15),
    
    // ----
    // Sets of options.
    
    // App is performing a user-requested action.
	// These are finite length activities that the user has explicitly started.
	// Examples include exporting or downloading a user specified file.
    NSActivityUserInitiated = (0x00FFFFFFULL | NSActivityIdleSystemSleepDisabled),
    NSActivityUserInitiatedAllowingIdleSystemSleep = (NSActivityUserInitiated & ~NSActivityIdleSystemSleepDisabled),
    
    // App has initiated some kind of work, but not as the direct result of user request.
	// These are finite length activities that are part of the normal operation of your
	// application but are not explicitly started by the user. Examples include autosaving,
	// indexing, and automatic downloading of files.
    NSActivityBackground = 0x000000FFULL,
    
    // Used for activities that require the highest amount of timer and I/O precision available.
	// Very few applications should need to use this constant.
	// This should be reserved for activities like audio or video recording.
    NSActivityLatencyCritical UNAVAILABLE_ATTRIBUTE = 0xFF00000000ULL, 
};

// The system has heuristics to improve battery life, performance, and responsiveness of
// applications for the benefit of the user. This API can be used to give hints to the
// system that your application has special requirements. In response to creating one of
// these activities, the system will disable some or all of the heuristics so your application
// can finish quickly while still providing responsive behavior if the user needs it.
//
// These activities can be used when your application is performing a long-running operation.
// If the activity can take different amounts of time (for example, calculating the next move
// in a chess game), it should use this API. This will ensure correct behavior when the amount
// of data or the capabilities of the user's computer varies. Be aware that failing to end
// these activities for an extended period of time can have significant negative impacts to
// the performance of your user's computer, so be sure to use only the minimum amount of time
// required. User preferences may override your application’s request.
@interface NSProcessInfo (BINExtensions)

// Pass in an activity to this API, and a non-NULL, non-empty reason string. Indicate
// completion of the activity by calling the corresponding endActivity: method with the
// result of the beginActivityWithOptions:reason: method. The reason string is used for debugging.
- (id <NSObject>)beginActivityWithOptions:(NSActivityOptions)options reason:(NSString *)reason;

// The argument to this method is the result of beginActivityWithOptions:reason:.
// If the object is deallocated before the -endActivity: call, the activity will be automatically ended.
- (void)endActivity:(id <NSObject>)activity;

// Synchronously perform an activity. The activity will be automatically ended after
// your block argument returns. The reason string is used for debugging.
- (void)performActivityWithOptions:(NSActivityOptions)options reason:(NSString *)reason block:(void (^)())block;

@end
#endif
