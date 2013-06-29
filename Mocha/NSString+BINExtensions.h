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
