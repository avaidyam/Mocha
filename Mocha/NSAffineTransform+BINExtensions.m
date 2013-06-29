#import "NSAffineTransform+BINExtensions.h"
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma clang diagnostic ignored "-Wobjc-property-implementation"
@implementation NSAffineTransform (BINExtensions)

+ (void)load {
	if(!class_getInstanceMethod(NSAffineTransform.class, @selector(CGAffineTransform))) {
		Method m = class_getInstanceMethod(NSAffineTransform.class, @selector(BIN_CGAffineTransform));
		class_addMethod(NSColor.class, @selector(CGAffineTransform),
						class_getMethodImplementation(NSAffineTransform.class, @selector(BIN_CGAffineTransform)),
						method_getTypeEncoding(m));
	}
	
	if(!class_getInstanceMethod(NSAffineTransform.class, @selector(transformWithCGAffineTransform:))) {
		Method m = class_getInstanceMethod(NSAffineTransform.class, @selector(BIN_transformWithCGAffineTransform:));
		class_addMethod(NSColor.class, @selector(transformWithCGAffineTransform:),
						class_getMethodImplementation(NSAffineTransform.class, @selector(BIN_transformWithCGAffineTransform:)),
						method_getTypeEncoding(m));
	}
}

+ (NSAffineTransform *)BIN_transformWithCGAffineTransform:(CGAffineTransform)transform {
	NSAffineTransform *affineTransform = [NSAffineTransform transform];
	affineTransform.transformStruct = (NSAffineTransformStruct) {
		.m11 = transform.a,
		.m12 = transform.b,
		.m21 = transform.c,
		.m22 = transform.d,
		.tX = transform.tx,
		.tY = transform.ty
	};
	return affineTransform;
}

- (CGAffineTransform)BIN_CGAffineTransform {
	NSAffineTransformStruct transform = self.transformStruct;
	return (CGAffineTransform) {
		.a = transform.m11,
		.b = transform.m12,
		.c = transform.m21,
		.d = transform.m22,
		.tx = transform.tX,
		.ty = transform.tY
	};
}
#pragma clang diagnostic pop

@end


