#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

@interface NSAffineTransform (BINExtensions)

// Creates an CGAffineTransform struct with the transform of the reciever.
@property (nonatomic, readonly) CGAffineTransform CGAffineTransform;
 
// Creates an NSAffineTransform object with the passed CGAffineTransform.
+ (NSAffineTransform *)transformWithCGAffineTransform:(CGAffineTransform)transform;

@end
