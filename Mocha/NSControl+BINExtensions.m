/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import "NSControl+BINExtensions.h"
#import "NSObject+BINExtensions.h"

@implementation NSControl (BINExtensions)

+ (void)load {
	[self attemptToAddInstanceMethod:@selector(allowsExpansionToolTips)
						  withPrefix:@"BIN"];
	[self attemptToAddInstanceMethod:@selector(setAllowsExpansionToolTips:)
						  withPrefix:@"BIN"];
}

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

- (BOOL)BIN_allowsExpansionToolTips {
	return NO;
}

- (void)BIN_setAllowsExpansionToolTips:(BOOL)value {
	
}

@end

@implementation NSCell (BINExtensions)

@dynamic representedObject;

@end
