/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import "NSError+BINExtensions.h"
#import "NSObject+BINExtensions.h"
#import <Foundation/NSThread.h>
#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSRange.h>
#import <objc/runtime.h>

@implementation NSError (BINExtensions)

@dynamic callStackSymbols;
static const char *callStackSymbols_key = "callStackSymbols_key";

+ (void)load {
	[self attemptToSwapInstanceMethod:@selector(initWithDomain:code:userInfo:)
						   withPrefix:MochaPrefix];
}

- (id)initWithDomain_BIN:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict {
	if((self = [self initWithDomain_BIN:domain code:code userInfo:dict])) {
		NSArray *symbols = [NSThread callStackSymbols];
		objc_setAssociatedObject(self, callStackSymbols_key,
								 [symbols subarrayWithRange:NSMakeRange(1, symbols.count - 1)],
								 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return self;
}

- (NSArray *)callStackSymbols {
	return objc_getAssociatedObject(self, callStackSymbols_key);
}

@end
