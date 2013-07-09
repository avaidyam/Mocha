/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import "NSColorPanel+BINExtensions.h"
#import <AppKit/NSViewController.h>
#import <AppKit/NSToolbar.h>
#import <AppKit/NSPopover.h>
#import <AppKit/NSToolbarItem.h>
#import "BINInspectorBar.h"
#import <objc/runtime.h>

@implementation NSColorPanel (BINExtensions)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)popUpRelativeToView:(NSView *)aView preferredEdge:(NSRectEdge)preferredEdge {
	NSPopover *popover = [NSPopover new];
	popover.delegate = (id<NSPopoverDelegate>)self;
	popover.behavior = NSPopoverBehaviorSemitransient;
	popover.contentViewController = [NSViewController new];
	
	NSRect popoverFrame = NSInsetRect([self.contentView bounds], 0.0f, -15.0f);
	NSRect toolbarFrame = NSMakeRect(0.0f, popoverFrame.size.height - 30.0f, popoverFrame.size.width, 30.0f);
	
	NSUInteger selectedIndex = 0;
	NSMutableArray *tabbarItems = @[].mutableCopy;
	for(NSToolbarItem *toolbarItem in self.toolbar.items) {
		[tabbarItems addObject:[[BINInspectorBarItem alloc] initWithIcon:toolbarItem.image
															  tooltip:toolbarItem.toolTip]];
		if([toolbarItem.itemIdentifier isEqualToString:self.toolbar.selectedItemIdentifier])
			selectedIndex = [self.toolbar.items indexOfObject:toolbarItem];
	}
	
	BINInspectorBar *tabbar = [[BINInspectorBar alloc] initWithFrame:toolbarFrame];
	tabbar.items = tabbarItems;
	[tabbar selectIndex:selectedIndex];
	
	__weak BINInspectorBar *__tabbar = (id)tabbar;
	tabbar.changedSelectionHandler = ^{
		if(__tabbar.selectedIndex != -1) {
			NSToolbarItem *selectedItem = self.toolbar.items[(NSUInteger)__tabbar.selectedIndex];
			SEL action = selectedItem.action;
			[self performSelector:action withObject:selectedItem];
		}
	};
	
	NSView *view = [[NSView alloc] initWithFrame:popoverFrame];
	[view addSubview:tabbar];
	[view addSubview:self.contentView];
	
	popover.contentViewController.view = view;
	[popover showRelativeToRect:aView.bounds ofView:aView preferredEdge:preferredEdge];
}
#pragma clang diagnostic pop

- (NSWindow *)detachableWindowForPopover:(NSPopover *)popover {
	return self;
}

@end
