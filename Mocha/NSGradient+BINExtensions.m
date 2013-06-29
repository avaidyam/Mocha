#import "NSGradient+BINExtensions.h"

@implementation NSGradient (BINExtensions)

- (void)drawConicalInRect:(NSRect)rect {
	NSMutableArray *colors = @[].mutableCopy;
	NSMutableArray *locations = @[].mutableCopy;
	
	for(NSInteger i = 0, count = self.numberOfColorStops; i < count; i++) {
		NSColor *currColor = nil;
		CGFloat currLoc = 0;
		[self getColor:&currColor location:&currLoc atIndex:i];
		[colors addObject:currColor];
		[locations addObject:@(currLoc)];
	}
	
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	[NSGraphicsContext saveGraphicsState];
	CGContextDrawConicalGradient(ctx, rect, colors, locations);
	[NSGraphicsContext restoreGraphicsState];
}

- (void)drawConicalInBezierPath:(NSBezierPath *)path {
	NSMutableArray *colors = @[].mutableCopy;
	NSMutableArray *locations = @[].mutableCopy;
	
	for(NSInteger i = 0, count = self.numberOfColorStops; i < count; i++) {
		NSColor *currColor = nil;
		CGFloat currLoc = 0;
		[self getColor:&currColor location:&currLoc atIndex:i];
		[colors addObject:currColor];
		[locations addObject:@(currLoc)];
	}
	
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGRect rect = path.bounds;
	[NSGraphicsContext saveGraphicsState];
	[path setClip];
	CGContextDrawConicalGradient(ctx, rect, colors, locations);
	[NSGraphicsContext restoreGraphicsState];
}

@end

typedef unsigned char byte;
typedef unsigned int uint;

#define F2CC(x) ((byte)(255 * x))
#define RGBAF(r,g,b,a) (F2CC(r) << 24 | F2CC(g) << 16 | F2CC(b) << 8 | F2CC(a))
#define RGBA(r,g,b,a) ((byte)r << 24 | (byte)g << 16 | (byte)b << 8 | (byte)a)

#define RGBA_R(c) ((uint)c >> 24 & 255)
#define RGBA_G(c) ((uint)c >> 16 & 255)
#define RGBA_B(c) ((uint)c >> 8 & 255)
#define RGBA_A(c) ((uint)c >> 0 & 255)

static inline byte blerp(byte a, byte b, float w) {
	return a + w * (b - a);
}

static inline int lerp(int a, int b, float w) {
	return RGBA(blerp(RGBA_R(a), RGBA_R(b), w),
				blerp(RGBA_G(a), RGBA_G(b), w),
				blerp(RGBA_B(a), RGBA_B(b), w),
				blerp(RGBA_A(a), RGBA_A(b), w));
}

void CGContextDrawConicalGradient(CGContextRef context, CGRect rect, NSArray *colors, NSArray *locations) {
	int w = CGRectGetWidth(rect);
	int h = CGRectGetHeight(rect);
    
	int bitsPerComponent = 8;
	int bpp = 4 * bitsPerComponent / 8;
	int byteCount = w * h * bpp;
    
	int colorCount = (int)colors.count;
	int locationCount = 0;
	int* _colors = NULL;
	float* _locations = NULL;
    
	if(colorCount > 0) {
		_colors = calloc(colorCount, bpp);
		int *p = _colors;
        
		for(NSColor *c in colors) {
			CGFloat r, g, b, a;
			if(c.colorSpace.colorSpaceModel == NSRGBColorSpaceModel) {
				[c getRed:&r green:&g blue:&b alpha:&a];
			} else if(c.colorSpace.colorSpaceModel == NSGrayColorSpaceModel) {
				[c getWhite:&r alpha:&a];
				g = b = r;
			} else continue;
			*p++ = RGBAF(r, g, b, a);
		}
	}
    
	if(locations.count > 0 && locations.count == colorCount) {
		locationCount = (int)locations.count;
		_locations = calloc(locationCount, sizeof(_locations[0]));
        
		float *p = _locations;
		for(NSNumber *n in locations) {
			*p++ = [n floatValue];
		}
	}
    
	byte* data = malloc(byteCount);
    if(colorCount > 0 && locationCount > 0 && locationCount == colorCount) {
        int* p = (int *)data;
        float centerX = (float)w / 2;
        float centerY = (float)h / 2;
        
        for (int y = 0; y < h; y++)
            for (int x = 0; x < w; x++) {
                float dirX = x - centerX;
                float dirY = y - centerY;
                float angle = atan2f(dirY, dirX);
                
                if(dirY < 0)
                    angle += 2 * M_PI;
                angle /= 2 * M_PI;
                
                int index = 0, nextIndex = 0;
                float t = 0;
                
                if(locationCount > 0) {
                    for(index = locationCount - 1; index >= 0; index--) {
                        if(angle >= _locations[index])
                            break;
                    }
                    
                    if(index >= locationCount)
                        index = locationCount - 1;
                    nextIndex = index + 1;
                    if(nextIndex >= locationCount)
                        nextIndex = locationCount - 1;
                    
                    float ld = _locations[nextIndex] - _locations[index];
                    t = ld <= 0 ? 0 : (angle - _locations[index]) / ld;
                } else {
                    t = angle * (colorCount - 1);
                    index = t;
                    t -= index;
                    
                    nextIndex = index + 1;
                    if(nextIndex >= colorCount)
                        nextIndex = colorCount - 1;
                }
                
                int lc = _colors[index];
                int rc = _colors[nextIndex];
                int color = lerp(lc, rc, t);
                
                *p++ = color;
            }
    }
    
	if(_colors) free(_colors);
    if(_locations) free(_locations);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little;
    
    CGContextRef ctx = CGBitmapContextCreate(data, w, h, bitsPerComponent, w * bpp, colorSpace, bitmapInfo);
    CGImageRef img = CGBitmapContextCreateImage(ctx);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(ctx);
    free(data);
    
    CGContextDrawImage(context, rect, img);
    CGImageRelease(img);
}

void CGContextApplyNoise(CGContextRef context, CGRect rect, CGFloat opacity) {
    NSUInteger width = 128;
    NSUInteger height = 128;
    
    NSUInteger size = width * height;
    char *rgba = (char *)malloc(size);
    srand(124);
    
    for(NSUInteger i=0; i < size; ++i)
        rgba[i] = rand() % 256;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapContext = CGBitmapContextCreate(rgba, width, height, 8, width, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    CGImageRef image = CGBitmapContextCreateImage(bitmapContext);
    
    CFRelease(bitmapContext);
    CGColorSpaceRelease(colorSpace);
    free(rgba);
    
    
    CGContextSaveGState(context);
    CGContextClipToRect(context, rect);
    CGContextSetAlpha(context, opacity);
    CGContextSetBlendMode(context, kCGBlendModeScreen);
    
    CGRect imageRect = (CGRect){CGPointZero, CGImageGetWidth(image), CGImageGetHeight(image)};
    CGContextDrawTiledImage(context, imageRect, image);
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextRestoreGState(context);
    CGImageRelease(image);
}
