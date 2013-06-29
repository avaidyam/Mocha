#import <Foundation/Foundation.h>

// Add subscripting to NSCache.
@interface NSCache (BINExtensions)

+ (instancetype)cacheWithName:(NSString *)name countLimit:(NSUInteger)countLimit;

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id)key;

@end
