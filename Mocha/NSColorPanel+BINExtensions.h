/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <AppKit/NSColorPanel.h>

@interface NSColorPanel (BINExtensions)

// Display NSColorPanel in a context-aware popover from a given edge,
// instead of as a panel. It can also detach into a panel, itself.
- (void)popUpRelativeToView:(NSView *)view preferredEdge:(NSRectEdge)preferredEdge;

@end
