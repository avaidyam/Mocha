#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>
#import "NSObject+BINExtensions.h"
#import "NSColor+BINExtensions.h"

@interface NSTextView (BINExtensions)

@property (nonatomic, assign) BOOL slideInsertionPoint;
@property (nonatomic, assign) BOOL flashInsertionPoint; // FIXME: Doesn't work properly.

@property (nonatomic, assign) CGFloat insertionPointWidth;
@property (nonatomic, strong) NSColor *insertionPointColor;

@end
