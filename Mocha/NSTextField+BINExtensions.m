#import "NSTextField+BINExtensions.h"
#import <objc/runtime.h>

@implementation NSTextField (BINExtensions)

@dynamic accessoryView;
static const char *accessoryView_key = "accessoryView_key";
- (NSView *)accessoryView {
	return objc_getAssociatedObject(self, accessoryView_key);
}
- (void)setAccessoryView:(NSView *)accessoryView {
	objc_setAssociatedObject(self, accessoryView_key, accessoryView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[self addSubview:accessoryView];
}

@dynamic drawTextured;
- (BOOL)drawTextured {
	return [self.cell drawTextured];
}
- (void)setDrawTextured:(BOOL)drawTextured {
	[self.cell setDrawTextured:drawTextured];
}

+ (void)drawsTexturedByDefault:(BOOL)flag {
	if([self.cellClass respondsToSelector:_cmd])
		[self.cellClass drawsTexturedByDefault:flag];
}

- (NSTextVerticalAlignment)verticalAlignment {
	return [self.cell verticalAlignment];
}
- (void)setVerticalAlignment:(NSTextVerticalAlignment)verticalAlignment {
	[self.cell setVerticalAlignment:verticalAlignment];
}

+ (void)load {
	/*NSError *error = nil;
	 if(![NSTextField exchangeInstanceMethod:@selector(layout)
	 withMethod:@selector(BIN_layout)
	 error:&error]) {
	 NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	 }//*/
}

- (void)layoutSubviews { //BIN_layout
	if(self.accessoryView != nil) {
		self.accessoryView.frame = NSMakeRect(self.bounds.size.width - self.accessoryView.frame.size.width, 0,
											  self.accessoryView.frame.size.width, self.bounds.size.height);
	}
	//[self BIN_layout];
}

@end

@implementation NSTextFieldCell (BINExtensions)

+ (void)load {
	NSError *error = nil;
	if(![NSTextFieldCell exchangeInstanceMethod:@selector(drawInteriorWithFrame:inView:)
									 withMethod:@selector(BIN_drawInteriorWithFrame:inView:)
										  error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
	
	error = nil;
	if(![NSTextFieldCell exchangeInstanceMethod:@selector(selectWithFrame:inView:editor:delegate:start:length:)
									 withMethod:@selector(BIN_selectWithFrame:inView:editor:delegate:start:length:)
										  error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
	
	error = nil;
	if(![NSTextFieldCell exchangeInstanceMethod:@selector(endEditing:)
									 withMethod:@selector(BIN_endEditing:)
										  error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
	
	error = nil;
	if(![NSTextFieldCell exchangeInstanceMethod:@selector(drawingRectForBounds:)
									 withMethod:@selector(BIN_drawingRectForBounds:)
										  error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
	
	error = nil;
	if(![NSTextFieldCell exchangeInstanceMethod:@selector(titleRectForBounds:)
									 withMethod:@selector(BIN_titleRectForBounds:)
										  error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
	
	error = nil;
	if(![NSTextFieldCell exchangeInstanceMethod:@selector(drawWithFrame:inView:)
									 withMethod:@selector(BIN_drawWithFrame:inView:)
										  error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
}

BOOL _drawTextured = YES;
+ (void)drawsTexturedByDefault:(BOOL)flag {
	_drawTextured = flag;
}

@dynamic drawTextured;
static const char *drawTextured_key = "accessoryButton_key";
- (BOOL)drawTextured {
	return [objc_getAssociatedObject(self, drawTextured_key) boolValue];
}
- (void)setDrawTextured:(BOOL)drawTextured {
	objc_setAssociatedObject(self, drawTextured_key, @(drawTextured), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@dynamic verticalAlignment;
static const char *verticalAlignment_key = "verticalAlignment_key";
- (NSTextVerticalAlignment)verticalAlignment {
	return [objc_getAssociatedObject(self, verticalAlignment_key) unsignedIntegerValue];
}
- (void)setVerticalAlignment:(NSTextVerticalAlignment)verticalAlignment {
	objc_setAssociatedObject(self, verticalAlignment_key, @(verticalAlignment), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)BIN_drawInteriorWithFrame:(NSRect)bounds inView:(NSView *)controlView {
	if([controlView isKindOfClass:NSTextField.class] && [(NSTextField *)controlView accessoryView] != nil)
		bounds.size.width -= [(NSTextField *)controlView accessoryView].bounds.size.width + 4.0f;
	if(self.verticalAlignment == NSTextVerticalAlignmentTop)
		return [self BIN_drawInteriorWithFrame:bounds inView:controlView];
	
	NSAttributedString *attrString = self.attributedStringValue;
    if(self.isHighlighted && self.backgroundStyle==NSBackgroundStyleDark) {
        NSMutableAttributedString *whiteString = attrString.mutableCopy;
        [whiteString addAttribute:NSForegroundColorAttributeName
                            value:[NSColor whiteColor]
                            range:NSMakeRange(0, whiteString.length)];
        attrString = whiteString;
    }
	
    [attrString drawWithRect:[self titleRectForBounds:bounds]
                     options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin];
}

- (void)BIN_selectWithFrame:(NSRect)selectFrame inView:(NSView *)controlView editor:(NSText *)textObj
				   delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {
	if([controlView isKindOfClass:NSTextField.class] && [(NSTextField *)controlView accessoryView] != nil) {
		selectFrame.size.width -= [(NSTextField *)controlView accessoryView].bounds.size.width + 4.0f;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__textChanged:)
													 name:NSTextDidChangeNotification object:textObj];
	}
    [self BIN_selectWithFrame:selectFrame inView:controlView editor:textObj
					 delegate:anObject start:selStart length:selLength];
}

- (void)BIN_endEditing:(NSText *)editor {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTextDidChangeNotification object:editor];
    [self BIN_endEditing:editor];
}

- (void)__textChanged:(NSNotification *)note {
    [[self controlView] setNeedsDisplay:YES];
}

- (NSRect)BIN_titleRectForBounds:(NSRect)theRect {
    NSRect titleFrame = [self BIN_titleRectForBounds:theRect];
	if(self.verticalAlignment == NSTextVerticalAlignmentTop)
		return titleFrame;
	
    NSAttributedString *attrString = self.attributedStringValue;
    NSRect textRect = [attrString boundingRectWithSize:titleFrame.size
                                               options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin ];
    if(textRect.size.height < titleFrame.size.height) {
        titleFrame.origin.y = theRect.origin.y + (theRect.size.height - textRect.size.height) / 2.0;
        titleFrame.size.height = textRect.size.height;
    }
    return titleFrame;
}

- (BOOL)BIN_shouldDrawTextured {
	return ([[self.controlView.window.contentView subviews] containsObject:self.controlView] &&
			self.bezelStyle != NSTextFieldRoundedBezel && self.drawsBackground &&
			(self.drawTextured || _drawTextured));
}

- (NSRect)BIN_drawingRectForBounds:(NSRect)theRect {
	NSRect input = [self BIN_drawingRectForBounds:theRect];
	if([self BIN_shouldDrawTextured])
		input.origin.y -= 1.0f;
	return input;
}

- (void)BIN_drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	if(![self BIN_shouldDrawTextured]) {
		[self BIN_drawWithFrame:cellFrame inView:controlView];
		return;
	}
	
	static const CGFloat outlineCornerRadius = 3.6f;
	static const CGFloat innerShadowCornerRadius = 2.5f;
	static const CGFloat contentAreaCornerRadius = 2.6f;
	CGRect bounds = cellFrame;
	
	CGFloat down = 1.0f;
	NSRect hightlightFrame = NSMakeRect(0, 3.0f, bounds.size.width, bounds.size.height - 3.0f);
    [[NSColor colorWithCalibratedWhite:1.0f alpha:0.225f] set];
    [[NSBezierPath bezierPathWithRoundedRect:hightlightFrame xRadius:outlineCornerRadius
									 yRadius:outlineCornerRadius] fill];
	
    NSRect blackOutlineFrame = NSMakeRect(0, 0, bounds.size.width, bounds.size.height - down);
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.53f alpha:1.0f]
														 endingColor:[NSColor colorWithCalibratedWhite:0.68f alpha:1.0f]];
    [gradient drawInBezierPath:[NSBezierPath bezierPathWithRoundedRect:blackOutlineFrame
															   xRadius:3.6f yRadius:3.6f] angle:90.0f];
	
    NSRect whiteFrame = NSMakeRect(1.0f, 1.0f, bounds.size.width - 2.0f, bounds.size.height - down - 2.0f);
	[[NSColor whiteColor] set];
	[[NSBezierPath bezierPathWithRoundedRect:whiteFrame xRadius:contentAreaCornerRadius
									 yRadius:contentAreaCornerRadius] fill];
	
    NSRect shadowFrameTop = NSMakeRect(1.0f, 1.0f, cellFrame.size.width - 2.0f, down + 2.0f);
    NSRect shadowFrameLeft = NSMakeRect(1.0f, 1.0f, 2.5f, cellFrame.size.height - down - 2.0f);
    NSRect shadowFrameRight = NSMakeRect(cellFrame.size.width - 3.0f, 1.0f, 2.5f, cellFrame.size.height - down - 2.0f);
    NSRect shadowFrameBottom = NSMakeRect(1.0f, cellFrame.size.height - 3.0f, cellFrame.size.width - 2.0f, down);
	gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.0f alpha:0.065f]
											 endingColor:[NSColor colorWithCalibratedWhite:0.0f alpha:0.000f]];
	
	[gradient drawInBezierPath:[NSBezierPath bezierPathWithRoundedRect:shadowFrameTop
															   xRadius:innerShadowCornerRadius
															   yRadius:innerShadowCornerRadius] angle:90];
	[gradient drawInBezierPath:[NSBezierPath bezierPathWithRoundedRect:shadowFrameLeft
															   xRadius:innerShadowCornerRadius
															   yRadius:innerShadowCornerRadius] angle:0];
	[gradient drawInBezierPath:[NSBezierPath bezierPathWithRoundedRect:shadowFrameRight
															   xRadius:innerShadowCornerRadius
															   yRadius:innerShadowCornerRadius] angle:180];
	
	[[NSColor colorWithCalibratedWhite:0.0f alpha:0.025f] set];
    [[NSBezierPath bezierPathWithRoundedRect:shadowFrameBottom
									 xRadius:innerShadowCornerRadius
									 yRadius:innerShadowCornerRadius] fill];
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}

@end
