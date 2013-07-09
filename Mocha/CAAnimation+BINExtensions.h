/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <QuartzCore/CAAnimation.h>

typedef void (^CAAnimationStartHandler)(void);
typedef void (^CAAnimationCompletionHandler)(BOOL finished);

// CAAnimation support for start and completion handlers using blocks.
// If you use these handlers, setting the delegate may yeild issues.
@interface CAAnimation (BINExtensions)

@property (nonatomic, copy) CAAnimationStartHandler startHandler;
@property (nonatomic, copy) CAAnimationCompletionHandler completionHandler;

@end
