#import "NSColorPanel+BINExtensions.h"
#import <objc/runtime.h>

@class BFIconTabBarItem;
@class BFIconTabBar;

@protocol BFIconTabBarDelegate <NSObject>

- (void)tabBarChangedSelection:(BFIconTabBar *)tabbar;

@end


@interface BFIconTabBar : NSControl

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic) CGFloat itemWidth;
@property (nonatomic) BOOL multipleSelection;
@property (nonatomic, unsafe_unretained) IBOutlet id<BFIconTabBarDelegate> delegate;

- (BFIconTabBarItem *)selectedItem;
- (NSInteger)selectedIndex;
- (NSArray *)selectedItems;
- (NSIndexSet *)selectedIndexes;

- (IBAction)selectAll;
- (void)selectIndex:(NSUInteger)index;
- (void)selectItem:(BFIconTabBarItem *)item;
- (void)selectIndexes:(NSIndexSet *)indexes byExtendingSelection:(BOOL)extending;

- (IBAction)deselectAll;
- (void)deselectIndex:(NSUInteger)index;
- (void)deselectIndexes:(NSIndexSet *)indexes;

@end


@interface BFIconTabBarItem : NSObject

@property (nonatomic, strong) NSImage *icon;
@property (nonatomic, copy) NSString *tooltip;
@property (nonatomic, unsafe_unretained) BFIconTabBar *tabBar;

- (id)initWithIcon:(NSImage *)image tooltip:(NSString *)tooltipString;
+ (BFIconTabBarItem *)itemWithIcon:(NSImage *)image tooltip:(NSString *)tooltipString;

@end

@implementation NSColorPanel (BINExtensions)

- (void)popUpRelativeToView:(NSView *)aView preferredEdge:(NSRectEdge)preferredEdge {
	NSPopover *popover = [NSPopover new];
	popover.delegate = self;
	popover.behavior = NSPopoverBehaviorSemitransient;
	popover.contentViewController = [NSViewController new];
	
	NSRect popoverFrame = NSInsetRect([self.contentView bounds], 0.0f, -15.0f);
	NSRect toolbarFrame = NSMakeRect(0.0f, popoverFrame.size.height - 30.0f, popoverFrame.size.width, 30.0f);
	
	NSUInteger selectedIndex = 0;
	NSMutableArray *tabbarItems = @[].mutableCopy;
	for(NSToolbarItem *toolbarItem in self.toolbar.items) {
		[tabbarItems addObject:[[BFIconTabBarItem alloc] initWithIcon:toolbarItem.image
															  tooltip:toolbarItem.toolTip]];
		if([toolbarItem.itemIdentifier isEqualToString:self.toolbar.selectedItemIdentifier])
			selectedIndex = [self.toolbar.items indexOfObject:toolbarItem];
	}
	
	BFIconTabBar *tabbar = [[BFIconTabBar alloc] initWithFrame:toolbarFrame];
	tabbar.delegate = self;
	tabbar.items = tabbarItems;
	[tabbar selectIndex:selectedIndex];
	
	NSView *view = [[NSView alloc] initWithFrame:popoverFrame];
	[view addSubview:tabbar];
	[view addSubview:self.contentView];
	
	popover.contentViewController.view = view;
	[popover showRelativeToRect:aView.bounds ofView:aView preferredEdge:preferredEdge];
}

// Forward the selection action message to the color panel.
- (void)tabBarChangedSelection:(BFIconTabBar *)tabbar {
	if (tabbar.selectedIndex != -1)
	{
		NSToolbarItem *selectedItem = self.toolbar.items[(NSUInteger)tabbar.selectedIndex];
		SEL action = selectedItem.action;
		
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		
		[self performSelector:action withObject:selectedItem];
		
#pragma clang diagnostic pop
	}
}

- (NSWindow *)detachableWindowForPopover:(NSPopover *)popover {
	return self;
}

@end

@implementation BFIconTabBar {
	NSMutableIndexSet *_selectedIndexes;
	BFIconTabBarItem *_pressedItem;
	BOOL _firstItemWasSelected;
	BOOL _dragging;
}

@synthesize items = _items;
@synthesize itemWidth = _itemWidth;
@synthesize multipleSelection = _multipleSelection;
@synthesize delegate = _delegate;

