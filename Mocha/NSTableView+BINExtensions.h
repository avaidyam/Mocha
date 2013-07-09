/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <AppKit/NSTableView.h>

// This extension to NSTableView deprecates the .doubleAction property
// in favor of the informal protocol declaration below. It should be
// implemented by the table view's delegate, and it will be called
// instead of the double action set on the table view control's target.
@interface NSTableView (BINExtensions)

- (void)setDoubleAction:(SEL)aSelector DEPRECATED_ATTRIBUTE;
- (SEL)doubleAction DEPRECATED_ATTRIBUTE;

@end

@interface NSObject (NSTableViewDelegate_BINExtensions)

- (void)tableView:(NSTableView *)tableView didDoubleClickColumn:(NSInteger)column row:(NSInteger)row;

@end