/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <Mocha/Mocha.h>

@interface BINAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) IBOutlet NSWindow *window;

- (IBAction)moveAround:(id)sender;
- (IBAction)animateOut:(id)sender;
- (IBAction)animateFrame:(id)sender;
- (IBAction)animateOutExplicitly:(id)sender;

@end
