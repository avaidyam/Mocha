/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import "NSTableView+BINExtensions.h"
#import "NSObject+BINExtensions.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation NSTableView (BINExtensions)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
+ (void)load {
	[self attemptToSwapInstanceMethod:@selector(setDoubleAction:) withPrefix:MochaPrefix];
	[self attemptToSwapInstanceMethod:@selector(setTarget:) withPrefix:MochaPrefix];
	[self attemptToSwapInstanceMethod:@selector(initWithFrame:) withPrefix:MochaPrefix];
	[self attemptToSwapInstanceMethod:@selector(initWithCoder:) withPrefix:MochaPrefix];
	[self attemptToSwapInstanceMethod:@selector(awakeFromNib) withPrefix:MochaPrefix];
}
#pragma clang diagnostic pop

- (id)initWithFrame_BIN:(NSRect)frameRect {
	if((self = [self initWithFrame_BIN:frameRect])) {
		self.target = self;
		self.doubleAction = @selector(BIN_intermediateDoubleAction:);
	}
	return self;
}

- (id)initWithCoder_BIN:(NSCoder *)aDecoder {
	if((self = [self initWithCoder_BIN:aDecoder])) {
		self.target = self;
		self.doubleAction = @selector(BIN_intermediateDoubleAction:);
	}
	return self;
}

- (void)BIN_awakeFromNib {
	[self BIN_awakeFromNib];
	
	self.target = self;
	self.doubleAction = @selector(BIN_intermediateDoubleAction:);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (void)BIN_setTarget:(id)anObject {
	[self BIN_setTarget:self];
}

- (id)target {
	return self;
}

- (void)BIN_setDoubleAction:(SEL)aSelector {
	[self BIN_setDoubleAction:@selector(BIN_intermediateDoubleAction:)];
}

- (SEL)doubleAction {
	return @selector(BIN_intermediateDoubleAction:);
}

#pragma clang diagnostic pop

- (void)BIN_intermediateDoubleAction:(id)sender {
	if(self.delegate != nil && [self.delegate respondsToSelector:@selector(tableView:didDoubleClickColumn:row:)])
		[(id)self.delegate tableView:self didDoubleClickColumn:self.clickedColumn row:self.clickedRow];
}

@end
#pragma clang diagnostic pop
