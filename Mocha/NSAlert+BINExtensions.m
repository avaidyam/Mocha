#import "NSAlert+BINExtensions.h"
#import <objc/runtime.h>

@interface BINSheetRequest : NSObject

@property (nonatomic, strong) NSWindow *sheet;
@property (nonatomic, strong) NSWindow *window;
@property (nonatomic, copy) void (^handler)(NSModalResponse);

+ (instancetype)sheetRequestWithSheet:(NSWindow *)sheet
					   modalForWindow:(NSWindow *)window
							  handler:(void (^)(NSModalResponse))handler;
- (void)beginSheet;

@end

@interface NSWindow (BINSheetPrivate)

@property (nonatomic, strong) NSMutableArray *sheetQueue;

@end

@interface NSAlert (BINExtensionsPrivate)

@property (nonatomic, strong) NSPopover *popover;
@property (nonatomic, assign) NSInteger completionReturn;
@property (nonatomic, copy) NSAlertCompletionHandler completionHandler;

@end

@implementation NSAlert (BINExtensions)

+ (void)load {
	NSError *error = nil;
	if(![NSAlert exchangeInstanceMethod:@selector(buttonPressed:)
							 withMethod:@selector(BIN_buttonPressed:)
								  error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
	
	error = nil;
	if(![NSAlert exchangeInstanceMethod:@selector(layout)
							 withMethod:@selector(BIN_layout)
								  error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
}

- (BOOL)displayAnchoredToView:(NSView *)anchorView
					   onEdge:(NSRectEdge)anchorEdge
			completionHandler:(NSAlertCompletionHandler)handler {
	if(self.popover.shown)
		return NO;
	
	self.popover = [NSPopover new];
	NSView *contentView = [self.buttons[0] superview];
	self.popover.contentViewController = [NSViewController new];
	self.popover.contentViewController.view = contentView;
	self.completionHandler = handler;
	self.completionReturn = NSNotFound;
	
	id observer = nil;
	observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSPopoverDidCloseNotification
																 object:self.popover queue:nil
															 usingBlock:^(NSNotification *note) {
																 if(self.completionHandler != nil)
																	 self.completionHandler(self.completionReturn);
																 self.completionHandler = nil;
																 self.completionReturn = NSNotFound;
																 self.popover.contentViewController = nil;
																 self.popover = nil;
																 
																 [[NSNotificationCenter defaultCenter] removeObserver:observer];
															 }];
	
	[self layout];
	[self.popover showRelativeToRect:anchorView.bounds ofView:anchorView preferredEdge:anchorEdge];
	return YES;
}

// Custom layout routine for popovers. Save autoresize masks, then
// shift all elements to the lower left region of the popover, and
// reduce height and width by almost twice as much, finally restoring
// autoresize masks. This de-pads the auto-padded content view.
// Bonus: make the buttons textured if applicable for bezel style.
- (void)BIN_layout {
	[self BIN_layout];
	NSView *contentView = [self.buttons[0] superview];
	if(self.popover == nil)
		return;
	
	NSMutableDictionary *masks = @{}.mutableCopy;
	for(NSView *view in contentView.subviews) {
		masks[@([contentView.subviews indexOfObject:view])] = @(view.autoresizingMask);
		view.autoresizingMask = NSViewNotSizable;
	}
	
	for(NSView *view in contentView.subviews) {
		NSRect f = view.frame;
		f.origin.x -= 20.0f;
		f.origin.y -= 10.0f;
		view.frame = f;
	}
	
	NSRect f = contentView.frame;
	f.size.width -= 30.0f;
	f.size.height -= 20.0f;
	contentView.frame = f;
	
	for(NSView *view in contentView.subviews) {
		view.autoresizingMask = [masks[@([contentView.subviews indexOfObject:view])] unsignedIntegerValue];
		//if([view isKindOfClass:NSButton.class] && [(id)view bezelStyle] == NSRoundedBezelStyle)
		//	[(id)view setBezelStyle:NSTexturedRoundedBezelStyle];
	}
}

- (void)BIN_beginSheetModalForWindow:(NSWindow *)window completionHandler:(void (^)(NSModalResponse returnCode))handler {
	NSWindow *sheet = [self.buttons[0] window];
	
	if(self.alertStyle == NSCriticalAlertStyle)
		[window beginCriticalSheet:sheet completionHandler:handler];
	else [window beginSheet:sheet completionHandler:handler];
}

- (void)BIN_buttonPressed:(NSButton *)sender {
	[self BIN_buttonPressed:sender];
	
	if(self.popover != nil) {
		self.completionReturn = sender.tag;
		[self.popover close];
	} else if(sender.window.sheetParent != nil) {
		[sender.window.sheetParent endSheet:sender.window returnCode:sender.tag];
	}
}

@end

@implementation NSWindow (BINSheetExtensions)

- (NSArray *)BIN_sheets {
	NSMutableArray *sheets = @[].mutableCopy;
	for(BINSheetRequest *req in self.sheetQueue)
		[sheets addObject:req.sheet];
	return sheets;
}

- (NSWindow *)BIN_sheetParent {
	NSWindow *sheetParent = nil;
	if(!self.isSheet)
		return sheetParent;
	
    for(NSWindow *window in [NSApp windows]) {
		if([self isEqual:window])
			continue;
		if([self isEqual:window.attachedSheet])
			return window;
	}
	
    return sheetParent;
}

- (void)BIN_beginSheet:(NSWindow *)sheetWindow completionHandler:(void (^)(NSModalResponse returnCode))handler {
	if(self.sheetQueue == nil)
		self.sheetQueue = @[].mutableCopy;
	
	// Add a request to the queue and if possible, display it.
	BINSheetRequest *req = [BINSheetRequest sheetRequestWithSheet:sheetWindow modalForWindow:self handler:handler];
	[self.sheetQueue addObject:req];
	if(self.attachedSheet == nil)
		[req beginSheet];
}

- (void)BIN_beginCriticalSheet:(NSWindow *)sheetWindow completionHandler:(void (^)(NSModalResponse returnCode))handler {
	if(self.sheetQueue == nil)
		self.sheetQueue = @[].mutableCopy;
	
	// Find the deepest possible parent sheet to be modal for.
	NSWindow *parent = self;
	while(parent.attachedSheet != nil)
		parent = parent.attachedSheet;
	
	// Immediately begin this request, but also add it to the queue at index 0.
	BINSheetRequest *req = [BINSheetRequest sheetRequestWithSheet:sheetWindow modalForWindow:parent handler:handler];
	[self.sheetQueue insertObject:req atIndex:0];
	[req beginSheet];
}

- (void)BIN_endSheet:(NSWindow *)sheetWindow {
	[self BIN_endSheet:sheetWindow returnCode:NSModalResponseStop];
}

- (void)BIN_endSheet:(NSWindow *)sheetWindow returnCode:(NSModalResponse)returnCode {
	if(self.sheetQueue == nil)
		self.sheetQueue = @[].mutableCopy;
	
	// Note: in OS X 10.9, this method calls the NSWindow method of the same name.
	[NSApp endSheet:sheetWindow returnCode:returnCode];
	
	// Remove the current sheet.
	BINSheetRequest *currentSheet = nil;
    for (BINSheetRequest *request in self.sheetQueue) {
		if([request.sheet isEqual:sheetWindow]) {
			currentSheet = request;
			break;
		}
	}
	[self.sheetQueue removeObject:currentSheet];
	
	// Begin the next sheet.
	BINSheetRequest *nextSheet = nil;
    for (BINSheetRequest *request in self.sheetQueue) {
        if([request.window isEqual:self]) {
            nextSheet = request;
            break;
        }
    }
	[nextSheet beginSheet];
}

@end

@implementation NSWindow (BINSheetPrivate)

@dynamic sheetQueue;
static const char *sheetQueue_key = "sheetQueue_key";
- (NSMutableArray *)sheetQueue {
	return objc_getAssociatedObject(self, sheetQueue_key);
}
- (void)setSheetQueue:(NSMutableArray *)sheetQueue {
	objc_setAssociatedObject(self, sheetQueue_key, sheetQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation NSAlert (BINExtensionsPrivate)

@dynamic popover;
static const char *popover_key = "popover_key";
- (NSPopover *)popover {
	return objc_getAssociatedObject(self, popover_key);
}
- (void)setPopover:(NSPopover *)popover {
	objc_setAssociatedObject(self, popover_key, popover, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@dynamic completionHandler;
static const char *completionHandler_key = "completionHandler_key";
- (NSAlertCompletionHandler)completionHandler {
	return objc_getAssociatedObject(self, completionHandler_key);
}
- (void)setCompletionHandler:(NSAlertCompletionHandler)completionHandler {
	objc_setAssociatedObject(self, completionHandler_key, completionHandler, OBJC_ASSOCIATION_COPY);
}

@dynamic completionReturn;
static const char *completionReturn_key = "completionReturn_key";
- (NSInteger)completionReturn {
	return [objc_getAssociatedObject(self, completionReturn_key) integerValue];
}
- (void)setCompletionReturn:(NSInteger)completionReturn {
	objc_setAssociatedObject(self, completionReturn_key, @(completionReturn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation BINSheetRequest

+ (instancetype)sheetRequestWithSheet:(NSWindow *)sheet
					   modalForWindow:(NSWindow *)window
							  handler:(void (^)(NSModalResponse))handler {
	BINSheetRequest *req = [BINSheetRequest new];
	req.sheet = sheet;
	req.window = window;
	req.handler = handler;
	return req;
}

- (void)beginSheet {
	[NSApp beginSheet:self.sheet modalForWindow:self.window
		modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	if(![sheet isEqual:self.sheet])
		return;
	[sheet orderOut:nil];
	if(self.handler != nil)
		self.handler(returnCode);
}

@end
