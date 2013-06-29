#import <Foundation/Foundation.h>

#define _stringify(str) #str
#define stringify(str) _stringify(str)

#define MOCHA_10_8 (defined(__MAC_10_8) || __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_8)
#define MOCHA_10_9 (defined(__MAC_10_9) || __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_9)

@interface NSObject (BINExtensions)

+ (BOOL)exchangeInstanceMethod:(SEL)originalSelector
					withMethod:(SEL)alternateSelector
						 error:(NSError **)error;
+ (BOOL)exchangeClassMethod:(SEL)originalSelector
			withClassMethod:(SEL)alternateSelector
					  error:(NSError **)error;

- (void)performSelector:(SEL)selector withObjects:(NSObject *)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

@end
