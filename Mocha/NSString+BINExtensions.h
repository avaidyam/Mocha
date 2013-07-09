/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <AppKit/AppKit.h>

@interface NSString (BINStringAmbivalentEquivalencyExtensions)

- (CGFloat)equivalencyToString:(NSString *)otherString;
- (CGFloat)equivalencyToString:(NSString *)otherString ambivalence:(CGFloat)ambivalence;
- (CGFloat)equivalencyToString:(NSString *)otherString ambivalence:(CGFloat)ambivalence
			 favorSmallerWords:(BOOL)favor reducePenaltyForLongerWords:(BOOL)reduce;

@end

@interface NSString (BINSymlinkAliasAdditions)

- (NSString *)stringByResolvingSymlinksAndAliases;
- (NSString *)stringByResolvingSymlink;
- (NSString *)stringByResolvingAlias;

@end
