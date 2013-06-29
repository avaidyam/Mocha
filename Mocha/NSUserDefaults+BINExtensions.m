#import "NSUserDefaults+BINExtensions.h"

@implementation NSUserDefaults (BINExtensions)

+ (instancetype)defaults {
	return [NSUserDefaults standardUserDefaults];
}

- (id)objectForKeyedSubscript:(id)key {
	return [self objectForKey:key];
}

- (void)setObject:(id)newValue forKeyedSubscript:(id)key {
	[self setObject:newValue forKey:key];
}

@end
