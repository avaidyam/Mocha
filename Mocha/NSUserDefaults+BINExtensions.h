#import <Foundation/Foundation.h>

@interface NSUserDefaults (BINExtensions)

+ (instancetype)defaults;

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id)key;

@end
