#import <AppKit/AppKit.h>

@interface NSColorPanel (BINExtensions) <NSPopoverDelegate>

- (void)popUpRelativeToView:(NSView *)view preferredEdge:(NSRectEdge)preferredEdge;

@end
