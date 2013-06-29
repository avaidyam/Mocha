#import "NSSecureTextField+BINExtensions.h"
#import <objc/runtime.h>

#define MD5(data, len, md) CC_MD5(data, len, md)
#define kNumberOfBars		3
#define kMinimumInputLength 6
#define kBarWidth			10
#define kBarPadding			2

static NSString* md5(NSString *string) {
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
	unsigned char digest[MD5_DIGEST_LENGTH];
	char finaldigest[2 * MD5_DIGEST_LENGTH];
	
	MD5(data.bytes, (unsigned)data.length, digest);
	for(int i = 0 ; i < MD5_DIGEST_LENGTH;i++)
		sprintf(finaldigest + i * 2, "%02x", digest[i]);
	
	return [[NSString alloc] initWithBytes:finaldigest
									length:(2 * MD5_DIGEST_LENGTH)
								  encoding:NSASCIIStringEncoding];
}

@interface NSColor (HexRGB)

+ (NSColor *)colorFromHexRGB:(NSString *)hexString;
+ (NSColor *)grayscaleFromHexRGB:(NSString *)hexString;

@end

@interface NSSecureTextField (BINExtensionsPrivate)

@property (nonatomic, assign) BOOL displayChromaHash;
@property (nonatomic, strong) NSMutableArray *colorBars;

@end

@implementation NSSecureTextField (BINExtensionsPrivate)

@dynamic displayChromaHash;
static const char *displayChromaHash_key = "displayChromaHash_key";
- (BOOL)displayChromaHash {
	return [objc_getAssociatedObject(self, displayChromaHash_key) boolValue];
}
- (void)setDisplayChromaHash:(BOOL)displayChromaHash {
	objc_setAssociatedObject(self, displayChromaHash_key, @(displayChromaHash), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	for(NSView *bar in self.colorBars)
		[self addSubview:bar];
}

@dynamic colorBars;
static const char *colorBars_key = "colorBars_key";
- (NSMutableArray *)colorBars {
	return objc_getAssociatedObject(self, colorBars_key);
}
- (void)setColorBars:(NSMutableArray *)colorBars {
	objc_setAssociatedObject(self, colorBars_key, colorBars, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation NSSecureTextField (BINExtensions)

+ (void)load {
	NSError *error = nil;
	if(![NSSecureTextField exchangeInstanceMethod:@selector(initWithFrame:)
									   withMethod:@selector(initWithFrame_BIN:)
											error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
	
	error = nil;
	if(![NSSecureTextField exchangeInstanceMethod:@selector(awakeFromNib)
									   withMethod:@selector(BIN_awakeFromNib)
											error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
	
	error = nil;
	if(![NSSecureTextField exchangeInstanceMethod:@selector(setFrame:)
									   withMethod:@selector(BIN_setFrame:)
											error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
	
	error = nil;
	if(![NSSecureTextField exchangeInstanceMethod:@selector(textDidChange:)
									   withMethod:@selector(BIN_textDidChange:)
											error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
	
	error = nil;
	if(![NSSecureTextField exchangeInstanceMethod:@selector(drawRect:)
									   withMethod:@selector(BIN_drawRect:)
											error:&error]) {
		NSLog(@"%@: %@", NSStringFromSelector(_cmd), error ?: @"unknown error!");
	}
}

- (id)initWithFrame_BIN:(NSRect)frameRect {
	if((self = [self initWithFrame_BIN:frameRect])) {
		[self BIN_setup];
	}
	return self;
}

- (void)BIN_awakeFromNib {
	[self BIN_awakeFromNib];
	[self BIN_setup];
}

extern BOOL _drawTextured;
- (void)BIN_setup {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		[NSProcessInfo processInfo]; // Prime the hostname.
	});
	
	self.colorBars = [[NSMutableArray alloc] initWithCapacity:kNumberOfBars];
	self.backgroundColor = [NSColor clearColor];
	
	for(int i = 0; i < kNumberOfBars; i++) {
		NSRect bounds = NSMakeRect(self.bounds.origin.x + self.bounds.size.width - (1 + i) * kBarWidth - kBarPadding,
								   self.bounds.origin.y + kBarPadding, kBarWidth, self.bounds.size.height - kBarPadding * 2);
		if([self.cell drawTextured] || _drawTextured)
			bounds.size.height -= 1.0f;
		
		NSView *bar = [[NSView alloc] initWithFrame:bounds];
		bar.wantsLayer = YES;
		
		[self.colorBars insertObject:bar atIndex:i];
		if(self.displayChromaHash)
			[self addSubview:bar];
	}
}

- (void)BIN_setFrame:(NSRect)frameRect {
	[self BIN_setFrame:frameRect];
	
	for(int i = 0; i < self.colorBars.count; i++) {
		NSRect bounds = NSMakeRect(self.bounds.origin.x + self.bounds.size.width - (1 + i) * kBarWidth - kBarPadding,
								   self.bounds.origin.y + kBarPadding, kBarWidth, self.bounds.size.height - kBarPadding * 2);
		[self.colorBars[i] setFrame:bounds];
	}
}

- (void)BIN_textDidChange:(NSNotification *)notification {
	[self BIN_textDidChange:notification];
	
	NSString *value = [(id)notification.object string];
	NSString *salt = [[NSProcessInfo processInfo] hostName];
	NSString *hash = md5([salt stringByAppendingString:value]);
	
	[CATransaction begin];
	NSInteger index = 0;
	for(NSView *bar in self.colorBars) {
		NSString *hex = [hash substringWithRange:NSMakeRange(index += 6, 6)];
		
		NSColor *endColor;
		if(value.length == 0)
			endColor = [NSColor clearColor];
		else if(value.length < kMinimumInputLength)
			endColor = [NSColor grayscaleFromHexRGB:hex];
		else endColor = [NSColor colorFromHexRGB:hex];
		
		CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
		anim.toValue = (id)endColor.CGColor;
		anim.removedOnCompletion = NO;
		anim.fillMode = kCAFillModeForwards;
		anim.completionHandler = ^(BOOL f){if(f){
			bar.layer.backgroundColor = endColor.CGColor;
		}};
		[bar.layer addAnimation:anim forKey:@"chroma-hash"];
	}
	[CATransaction commit];
}

- (void)BIN_drawRect:(NSRect)dirtyRect {
	if(self.displayChromaHash)
		for(NSView *bar in self.colorBars)
			[self addSubview:bar];
	[self BIN_drawRect:dirtyRect];
}

@end

@implementation NSColor (HexRGB)

+ (NSColor *)colorFromHexRGB:(NSString *)hexString {
	NSUInteger colorCode = 0;
	if(hexString != nil)
		[[NSScanner scannerWithString:hexString] scanHexInt:(unsigned *)&colorCode];
	
	return [NSColor colorWithCalibratedRed:(CGFloat)(((uint8_t)(colorCode >> 16)) >> 4) / 0x10
									 green:(CGFloat)(((uint8_t)(colorCode >> 8))  >> 4) / 0x10
									  blue:(CGFloat)(((uint8_t)(colorCode))		  >> 4) / 0x10
									 alpha:1.0f];
}

+ (NSColor *)grayscaleFromHexRGB:(NSString *)hexString {
	NSUInteger colorCode = 0;
	if(hexString != nil)
		[[NSScanner scannerWithString:hexString] scanHexInt:(unsigned *)&colorCode];
	
	return [NSColor colorWithCalibratedWhite:(CGFloat)(colorCode % 0xff) / 0xff
									   alpha:1.0];
}

@end
