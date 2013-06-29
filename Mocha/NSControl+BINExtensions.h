#import <AppKit/AppKit.h>

@interface NSControl (BINExtensions)

@property (nonatomic, strong) IBOutlet id representedObject;
@property (nonatomic, assign) NSBackgroundStyle backgroundStyle;

@end

@interface NSCell (BINExtensions)

@property (nonatomic, strong) IBOutlet id representedObject;

@end
