#import <AppKit/AppKit.h>

// Allows for pre-configuration and Interface Builder connection
// of popovers through convenience properties and methods.
@interface NSPopover (BINExtensions)

@property (nonatomic, weak) IBOutlet NSView *relativePositioningView;
@property (nonatomic, assign) NSRectEdge preferredEdge;

// Invokes -showRelativeToRect:ofView:preferredEdge: with IBAction
// support. If the .positioningRect property returns NSZeroRect,
// the bounds of the .relativePositioningView will be used.
- (IBAction)show:(id)sender;

// Opens the popover if it is not already open. Otherwise, it is closed.
- (IBAction)toggle:(id)sender;

@end
