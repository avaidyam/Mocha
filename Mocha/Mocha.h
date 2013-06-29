
// Frameworks
#import <AppKit/AppKit.h>
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>

// Classes
#import "BINAnimation.h"
#import "NSSystemInfo.h"

// Foundation Categories
#import "NSAffineTransform+BINExtensions.h"
#import "NSCache+BINExtensions.h"
#import "NSObject+BINExtensions.h"
#import "NSString+BINExtensions.h"
#import "NSTimer+BINExtensions.h"
#import "NSUserDefaults+BINExtensions.h"
#import "NSUUID+BINExtensions.h"

// Quartz Categories
#import "CAAnimation+BINExtensions.h"
#import "CATransaction+BINExtensions.h"

// AppKit Graphics Categories
#import "NSBezierPath+BINExtensions.h"
#import "NSColor+BINExtensions.h"
#import "NSGradient+BINExtensions.h"
#import "NSImage+BINExtensions.h"
#import "NSShadow+BINExtensions.h"

// AppKit Control Categories
#import "NSControl+BINExtensions.h"
#import "NSSecureTextField+BINExtensions.h"
#import "NSTableView+BINExtensions.h"
#import "NSTextField+BINExtensions.h"
#import "NSTextView+BINExtensions.h"

// AppKit Display Categories
#import "NSAlert+BINExtensions.h"
#import "NSColorPanel+BINExtensions.h"
#import "NSPopover+BINExtensions.h"
#import "NSView+BINExtensions.h"
#import "NSWindow+BINExtensions.h"

extern void NSMoveToApplicationsFolderIfNecessary(NSString *firstRunUserDefaultsKey);

extern BOOL NSWillLaunchItemAtURLOnLogin(NSURL *itemURL, BOOL *hidden);
extern void NSLaunchItemAtURLOnLogin(NSURL *itemURL, BOOL enabled, BOOL hidden);

// Adds Modern Objective-C Booleans to OS X 10.7.
#if __has_feature(objc_bool) && (!defined(__MAC_10_8) || __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_8)
#undef YES
#define YES __objc_yes
#undef NO
#define NO __objc_no
#endif

// Adds Modern Objective-C Subscripting to OS X 10.7.
// The actual implementation of these methods is handled by the
// libarclite framework, and so they do not need to be implemented.
#if (!defined(__MAC_10_8) || __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_8) && \
(defined(__MAC_10_7) || __MAC_OS_X_VERSION_MIN_REQUIRED > __MAC_10_7)
@interface NSArray (BINIndexing)
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
@end

@interface NSMutableArray (BINIndexing)
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
@end

@interface NSDictionary (BINIndexing)
- (id)objectForKeyedSubscript:(id)key;
@end

@interface NSMutableDictionary (BINIndexing)
- (void)setObject:(id)obj forKeyedSubscript:(id)key;
@end
#endif

// These methods existed in AppKit since 10.7, but were made public
// and subsequently deprecated in 10.9. They are AppStore compatible.
@interface NSData (Base64)

- (id)initWithBase64Encoding:(NSString *)base64String;
- (NSString *)base64Encoding;

@end
