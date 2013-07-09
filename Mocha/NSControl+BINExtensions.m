/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

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
