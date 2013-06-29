#import <AppKit/AppKit.h>
#import "NSObject+BINExtensions.h"

@interface NSTableView (BINExtensions)

- (void)setDoubleAction:(SEL)aSelector DEPRECATED_ATTRIBUTE;
- (SEL)doubleAction DEPRECATED_ATTRIBUTE;

@end

@interface NSObject (NSTableViewDelegate_BINExtensions)

- (void)tableView:(NSTableView *)tableView didDoubleClickColumn:(NSInteger)column row:(NSInteger)row;

@end