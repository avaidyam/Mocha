#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

typedef void (^CAAnimationStartHandler)(void);
typedef void (^CAAnimationCompletionHandler)(BOOL finished);

@interface CAAnimation (BINExtensions)

@property (nonatomic, copy) CAAnimationStartHandler startHandler;
@property (nonatomic, copy) CAAnimationCompletionHandler completionHandler;

@end
