#import "NSObject+BINExtensions.h"
#import <objc/objc-class.h>

#define SetNSErrorFor(FUNC, ERROR_VAR, FORMAT,...)	\
	if (ERROR_VAR) {	\
		NSString *errStr = [NSString stringWithFormat:@"%s: " FORMAT,FUNC,##__VA_ARGS__]; \
		*ERROR_VAR = [NSError errorWithDomain:@"NSCocoaErrorDomain" \
										 code:-1	\
									 userInfo:[NSDictionary dictionaryWithObject:errStr forKey:NSLocalizedDescriptionKey]]; \
	}
#define SetNSError(ERROR_VAR, FORMAT,...) SetNSErrorFor(__func__, ERROR_VAR, FORMAT, ##__VA_ARGS__)

@implementation NSObject (BINExtensions)

+ (BOOL)exchangeInstanceMethod:(SEL)origSel_ withMethod:(SEL)altSel_ error:(NSError**)error_ {
	Method origMethod = class_getInstanceMethod(self, origSel_);
	if (!origMethod) {
		SetNSError(error_, @"original method %@ not found for class %@",
				   NSStringFromSelector(origSel_), [self className]);
		return NO;
	}
	
	Method altMethod = class_getInstanceMethod(self, altSel_);
	if (!altMethod) {
		SetNSError(error_, @"alternate method %@ not found for class %@",
				   NSStringFromSelector(altSel_), [self className]);
		return NO;
	}
	
	class_addMethod(self, origSel_,
					class_getMethodImplementation(self, origSel_),
					method_getTypeEncoding(origMethod));
	class_addMethod(self, altSel_,
					class_getMethodImplementation(self, altSel_),
					method_getTypeEncoding(altMethod));
	method_exchangeImplementations(class_getInstanceMethod(self, origSel_),
								   class_getInstanceMethod(self, altSel_));
	
	return YES;
}

+ (BOOL)exchangeClassMethod:(SEL)origSel_ withClassMethod:(SEL)altSel_ error:(NSError **)error_ {
	return [object_getClass((id)self) exchangeInstanceMethod:origSel_ withMethod:altSel_ error:error_];
}

- (void)performSelector:(SEL)selector withObjects:(NSObject *)firstObject, ... {
#define MAX_MESSAGE_ARGUMENTS (10)
    typedef NSObject *objectArray[MAX_MESSAGE_ARGUMENTS];
    objectArray messageArguments = {0};
	
    size_t variadicArgumentIndex = 0;
    va_list variadicArguments;
    va_start(variadicArguments, firstObject);
    for(NSObject *variadicArgument = firstObject; variadicArgument != nil;
		variadicArgument = va_arg(variadicArguments, NSObject*)) {
        messageArguments[variadicArgumentIndex++] = variadicArgument;
    }
    va_end(variadicArguments);
	
    objc_msgSend(self, selector, messageArguments[0], messageArguments[1], messageArguments[2], messageArguments[3],
                 messageArguments[4], messageArguments[5], messageArguments[6], messageArguments[7],
				 messageArguments[8], messageArguments[9]);
	
}

@end
