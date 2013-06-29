#import "NSTableView+BINExtensions.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation NSTableView (BINExtensions)

+ (void)load {
	NSError *error = nil;
	if(![NSTableView exchangeInstanceMethod:@selector(setDoubleAction:)
								 withMethod:@selector(BIN_setDoubleAction:)
									  error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
	
	error = nil;
	if(![NSTableView exchangeInstanceMethod:@selector(setTarget:)
								 withMethod:@selector(BIN_setTarget:)
									  error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
	
	error = nil;
	if(![NSTableView exchangeInstanceMethod:@selector(initWithFrame:)
								 withMethod:@selector(initWithFrame_BIN:)
									  error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
	
	error = nil;
	if(![NSTableView exchangeInstanceMethod:@selector(initWithCoder:)
								 withMethod:@selector(initWithCoder_BIN:)
									  error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
	
	error = nil;
	if(![NSTableView exchangeInstanceMethod:@selector(awakeFromNib)
								 withMethod:@selector(BIN_awakeFromNib)
									  error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
}

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
