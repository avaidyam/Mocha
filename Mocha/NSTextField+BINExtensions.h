#import <AppKit/AppKit.h>
#import "NSObject+BINExtensions.h"

typedef enum NSTextVerticalAlignment : NSUInteger {
    NSTextVerticalAlignmentTop		= 0,
    NSTextVerticalAlignmentMiddle	= 1,
    NSTextVerticalAlignmentBottom DEPRECATED_ATTRIBUTE	= 2,
} NSTextVerticalAlignment;

@interface NSTextField (BINExtensions)

+ (void)drawsTexturedByDefault:(BOOL)flag; // Default YES

@property (nonatomic, assign) BOOL drawTextured;
@property (nonatomic, assign) NSTextVerticalAlignment verticalAlignment;
@property (nonatomic, strong) IBOutlet NSView *accessoryView;

@end

@interface NSTextFieldCell (BINExtensions)

+ (void)drawsTexturedByDefault:(BOOL)flag; // Default YES

@property (nonatomic, assign) BOOL drawTextured;
@property (nonatomic, assign) NSTextVerticalAlignment verticalAlignment;

@end
