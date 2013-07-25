/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <AppKit/NSControl.h>
#import <AppKit/NSCell.h>
#import <AppKit/NSButtonCell.h>

// Allows Interface Builder support for setting internal cell properties.
// Although the cell itself can be accessed from within IB, these
// extensions can extend even NSTableViews, etc, being NSControl subclasses.
@interface NSControl (BINExtensions)

@property (nonatomic, strong) IBOutlet id representedObject;
@property (nonatomic, assign) NSBackgroundStyle backgroundStyle;

@end

@interface NSCell (BINExtensions)

// Allow the representedObject of a cell to be set from within IB, and
// make it a property visible to the objective-c runtime.
@property (nonatomic, strong) IBOutlet id representedObject;

@end