#pragma mark -
#pragma mark Initialization & Destruction

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		_dragging = NO;
		_itemWidth = 32.0f;
		_multipleSelection = NO;
		_selectedIndexes = [[NSMutableIndexSet alloc] init];
		
    }
    return self;
}


#pragma mark -
#pragma mark Convenience Methods

// x coordinate of the first item.
- (CGFloat)startX {
	BOOL centered = NO;
	if (centered) {
		int itemCount = (int)[_items count];
		CGFloat totalWidth = itemCount * _itemWidth;
		CGFloat startX = (self.bounds.size.width - totalWidth) / 2.0f;
		return startX;
	} else {
		return 4.0f;
	}
}

- (BFIconTabBarItem *)itemAtX:(CGFloat)x {
	NSInteger index = floor((x - [self startX]) / _itemWidth);
	if (index >= 0 && index < (NSInteger)[_items count]) {
		return [_items objectAtIndex:(NSUInteger)index];
	}
	return nil;
}

#pragma mark -
#pragma mark Getters & Setters

- (NSMutableArray *)items {
	if (!_items) {
		_items = [NSMutableArray arrayWithCapacity:3];
	}
	return _items;
}

- (void)setItems:(NSArray *)newItems {
	if (newItems != _items) {
		_items = [NSMutableArray arrayWithArray:newItems];
		
		for (BFIconTabBarItem *item in _items) {
			item.tabBar = self;
		}
		
		if ([_selectedIndexes count] < 1) {
			[_selectedIndexes addIndex:0];
		}
		
		[self setNeedsDisplay];
	}
}

#pragma mark -
#pragma mark Selection

- (BFIconTabBarItem *)selectedItem {
	if ([_selectedIndexes count] > 0) {
		return [_items objectAtIndex:[_selectedIndexes firstIndex]];
	}
	return nil;
}

- (NSInteger)selectedIndex {
	return [_selectedIndexes count] < 1 ? -1 : (NSInteger)[_selectedIndexes firstIndex];
}

- (NSArray *)selectedItems {
	if ([_selectedIndexes count] > 0) {
		return [_items objectsAtIndexes:_selectedIndexes];
	}
	return nil;
}

- (NSIndexSet *)selectedIndexes {
	return [[NSIndexSet alloc] initWithIndexSet:_selectedIndexes];
}

- (void)setMultipleSelection:(BOOL)multiple {
	if (multiple != _multipleSelection) {
		_multipleSelection = multiple;
		if (!_multipleSelection && [_selectedIndexes count] > 1) {
			NSUInteger firstIndex = [_selectedIndexes firstIndex];
			[_selectedIndexes removeAllIndexes];
			[_selectedIndexes addIndex:firstIndex];
			[self setNeedsDisplay];
		}
	}
}

- (void)selectIndexes:(NSIndexSet *)indexes byExtendingSelection:(BOOL)extending {
	if (!indexes || [indexes count] < 1) {
		NSLog(@"Selection indexset empty.");
		return;
	}
	if (!extending || !_multipleSelection) {
		[self deselectAll];
	}
	if (_multipleSelection) {
		[_selectedIndexes addIndexes:indexes];
	} else {
		[_selectedIndexes addIndex:[indexes firstIndex]];
	}
	[self setNeedsDisplay];
}

- (void)selectIndex:(NSUInteger)index {
	[self selectIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:YES];
}

- (void)selectItem:(BFIconTabBarItem *)item {
	if ([_items containsObject:item]) {
		NSUInteger index = [_items indexOfObject:item];
		[self selectIndex:index];
	}
}

- (IBAction)selectAll {
	[_selectedIndexes addIndexesInRange:(NSRange){0, [_items count] - 1}];
	[self setNeedsDisplay];
}

- (void)deselectIndexes:(NSIndexSet *)indexes {
	if (!indexes || [indexes count] < 1) {
		NSLog(@"Deselection indexset empty.");
		return;
	}
	[_selectedIndexes removeIndexes:indexes];
	[self setNeedsDisplay];
}

- (void)deselectIndex:(NSUInteger)index {
	[self deselectIndexes:[NSIndexSet indexSetWithIndex:index]];
}

- (void)deselectItem:(BFIconTabBarItem *)item {
	if ([_items containsObject:item]) {
		NSUInteger index = [_items indexOfObject:item];
		[self deselectIndex:index];
	}
}

