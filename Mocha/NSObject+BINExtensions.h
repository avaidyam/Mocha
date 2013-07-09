/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <Foundation/NSObject.h>
#import <Foundation/NSError.h>
#import <Foundation/NSObjCRuntime.h>

// Simple stringification macro.
#define _stringify(str) #str
#define stringify(str) _stringify(str)

// Mocha Availability support macros.
#define MOCHA_10_8 (defined(__MAC_10_8) || __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_8)
#define MOCHA_10_9 (defined(__MAC_10_9) || __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_9)

// Mocha Availability runtime macros.
#define MochaPlatform10_8 (NSClassFromString(@"NSPageController"))
#define MochaPlatform10_9 (NSClassFromString(@"NSStackView"))

static NSString *MochaPrefix = @"BIN";

@interface NSObject (BINExtensions)

+ (BOOL)exchangeInstanceMethod:(SEL)originalSelector
					withMethod:(SEL)alternateSelector
						 error:(NSError **)error;
+ (BOOL)exchangeClassMethod:(SEL)originalSelector
			withClassMethod:(SEL)alternateSelector
					  error:(NSError **)error;

+ (BOOL)safelyAddInstanceMethod:(SEL)additionalSelector
				replacingMethod:(SEL)replacementSelector
						  error:(NSError **)error;
+ (BOOL)safelyAddClassMethod:(SEL)additionalSelector
			 replacingMethod:(SEL)replacementSelector
					   error:(NSError **)error;

+ (void)attemptToSwapInstanceMethod:(SEL)selector withPrefix:(NSString *)prefix;
+ (void)attemptToSwapClassMethod:(SEL)selector withPrefix:(NSString *)prefix;

+ (void)attemptToAddInstanceMethod:(SEL)selector withPrefix:(NSString *)prefix;
+ (void)attemptToAddClassMethod:(SEL)selector withPrefix:(NSString *)prefix;

@end
