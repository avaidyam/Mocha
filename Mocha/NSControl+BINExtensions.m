#import "NSControl+BINExtensions.h"

@implementation NSControl (BINExtensions)

- (id)representedObject {
	return [self.cell representedObject];
}
- (void)setRepresentedObject:(id)representedObject {
	[self.cell setRepresentedObject:representedObject];
}

- (NSBackgroundStyle)backgroundStyle {
	return [self.cell backgroundStyle];
}
- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
	[self.cell setBackgroundStyle:backgroundStyle];
}

@end

@implementation NSCell (BINExtensions)

@dynamic representedObject;

@end