- (IBAction)deselectAll {
	[_selectedIndexes removeAllIndexes];
	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)dirtyRect
{
	
	//// Color Declarations
	NSColor* selectionGradientTop = [NSColor colorWithDeviceWhite:0.99 alpha:1.0];
	NSColor* selectionGradientBottom = [NSColor colorWithDeviceWhite:0.99 alpha:1.0];
	NSColor* lineColor = [NSColor colorWithDeviceWhite:0.7 alpha:1.0];
	
	//	if (![[self window] isKeyWindow])
	//	{
	//		selectionGradientTop = [NSColor colorWithCalibratedRed:0.961 green:0.961 blue:0.961 alpha:1.000];
	//		selectionGradientBottom = [NSColor colorWithCalibratedRed:0.855 green:0.855 blue:0.855 alpha:1.000];
	//		lineColor = [NSColor colorWithCalibratedRed:0.537 green:0.537 blue:0.537 alpha:1.000];
	//	}
	
	//// Prepare selection border gradients.
	
	//// Color Declarations
	NSColor* gradientOutsideTop = [NSColor colorWithDeviceWhite:0.9 alpha:1.0];
	NSColor* gradientOutsideMiddle = [NSColor colorWithDeviceWhite:0.6 alpha:1.0];
	NSColor* gradientOutsideBottom = [NSColor colorWithDeviceWhite:0.8 alpha:1.0];
	NSColor* gradientInsideTop = selectionGradientTop;
	NSColor* gradientInsideMiddle = [NSColor colorWithDeviceWhite:0.7 alpha:1.0];
	NSColor* gradientInsideBottom = selectionGradientBottom;
	NSColor* selectionGradientMiddle = [NSColor colorWithDeviceWhite:0.8 alpha:1.0];
	
	if (![self.window isKeyWindow]) {
		gradientOutsideTop = [NSColor colorWithDeviceWhite:0.83 alpha:1.0];
		gradientOutsideMiddle = [NSColor colorWithDeviceWhite:0.43 alpha:1.0];
		gradientOutsideBottom = [NSColor colorWithDeviceWhite:0.71 alpha:1.0];
		gradientInsideMiddle = [NSColor colorWithDeviceWhite:0.71 alpha:1.0];
		selectionGradientMiddle = [NSColor colorWithDeviceWhite:0.79 alpha:1.0];
	}
	
	NSGradient* selectionGradient = [[NSGradient alloc] initWithColorsAndLocations:
									 selectionGradientTop, 0.0,
									 selectionGradientMiddle, 0.50,
									 selectionGradientBottom, 1.0, nil];
	NSGradient* gradientOutside = [[NSGradient alloc] initWithColorsAndLocations:
								   gradientOutsideTop, 0.0,
								   gradientOutsideMiddle, 0.50,
								   gradientOutsideBottom, 1.0, nil];
	NSGradient* gradientInside = [[NSGradient alloc] initWithColorsAndLocations:
								  gradientInsideTop, 0.0,
								  gradientInsideMiddle, 0.50,
								  gradientInsideBottom, 1.0, nil];
	
	
	CGFloat startX = [self startX];
	[self removeAllToolTips];
	
	for (NSUInteger i = 0; i < [_items count]; i++) {
		BFIconTabBarItem *item = [_items objectAtIndex:i];
		CGFloat currentX = startX + i * _itemWidth;
		
		// Add tooltip area.
		NSRect selectionFrame = NSMakeRect(floorf(currentX + 0.5), 1, _itemWidth, self.bounds.size.height - 2);
		[self addToolTipRect:selectionFrame owner:item.tooltip userData:nil];
		
		if ([_selectedIndexes containsIndex:i]) {
			
			//// Draw selection gradients
			CGFloat gradientHeight = self.bounds.size.height - 2;
			NSRect outsideLineFrameLeft = NSMakeRect(floorf(currentX + 0.5), 1, 1, gradientHeight);
			NSRect insideLineFrameLeft = NSMakeRect(floorf(currentX + 1.5), 1, 1, gradientHeight);
			NSRect outsideLineFrameRight = NSMakeRect(floorf(currentX + _itemWidth + 0.5), 1, 1, gradientHeight);
			NSRect insideLineFrameRight = NSMakeRect(floorf(currentX + _itemWidth - 0.5), 1, 1, gradientHeight);
			
			NSBezierPath* selectionFramePath = [NSBezierPath bezierPathWithRect: selectionFrame];
			[selectionGradient drawInBezierPath: selectionFramePath angle: -90];
			
			NSBezierPath* outsideLinePathLeft = [NSBezierPath bezierPathWithRect: outsideLineFrameLeft];
			[gradientOutside drawInBezierPath: outsideLinePathLeft angle: -90];
			
			NSBezierPath* insideLinePathLeft = [NSBezierPath bezierPathWithRect: insideLineFrameLeft];
			[gradientInside drawInBezierPath: insideLinePathLeft angle: -90];
			
			NSBezierPath* outsideLinePathRight = [NSBezierPath bezierPathWithRect: outsideLineFrameRight];
			[gradientOutside drawInBezierPath: outsideLinePathRight angle: -90];
			
			NSBezierPath* insideLinePathRight = [NSBezierPath bezierPathWithRect: insideLineFrameRight];
			[gradientInside drawInBezierPath: insideLinePathRight angle: -90];
		}
		
		// Draw icon
		CGPoint center = CGPointMake(currentX + _itemWidth / 2.0f, self.bounds.size.height / 2.0f);
		
		NSImage *embossedImage = item.icon;
		
		CGRect fromRect = CGRectMake(0.0f, 0.0f, embossedImage.size.width, embossedImage.size.height);
		CGPoint position = CGPointMake(roundf(center.x - embossedImage.size.width / 2.0f), roundf(center.y - embossedImage.size.height / 2.0f));
		[embossedImage drawAtPoint:position fromRect:fromRect operation:NSCompositeSourceOver fraction:1.0f];
	}
	
	
	
	//// Line Drawing
	NSBezierPath* line1 = [NSBezierPath bezierPath];
	[line1 moveToPoint: NSMakePoint(0.0, 0.5)];
	[line1 lineToPoint: NSMakePoint(self.bounds.size.width, 0.5)];
	[lineColor setStroke];
	[line1 setLineWidth: 1];
	[line1 stroke];
}

