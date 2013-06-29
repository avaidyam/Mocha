#import <AppKit/AppKit.h>
#import "NSObject+BINExtensions.h"

#if !MOCHA_10_9
typedef enum NSModalResponse : NSInteger {
    NSModalResponseOK		= 1,
    NSModalResponseCancel	= 0,
    NSModalResponseStop		= (-1000),
    NSModalResponseAbort	= (-1001),
    NSModalResponseContinue	= (-1002),
} NSModalResponse;
#endif

typedef void (^NSAlertCompletionHandler)(NSInteger);

@interface NSAlert (BINExtensions)

// Completion handler gets NSAlertDefaultReturn, NSAlertAlternateReturn, and NSAlertOtherReturn.
// Returns YES if could show popover.
- (BOOL)displayAnchoredToView:(NSView *)anchorView
					   onEdge:(NSRectEdge)anchorEdge
			completionHandler:(NSAlertCompletionHandler)handler;

/* Begins a sheet on the doc window using NSWindow's sheet API.
 If the alert has an alertStyle of NSCriticalAlertStyle, it will be shown as a "critical" sheet; it will otherwise be presented as a normal sheet.
 */
- (void)beginSheetModalForWindow:(NSWindow *)sheetWindow completionHandler:(void (^)(NSModalResponse returnCode))handler;

@end

@interface NSAlert (BINDeprecations)

+ (NSAlert *)alertWithMessageText:(NSString *)message
					defaultButton:(NSString *)defaultButton
				  alternateButton:(NSString *)alternateButton
					  otherButton:(NSString *)otherButton
		informativeTextWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(5,6) DEPRECATED_ATTRIBUTE;

- (void)beginSheetModalForWindow:(NSWindow *)window
				   modalDelegate:(id)delegate
				  didEndSelector:(SEL)didEndSelector
					 contextInfo:(void *)contextInfo DEPRECATED_ATTRIBUTE;

@end

@interface NSWindow (BINSheetExtensions)

/*
 If the window already has a presented sheet, it will queue up sheets presented after that. Once the presented sheet is dismissed, the next queued sheet will be presented, and so forth.
 Critical sheets will skip this queuing process and be immediately presented on top of existing sheets. The presented sheet will be temporarily disabled and be able to be interacted with after the critical sheet is dismissed, and will then continue as normal. Critical sheets should only be used for time-critical or important events, when the presentation of the sheet needs to be guaranteed (Critical Alerts will automatically use this API).
 */
- (void)beginSheet:(NSWindow *)sheetWindow completionHandler:(void (^)(NSModalResponse returnCode))handler;
- (void)beginCriticalSheet:(NSWindow *)sheetWindow completionHandler:(void (^)(NSModalResponse returnCode))handler;
- (void)endSheet:(NSWindow *)sheetWindow;
- (void)endSheet:(NSWindow *)sheetWindow returnCode:(NSModalResponse)returnCode;

- (NSArray *)sheets; // An ordered array of the sheets on the window. This consists of the presented sheets in top-to-bottom order, followed by queued sheets in the order they were queued. This does not include nested/sub-sheets.

/* Returns the window that the sheet is directly attached to. This is based on the logical attachment of the sheet, not appearance.
 This relationship exists starting when the sheet is begun (using NSApplication's -beginSheet:modalForWindow:modalDelegate:didEndSelector:contextInfo: or NSWindow's -beginSheet:completionHandler:), and ending once it is ordered out.
 
 Returns nil if the window is not a sheet or has no sheet parent.
 */
- (NSWindow *)sheetParent;

@end
