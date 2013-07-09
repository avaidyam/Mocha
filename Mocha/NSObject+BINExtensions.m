/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import "NSObject+BINExtensions.h"
#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSScriptClassDescription.h>
#import <objc/objc-class.h>

@implementation NSObject (BINExtensions)

+ (BOOL)exchangeInstanceMethod:(SEL)original withMethod:(SEL)alternate error:(NSError **)error {
	Method origMethod = class_getInstanceMethod(self, original);
	if(!origMethod) {
		if(error) {
			NSString *errStr = [NSString stringWithFormat:@"%@: original method %@ not found for class %@",
								NSStringFromSelector(_cmd), NSStringFromSelector(original), self.className];
			*error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1	
									 userInfo:@{ NSLocalizedDescriptionKey : errStr }];
		}
		return NO;
	}
	
	Method altMethod = class_getInstanceMethod(self, alternate);
	if (!altMethod) {
		if(error) {
			NSString *errStr = [NSString stringWithFormat:@"%@: alternate method %@ not found for class %@",
								NSStringFromSelector(_cmd), NSStringFromSelector(original), self.className];
			*error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1
									 userInfo:@{ NSLocalizedDescriptionKey : errStr }];
		}
		return NO;
	}
	
	class_addMethod(self, original,
					class_getMethodImplementation(self, original),
					method_getTypeEncoding(origMethod));
	class_addMethod(self, alternate,
					class_getMethodImplementation(self, alternate),
					method_getTypeEncoding(altMethod));
	method_exchangeImplementations(class_getInstanceMethod(self, original),
								   class_getInstanceMethod(self, alternate));
	
	return YES;
}

+ (BOOL)exchangeClassMethod:(SEL)original withClassMethod:(SEL)alternate error:(NSError **)error {
	return [object_getClass((id)self) exchangeInstanceMethod:original withMethod:alternate error:error];
}

+ (BOOL)safelyAddInstanceMethod:(SEL)additional replacingMethod:(SEL)replace error:(NSError **)error {
	if(!class_getInstanceMethod(self, replace)) {
		Method additionalMethod = class_getInstanceMethod(self, additional);
		if (!additionalMethod) {
			if(error) {
				NSString *errStr = [NSString stringWithFormat:@"%@: additional method %@ not found for class %@",
									NSStringFromSelector(_cmd), NSStringFromSelector(additional), self.className];
				*error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1
										 userInfo:@{ NSLocalizedDescriptionKey : errStr }];
			}
			return NO;
		}
		
		class_addMethod(self, replace,
						class_getMethodImplementation(self, additional),
						method_getTypeEncoding(additionalMethod));
	}
	return YES;
}

+ (void)attemptToSwapInstanceMethod:(SEL)selector withPrefix:(NSString *)prefix {
	NSString *prefixedSel = NSStringFromSelector(selector);
	if([prefixedSel hasPrefix:@"init"]) {
		NSMutableArray *components = [prefixedSel componentsSeparatedByString:@":"].mutableCopy;
		components[0] = [NSString stringWithFormat:@"%@_%@", components[0], prefix];
		prefixedSel = [components componentsJoinedByString:@":"];
	} else prefixedSel = [NSString stringWithFormat:@"%@_%@", prefix, prefixedSel];
	
	NSError *error = nil;
	if(![self exchangeInstanceMethod:NSSelectorFromString(prefixedSel) withMethod:selector error:&error])
		NSLog(@"%@", error);
}

+ (void)attemptToSwapClassMethod:(SEL)selector withPrefix:(NSString *)prefix {
	[object_getClass((id)self) attemptToSwapInstanceMethod:selector withPrefix:prefix];
}

+ (BOOL)safelyAddClassMethod:(SEL)additional replacingMethod:(SEL)replace error:(NSError **)error {
	return [object_getClass((id)self) safelyAddInstanceMethod:additional replacingMethod:replace error:error];
}

+ (void)attemptToAddInstanceMethod:(SEL)selector withPrefix:(NSString *)prefix {
	NSString *prefixedSel = NSStringFromSelector(selector);
	if([prefixedSel hasPrefix:@"init"]) {
		NSMutableArray *components = [prefixedSel componentsSeparatedByString:@":"].mutableCopy;
		components[0] = [NSString stringWithFormat:@"%@_%@", components[0], prefix];
		prefixedSel = [components componentsJoinedByString:@":"];
	} else prefixedSel = [NSString stringWithFormat:@"%@_%@", prefix, prefixedSel];
	
	NSError *error = nil;
	if(![self safelyAddInstanceMethod:NSSelectorFromString(prefixedSel) replacingMethod:selector error:&error])
		NSLog(@"%@", error);
}

+ (void)attemptToAddClassMethod:(SEL)selector withPrefix:(NSString *)prefix {
	[object_getClass((id)self) attemptToAddInstanceMethod:selector withPrefix:prefix];
}

@end