#pragma mark -
#pragma mark Events

- (void)notify {
	[NSApp sendAction:[self action] to:[self target] from:self];
	if ([_delegate respondsToSelector:@selector(tabBarChangedSelection:)]) {
		[_delegate tabBarChangedSelection:self];
	}
}

- (void)mouseDown:(NSEvent *)theEvent {
	CGPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	BFIconTabBarItem *item = [self itemAtX:point.x];
	if (item) {
		_dragging = YES;
		_pressedItem = item;
		if (_multipleSelection) {
			// Remember if the first clicked item was selected or deselected. Dragging onto other items will do the same operation, if multipleSelection is enabled.
			_firstItemWasSelected = ![[self selectedItems] containsObject:_pressedItem];
			if (_firstItemWasSelected) {
				[self selectItem:_pressedItem];
			} else {
				[self deselectItem:_pressedItem];
			}
		} else {
			[self selectItem:_pressedItem];
		}
		[self notify];
		[self setNeedsDisplay];
	} else {
		[super mouseDown:theEvent];
	}
}

- (void)mouseDragged:(NSEvent *)theEvent {
	if (_dragging) {
		CGPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		BFIconTabBarItem *item = [self itemAtX:point.x];
		if (item != _pressedItem) {
			_pressedItem = item;
			if (_multipleSelection && !_firstItemWasSelected) {
				[self deselectItem:_pressedItem];
			} else {
				[self selectItem:_pressedItem];
			}
			[self notify];
			[self setNeedsDisplay];
		}
	} else {
		[super mouseDragged:theEvent];
	}
}

- (void)mouseUp:(NSEvent *)theEvent {
	if (_dragging) {
		_pressedItem = nil;
		_dragging = NO;
		[self setNeedsDisplay];
	} else {
		[super mouseUp:theEvent];
	}
}

@end

@implementation BFIconTabBarItem

- (id)initWithIcon:(NSImage *)image tooltip:(NSString *)tooltipString {
    self = [super init];
    if (self) {
        self.icon = image;
		self.tooltip = tooltipString;
    }
    return self;
}

+ (BFIconTabBarItem *)itemWithIcon:(NSImage *)image tooltip:(NSString *)tooltipString {
	return [[BFIconTabBarItem alloc] initWithIcon:image tooltip:tooltipString];
}

- (void)setIcon:(NSImage *)newIcon {
	if (newIcon != _icon) {
		_icon = newIcon;
		
		[_tabBar setNeedsDisplay];
	}
}

@end
