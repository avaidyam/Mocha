/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <AppKit/NSTextField.h>
#import <AppKit/NSTextFieldCell.h>
#import "NSObject+BINExtensions.h"

// Possible values for the vertical alignment of a text field.
// "Top" displays the text visually at the top of the field.
// "Middle" displays the text visually vertically centered.
// "Bottom" displays the text visually at the bottom of the field.
typedef enum NSTextVerticalAlignment : NSUInteger {
	NSTextVerticalAlignmentTop,
	NSTextVerticalAlignmentMiddle,
	NSTextVerticalAlignmentBottom,
} NSTextVerticalAlignment;

@interface NSTextField (BINExtensions)

// The following properties assign the text field's cell's properties
// of the same name. See below for more information.
@property (nonatomic, assign) BOOL drawTextured;
@property (nonatomic, assign) NSTextVerticalAlignment verticalAlignment;

// Allows the assignment of an accessory view that can sit "cushioned"
// to the right edge of the text field, or a variable width.
@property (nonatomic, strong) IBOutlet NSView *accessoryView;

@end

@interface NSTextFieldCell (BINExtensions)

// This global flag forces the "textured" style text field cell
// to be drawn for all possible cases (see more below).
+ (void)drawsTexturedByDefault:(BOOL)flag;

// The text field cell will be drawn with rounded corners and an inner
// shadowed, textured style. This is only applicable if the cell's bezel
// is NSTextFieldSquareBezel, and .drawsBackground returns YES.
@property (nonatomic, assign) BOOL drawTextured;

// The vertical alignment of a text field cell.
// See NSTextVerticalAlignment for more information on possible alignments.
@property (nonatomic, assign) NSTextVerticalAlignment verticalAlignment;

@end
