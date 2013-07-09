/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import "BINAnimation.h"

#define kBINAnimationFramerate 1.0/60
#define setterFromProperty(property) NSSelectorFromString([NSString stringWithFormat:@"set%@:",[property stringByReplacingCharactersInRange:NSMakeRange(0, 1)withString:[[property substringToIndex:1] capitalizedString]]])

static NSArray *animationSelectorsForCoreAnimation = nil;
static NSArray *animationSelectorsForNSView = nil;

@interface BINAnimationOperation ()
@property (nonatomic) BOOL canUseBuiltAnimation;
@end

@interface BINAnimation ()
@property (nonatomic, assign, readwrite) CGFloat timeOffset;
- (void)update;
@end

@implementation BINAnimationPeriod

+ (instancetype)periodWithStartValue:(CGFloat)aStartValue endValue:(CGFloat)anEndValue
							duration:(CGFloat)duration {
	BINAnimationPeriod *period = [self.class new];
	period.startValue = period.animatedValue = aStartValue;
	period.endValue = anEndValue;
	period.duration = duration;
	period.startOffset = [[BINAnimation sharedInstance] timeOffset];
	return period;
}

@end

@implementation BINAnimationLerpPeriod

+ (instancetype)periodWithStartValue:(NSValue *)aStartValue
							endValue:(NSValue *)anEndValue
							duration:(CGFloat)duration {
	BINAnimationLerpPeriod *period = [self.class new];
	period.startLerp = aStartValue;
	period.animatedLerp = aStartValue;
	period.endLerp = anEndValue;
	period.duration = duration;
	period.startOffset = [[BINAnimation sharedInstance] timeOffset];
	return period;
}

@end

@implementation BINAnimationPointLerpPeriod

+ (instancetype)periodWithStartPoint:(CGPoint)aStartPoint
							endPoint:(CGPoint)anEndPoint
							duration:(CGFloat)duration {
	return [BINAnimationPointLerpPeriod periodWithStartValue:[NSValue valueWithPoint:aStartPoint]
													endValue:[NSValue valueWithPoint:anEndPoint]
													duration:duration];
}

- (CGPoint)startPoint {
	return [self.startLerp pointValue];
}

- (CGPoint)animatedPoint {
	return [self.animatedLerp pointValue];
}

- (CGPoint)endPoint {
	return [self.endLerp pointValue];
}

- (NSValue *)animatedValueForProgress:(CGFloat)progress {
	CGPoint startPoint = self.startPoint;
	CGPoint endPoint = self.endPoint;
	CGPoint distance = CGPointMake(endPoint.x - startPoint.x,
								   endPoint.y - startPoint.y);
	CGPoint animatedPoint = CGPointMake(startPoint.x + distance.x * progress,
									   startPoint.y + distance.y * progress);
	return [NSValue valueWithPoint:animatedPoint];
}

- (void)setProgress:(CGFloat)progress {
	self.animatedLerp = [self animatedValueForProgress:progress];
}

@end

@implementation BINAnimationSizeLerpPeriod

+ (instancetype)periodWithStartSize:(CGSize)aStartSize
							endSize:(CGSize)anEndSize
						   duration:(CGFloat)duration {
	return [BINAnimationSizeLerpPeriod periodWithStartValue:[NSValue valueWithSize:aStartSize]
												   endValue:[NSValue valueWithSize:anEndSize]
												   duration:duration];
}

- (CGSize)startSize {
	return [self.startLerp sizeValue];
}

- (CGSize)animatedSize {
	return [self.animatedLerp sizeValue];
}

- (CGSize)endSize {
	return [self.endLerp sizeValue];
}

- (NSValue *)animatedValueForProgress:(CGFloat)progress {
	CGSize startSize = self.startSize;
	CGSize endSize = self.endSize;
	CGSize distance = CGSizeMake(endSize.width - startSize.width,
								 endSize.height - startSize.height);
	CGSize animatedSize = CGSizeMake(startSize.width + distance.width * progress,
									startSize.height + distance.height * progress);
	return [NSValue valueWithSize:animatedSize];
}

- (void)setProgress:(CGFloat)progress {
	self.animatedLerp = [self animatedValueForProgress:progress];
}

@end

@implementation BINAnimationRectLerpPeriod

+ (instancetype)periodWithStartRect:(CGRect)aStartRect
							endRect:(CGRect)anEndRect
						   duration:(CGFloat)duration {
	return [BINAnimationRectLerpPeriod periodWithStartValue:[NSValue valueWithRect:aStartRect]
												   endValue:[NSValue valueWithRect:anEndRect]
												   duration:duration];
}

- (CGRect)startRect {
	return [self.startLerp rectValue];
}

- (CGRect)animatedRect {
	return [self.animatedLerp rectValue];
}

- (CGRect)endRect {
	return [self.endLerp rectValue];
}

- (NSValue *)animatedValueForProgress:(CGFloat)progress {
	CGRect startRect = self.startRect;
	CGRect endRect = self.endRect;
	CGRect distance = CGRectMake(endRect.origin.x - startRect.origin.x,
								 endRect.origin.y - startRect.origin.y,
								 endRect.size.width - startRect.size.width,
								 endRect.size.height - startRect.size.height);
	CGRect animatedRect = CGRectMake(startRect.origin.x + distance.origin.x * progress,
									startRect.origin.y + distance.origin.y * progress,
									startRect.size.width + distance.size.width * progress,
									startRect.size.height + distance.size.height * progress);
	return [NSValue valueWithRect:animatedRect];
}

- (void)setProgress:(CGFloat)progress {
	self.animatedLerp = [self animatedValueForProgress:progress];
}

@end

@implementation BINAnimationOperation
@end

@implementation BINAnimation {
	NSMutableArray *animationOperations;
	NSMutableArray *expiredanimationOperations;
	CVDisplayLinkRef displayLink;
}

+ (BINAnimation *)sharedInstance {
	static BINAnimation *_sharedInstance = nil;
	if (_sharedInstance == nil) {
		_sharedInstance = [BINAnimation new];
		_sharedInstance.useBuiltInAnimationsWhenPossible = YES;
	}
	return _sharedInstance;
}

+ (BINAnimationOperation *)animate:(id)object property:(NSString *)property
							from:(CGFloat)from to:(CGFloat)to duration:(CGFloat)duration
				  timingFunction:(BINAnimationTimingFunction)timingFunction
						  target:(NSObject *)target completeSelector:(SEL)selector {
	
	BINAnimationPeriod *period = [BINAnimationPeriod periodWithStartValue:from endValue:to duration:duration];
	BINAnimationOperation *operation = [BINAnimationOperation new];
	operation.period = period;
	operation.timingFunction = timingFunction;
	operation.target = target;
	operation.completeSelector = selector;
	operation.boundObject = object;
	operation.boundGetter = NSSelectorFromString([NSString stringWithFormat:@"%@", property]);
	operation.boundSetter = setterFromProperty(property);
	[operation addObserver:[BINAnimation sharedInstance] forKeyPath:@"period.animatedValue"
				   options:NSKeyValueObservingOptionNew context:NULL];
	
	[[BINAnimation sharedInstance] performSelector:@selector(addAnimationOperation:)
										withObject:operation afterDelay:0];
	return operation;
}

+ (BINAnimationOperation *)animate:(CGFloat *)ref from:(CGFloat)from to:(CGFloat)to
						duration:(CGFloat)duration
				  timingFunction:(BINAnimationTimingFunction)timingFunction
						  target:(NSObject *)target completeSelector:(SEL)selector {
	
	BINAnimationPeriod *period = [BINAnimationPeriod periodWithStartValue:from endValue:to duration:duration];
	BINAnimationOperation *operation = [BINAnimationOperation new];
	operation.period = period;
	operation.timingFunction = timingFunction;
	operation.target = target;
	operation.completeSelector = selector;
	operation.boundRef = ref;
	[operation addObserver:[BINAnimation sharedInstance] forKeyPath:@"period.animatedValue"
				   options:NSKeyValueObservingOptionNew context:NULL];
	
	[[BINAnimation sharedInstance] performSelector:@selector(addAnimationOperation:)
										withObject:operation afterDelay:0];
	return operation;
}

+ (BINAnimationOperation *)animate:(id)object property:(NSString*)property
							from:(CGFloat)from to:(CGFloat)to duration:(CGFloat)duration {
	return [BINAnimation animate:object property:property from:from to:to duration:duration
				timingFunction:NULL target:nil completeSelector:NULL];
}

+ (BINAnimationOperation *)animate:(CGFloat *)ref from:(CGFloat)from
							  to:(CGFloat)to duration:(CGFloat)duration {
	return [BINAnimation animate:ref from:from to:to duration:duration
				timingFunction:NULL target:nil completeSelector:NULL];
}

+ (BINAnimationOperation *)lerp:(id)object property:(NSString *)property
						 period:(BINAnimationLerpPeriod <BINAnimationLerpPeriod> *)period
				 timingFunction:(BINAnimationTimingFunction)timingFunction
						 target:(NSObject *)target completeSelector:(SEL)selector {
	
	BINAnimationOperation *operation = [BINAnimationOperation new];
	operation.period = period;
	operation.timingFunction = timingFunction;
	operation.target = target;
	operation.completeSelector = selector;
	operation.boundObject = object;
	operation.boundGetter = NSSelectorFromString([NSString stringWithFormat:@"%@", property]);
	operation.boundSetter = setterFromProperty(property);
	[operation addObserver:[BINAnimation sharedInstance] forKeyPath:@"period.animatedLerp"
				   options:NSKeyValueObservingOptionNew context:NULL];
	
	[[BINAnimation sharedInstance] performSelector:@selector(addAnimationOperation:)
										withObject:operation afterDelay:0];
	return operation;
}


+ (BINAnimationOperation *)animate:(id)object property:(NSString *)property
							from:(CGFloat)from to:(CGFloat)to duration:(CGFloat)duration
				  timingFunction:(BINAnimationTimingFunction)timingFunction
					 updateBlock:(BINAnimationUpdateBlock)updateBlock
				   completeBlock:(BINAnimationCompleteBlock)completeBlock {
	
	BINAnimationPeriod *period = [BINAnimationPeriod periodWithStartValue:from endValue:to duration:duration];
	BINAnimationOperation *operation = [BINAnimationOperation new];
	operation.period = period;
	operation.timingFunction = timingFunction;
	operation.updateBlock = updateBlock;
	operation.completeBlock = completeBlock;
	operation.boundObject = object;
	operation.boundGetter = NSSelectorFromString([NSString stringWithFormat:@"%@", property]);
	operation.boundSetter = setterFromProperty(property);
	[operation addObserver:[BINAnimation sharedInstance] forKeyPath:@"period.animatedValue"
				   options:NSKeyValueObservingOptionNew context:NULL];
	
	[[BINAnimation sharedInstance] performSelector:@selector(addAnimationOperation:)
										withObject:operation afterDelay:0];
	return operation;
}

+ (BINAnimationOperation *)animate:(CGFloat *)ref from:(CGFloat)from
							  to:(CGFloat)to duration:(CGFloat)duration
				  timingFunction:(BINAnimationTimingFunction)timingFunction
					 updateBlock:(BINAnimationUpdateBlock)updateBlock
				   completeBlock:(BINAnimationCompleteBlock)completeBlock {
	
	BINAnimationPeriod *period = [BINAnimationPeriod periodWithStartValue:from endValue:to duration:duration];
	BINAnimationOperation *operation = [BINAnimationOperation new];
	operation.period = period;
	operation.timingFunction = timingFunction;
	operation.updateBlock = updateBlock;
	operation.completeBlock = completeBlock;
	operation.boundRef = ref;
	[operation addObserver:[BINAnimation sharedInstance] forKeyPath:@"period.animatedValue"
				   options:NSKeyValueObservingOptionNew context:NULL];
	
	[[BINAnimation sharedInstance] performSelector:@selector(addAnimationOperation:)
										withObject:operation afterDelay:0];
	return operation;
}

+ (BINAnimationOperation *)lerp:(id)object property:(NSString *)property
						 period:(BINAnimationLerpPeriod <BINAnimationLerpPeriod> *)period
				 timingFunction:(BINAnimationTimingFunction)timingFunction
					updateBlock:(BINAnimationUpdateBlock)updateBlock
				  completeBlock:(BINAnimationCompleteBlock)completeBlock {
	
	BINAnimationOperation *operation = [BINAnimationOperation new];
	operation.period = period;
	operation.timingFunction = timingFunction;
	operation.updateBlock = updateBlock;
	operation.completeBlock = completeBlock;
	operation.boundObject = object;
	operation.boundGetter = NSSelectorFromString([NSString stringWithFormat:@"%@", property]);
	operation.boundSetter = setterFromProperty(property);
	[operation addObserver:[BINAnimation sharedInstance] forKeyPath:@"period.animatedLerp"
				   options:NSKeyValueObservingOptionNew context:NULL];
	
	[[BINAnimation sharedInstance] performSelector:@selector(addAnimationOperation:)
										withObject:operation afterDelay:0];
	return operation;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change context:(void *)context {
	BINAnimationOperation *operation = (BINAnimationOperation *)object;
	
	if([operation.period isKindOfClass:[BINAnimationLerpPeriod class]]) {
		BINAnimationLerpPeriod *lerpPeriod = (BINAnimationLerpPeriod *)operation.period;
		
		NSUInteger bufferSize = 0;
		NSGetSizeAndAlignment([lerpPeriod.animatedLerp objCType], &bufferSize, NULL);
		void *animatedValue = malloc(bufferSize);
		[lerpPeriod.animatedLerp getValue:animatedValue];
		
		if(operation.boundObject && [operation.boundObject respondsToSelector:operation.boundGetter] &&
		   [operation.boundObject respondsToSelector:operation.boundSetter]) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[operation.boundObject class] instanceMethodSignatureForSelector:operation.boundSetter]];
			
			[invocation setTarget:operation.boundObject];
			[invocation setSelector:operation.boundSetter];
			[invocation setArgument:animatedValue atIndex:2];
			[invocation invoke];
		}
		
		free(animatedValue);
	} else {
		CGFloat animatedValue = operation.period.animatedValue;
		
		if(operation.boundObject && [operation.boundObject respondsToSelector:operation.boundGetter] &&
		   [operation.boundObject respondsToSelector:operation.boundSetter]) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[operation.boundObject class] instanceMethodSignatureForSelector:operation.boundSetter]];
			
			[invocation setTarget:operation.boundObject];
			[invocation setSelector:operation.boundSetter];
			[invocation setArgument:&animatedValue atIndex:2];
			[invocation invoke];
		} else if(operation.boundRef) {
			*operation.boundRef = animatedValue;
		}
	}
}

static CVReturn updateCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *now,
							   const CVTimeStamp *outputTime, CVOptionFlags flagsIn,
							   CVOptionFlags *flagsOut, void *displayLinkContext) {
	@autoreleasepool {
		[(__bridge id)displayLinkContext performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:NO];
	}
	return kCVReturnSuccess;
}

- (id)init {
	if((self = [super init])) {
		animationOperations = @[].mutableCopy;
		expiredanimationOperations = @[].mutableCopy;
		
		self.defaultTimingFunction = &BINAnimationTimingFunctionQuadInOut;
		self.timeOffset = 0;
		
		if(displayLink == nil) {
			CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
			CVDisplayLinkSetOutputCallback(displayLink, &updateCallback, (__bridge void *)self);
			CVDisplayLinkSetCurrentCGDisplay(displayLink, kCGDirectMainDisplay);
		}
		CVDisplayLinkStart(displayLink);
	}
	return self;
}

- (BINAnimationOperation *)addAnimationOperation:(BINAnimationOperation*)operation {
	if(self.useBuiltInAnimationsWhenPossible && !operation.override) {
		if(animationSelectorsForCoreAnimation == nil) {
			animationSelectorsForCoreAnimation = @[@"setBounds:",				// CGRect
												   @"setPosition:",				// CGPoint
												   @"setZPosition:",			// CGFloat
												   @"setAnchorPoint:",			// CGPoint
												   @"setAnchorPointZ:",			// CGFloat
												   //@"setTransform:",			// CATransform3D
												   //@"setSublayerTransform:",	// CATransform3D
												   @"setFrame:",				// CGRect
												   @"setContentsRect"			// CGRect
												   @"setContentsScale:",		// CGFloat
												   @"setContentsCenter:",		// CGPoint
												   //@"setBackgroundColor:",	// CGColorRef
												   @"setCornerRadius:",			// CGFloat
												   @"setBorderWidth:",			// CGFloat
												   @"setOpacity:",				// CGFloat
												   //@"setShadowColor:",		// CGColorRef
												   @"setShadowOpacity:",		// CGFloat
												   @"setShadowOffset:",			// CGSize
												   @"setShadowRadius:"			/*CGFloat*/];
		}
		
		if(animationSelectorsForNSView == nil) {
			animationSelectorsForNSView = @[@"setFrame:",				// CGRect
											@"setBounds:",				// CGRect
											@"setCenter:",				// CGPoint
											@"setTransform:",			// CGAffineTransform
											@"setAlphaValue:",			// CGFloat
											//@"setBackgroundColor:",	// UIColor
											@"setContentStretch:"		/*CGRect*/];
		}
		
		if(operation.boundSetter && operation.boundObject && !(operation.timingFunction == &BINAnimationTimingFunctionCAEaseIn ||
															   operation.timingFunction == &BINAnimationTimingFunctionCAEaseOut ||
															   operation.timingFunction == &BINAnimationTimingFunctionCAEaseInOut ||
															   operation.timingFunction == &BINAnimationTimingFunctionCALinear ||
															   operation.timingFunction == NULL)) {
			goto complete;
		}
		
		if(operation.boundSetter && operation.boundObject && [operation.boundObject isKindOfClass:[CALayer class]]) {
			for(NSString *selector in animationSelectorsForCoreAnimation) {
				NSString *setter = NSStringFromSelector(operation.boundSetter);
				
				if ([selector isEqualToString:setter]) {
					NSLog(@"Using Core Animation for %@", NSStringFromSelector(operation.boundSetter));
					operation.canUseBuiltAnimation = YES;
					
					NSString *propertyUnformatted = [selector stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
					NSString *propertyFormatted = [[propertyUnformatted stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[propertyUnformatted substringToIndex:1] lowercaseString]] substringToIndex:[propertyUnformatted length] - 1];
					
					CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:propertyFormatted];
					animation.duration = operation.period.duration;
					
					if (![operation.period isKindOfClass:[BINAnimationLerpPeriod class]] &&
						![operation.period conformsToProtocol:@protocol(BINAnimationLerpPeriod)]) {
						animation.fromValue = [NSNumber numberWithFloat:operation.period.startValue];
						animation.toValue = [NSNumber numberWithFloat:operation.period.endValue];
					} else {
						BINAnimationLerpPeriod *period = (BINAnimationLerpPeriod *)operation.period;
						animation.fromValue = period.startLerp;
						animation.toValue = period.endLerp;
					}
					
					if (operation.timingFunction == &BINAnimationTimingFunctionCAEaseIn) {
						animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
					} else if (operation.timingFunction == &BINAnimationTimingFunctionCAEaseOut) {
						animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
					} else if (operation.timingFunction == &BINAnimationTimingFunctionCAEaseInOut) {
						animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
					} else if (operation.timingFunction == &BINAnimationTimingFunctionCALinear) {
						animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
					} else {
						animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
					}
					
					[operation.boundObject setValue:animation.toValue forKeyPath:propertyFormatted];
					[operation.boundObject addAnimation:animation forKey:@"BINAnimationCAAnimation"];
					
					goto complete;
				}
			}
		} else if (operation.boundSetter && operation.boundObject && [operation.boundObject isKindOfClass:[NSView class]]) {
			for (NSString *selector in animationSelectorsForNSView) {
				NSString *setter = NSStringFromSelector(operation.boundSetter);
				if ([selector isEqualToString:setter]) {
					NSLog(@"Using NSView Animation for %@", NSStringFromSelector(operation.boundSetter));
					operation.canUseBuiltAnimation = YES;
					
					NSString *propertyUnformatted = [selector stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
					NSString *propertyFormatted = [[propertyUnformatted stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[propertyUnformatted substringToIndex:1] lowercaseString]] substringToIndex:[propertyUnformatted length] - 1];
					
					NSValue *fromValue = nil;
					NSValue *toValue = nil;
					
					if (![operation.period isKindOfClass:[BINAnimationLerpPeriod class]] &&
						![operation.period conformsToProtocol:@protocol(BINAnimationLerpPeriod)]) {
						fromValue = [NSNumber numberWithFloat:operation.period.startValue];
						toValue = [NSNumber numberWithFloat:operation.period.endValue];
					} else {
						BINAnimationLerpPeriod *period = (BINAnimationLerpPeriod*)operation.period;
						fromValue = period.startLerp;
						toValue = period.endLerp;
					}
					
					[operation.boundObject setValue:fromValue forKeyPath:propertyFormatted];
					[NSAnimationContext beginGrouping];
					[[NSAnimationContext currentContext] setDuration:operation.period.duration];
					
					if (operation.timingFunction == &BINAnimationTimingFunctionCAEaseIn) {
						[[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
					} else if (operation.timingFunction == &BINAnimationTimingFunctionCAEaseOut) {
						[[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
					} else if (operation.timingFunction == &BINAnimationTimingFunctionCAEaseInOut) {
						[[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
					} else if (operation.timingFunction == &BINAnimationTimingFunctionCALinear) {
						[[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
					} else {
						[[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
					}
					
					[operation.boundObject setValue:toValue forKeyPath:propertyFormatted];
					[NSAnimationContext endGrouping];
					
					goto complete;
				}
			}
		}
		
	}
	
complete:
	[animationOperations addObject:operation];
	return operation;
}

- (BINAnimationOperation *)addAnimationPeriod:(BINAnimationPeriod *)period
							  updateBlock:(void (^)(BINAnimationPeriod *period))updateBlock
						  completionBlock:(void (^)())completeBlock {
	return [self addAnimationPeriod:period updateBlock:updateBlock
				completionBlock:completeBlock
				 timingFunction:self.defaultTimingFunction];
}

- (BINAnimationOperation*)addAnimationPeriod:(BINAnimationPeriod *)period
							 updateBlock:(void (^)(BINAnimationPeriod *period))anUpdateBlock
						 completionBlock:(void (^)())completeBlock
						  timingFunction:(BINAnimationTimingFunction)timingFunction {
	BINAnimationOperation *animationOperation = [BINAnimationOperation new];
	animationOperation.period = period;
	animationOperation.timingFunction = timingFunction;
	animationOperation.updateBlock = anUpdateBlock;
	animationOperation.completeBlock = completeBlock;
	return [self addAnimationOperation:animationOperation];
}

- (BINAnimationOperation*)addAnimationPeriod:(BINAnimationPeriod *)period
								  target:(NSObject *)target selector:(SEL)selector {
	return [self addAnimationPeriod:period target:target selector:selector timingFunction:self.defaultTimingFunction];
}

- (BINAnimationOperation*)addAnimationPeriod:(BINAnimationPeriod *)period target:(NSObject *)target
								selector:(SEL)selector timingFunction:(BINAnimationTimingFunction)timingFunction {
	BINAnimationOperation *animationOperation = [BINAnimationOperation new];
	animationOperation.period = period;
	animationOperation.target = target;
	animationOperation.timingFunction = timingFunction;
	animationOperation.updateSelector = selector;
	return [self addAnimationOperation:animationOperation];
}

- (void)removeAnimationOperation:(BINAnimationOperation *)animationOperation {
	if(animationOperation != nil && [animationOperations containsObject:animationOperation])
		[expiredanimationOperations addObject:animationOperation];
}

- (void)update {
	self.timeOffset += kBINAnimationFramerate;
	for(BINAnimationOperation *animationOperation in animationOperations) {
		BINAnimationPeriod *period = animationOperation.period;
		
		if(self.timeOffset <= period.startOffset + period.delay)
			continue;
		
		CGFloat (*timingFunction)(CGFloat, CGFloat, CGFloat, CGFloat) = animationOperation.timingFunction;
		if(timingFunction == NULL)
			timingFunction = self.defaultTimingFunction;
		
		if(timingFunction != NULL && animationOperation.canUseBuiltAnimation == NO) {
			if(self.timeOffset <= period.startOffset + period.delay + period.duration) {
				if ([period isKindOfClass:[BINAnimationLerpPeriod class]]) {
					if([period conformsToProtocol:@protocol(BINAnimationLerpPeriod)]) {
						BINAnimationLerpPeriod <BINAnimationLerpPeriod> *lerpPeriod = (BINAnimationLerpPeriod <BINAnimationLerpPeriod> *)period;
						CGFloat progress = timingFunction(self.timeOffset - period.startOffset - period.delay,
														  0.0, 1.0, period.duration);
						[lerpPeriod setProgress:progress];
					} else {
						// TODO: Throw exception
						NSLog(@"Class doesn't conform to BINAnimationLerp");
					}
				} else {
					if(self.timeOffset <= period.startOffset + period.delay + kBINAnimationFramerate &&
					   animationOperation.startBlock != NULL) {
						animationOperation.startBlock();
					}
					
					period.animatedValue = timingFunction(self.timeOffset - period.startOffset - period.delay,
														 period.startValue, period.endValue - period.startValue,
														 period.duration);
				}
			} else {
				period.animatedValue = period.endValue;
				[expiredanimationOperations addObject:animationOperation];
			}
			
			NSObject *target = animationOperation.target;
			SEL selector = animationOperation.updateSelector;
			
			if(period != nil) {
				if(target != nil && selector != NULL)
					[target performSelector:selector withObject:period afterDelay:0];
				
				if(animationOperation.updateBlock != NULL)
					animationOperation.updateBlock(period);
			}
		} else if (animationOperation.canUseBuiltAnimation == YES) {
			if (self.timeOffset > period.startOffset + period.delay + period.duration)
				[expiredanimationOperations addObject:animationOperation];
		}
	}
	
	for (__strong BINAnimationOperation *animationOperation in expiredanimationOperations) {
		if(animationOperation.completeSelector)
			[animationOperation.target performSelector:animationOperation.completeSelector withObject:nil afterDelay:0];
		if(animationOperation.completeBlock != NULL)
			animationOperation.completeBlock();
		
		// FIXME: Come up with a better pattern for removing observers.
		@try {
			[animationOperation removeObserver:[BINAnimation sharedInstance] forKeyPath:@"period.animatedValue"];
		} @catch (id exception) {}
		@try {
			[animationOperation removeObserver:[BINAnimation sharedInstance] forKeyPath:@"period.animatedLerp"];
		} @catch (id exception) {}
		
		[animationOperations removeObject:animationOperation];
		animationOperation = nil;
	}
	
	[expiredanimationOperations removeAllObjects];
}

- (void)dealloc {
	animationOperations = nil;
	expiredanimationOperations = nil;
	
	if (displayLink) {
		CVDisplayLinkStop(displayLink);
		CVDisplayLinkRelease(displayLink);
	}
}

@end


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunsequenced"
CGFloat BINAnimationTimingFunctionLinear (CGFloat time, CGFloat begin, CGFloat change, CGFloat duration) {
	return change * time / duration + begin;
}

CGFloat BINAnimationTimingFunctionBackOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	CGFloat s = 1.70158;
	return c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b;
}

CGFloat BINAnimationTimingFunctionBackIn (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	CGFloat s = 1.70158;
	return c*(t/=d)*t*((s+1)*t - s) + b;
}

CGFloat BINAnimationTimingFunctionBackInOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	CGFloat s = 1.70158;
	if ((t/=d/2) < 1) return c/2*(t*t*(((s*=(1.525))+1)*t - s)) + b;
	return c/2*((t-=2)*t*(((s*=(1.525))+1)*t + s) + 2) + b;
}

CGFloat BINAnimationTimingFunctionBounceOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	if ((t/=d) < (1/2.75)) {
		return c*(7.5625*t*t) + b;
	} else if (t < (2/2.75)) {
		return c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;
	} else if (t < (2.5/2.75)) {
		return c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;
	} else {
		return c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;
	}
}

CGFloat BINAnimationTimingFunctionBounceIn (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	return c - BINAnimationTimingFunctionBounceOut(d-t, 0, c, d) + b;
}

CGFloat BINAnimationTimingFunctionBounceInOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	if (t < d/2) return BINAnimationTimingFunctionBounceIn(t*2, 0, c, d) * .5 + b;
	else return BINAnimationTimingFunctionBounceOut(t*2-d, 0, c, d) * .5 + c*.5 + b;
}

CGFloat BINAnimationTimingFunctionCircOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	return c * sqrt(1 - (t=t/d-1)*t) + b;
}

CGFloat BINAnimationTimingFunctionCircIn (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	return -c * (sqrt(1 - (t/=d)*t) - 1) + b;
}

CGFloat BINAnimationTimingFunctionCircInOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	if ((t/=d/2) < 1) return -c/2 * (sqrt(1 - t*t) - 1) + b;
	return c/2 * (sqrt(1 - (t-=2)*t) + 1) + b;
}

CGFloat BINAnimationTimingFunctionCubicOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	return c*((t=t/d-1)*t*t + 1) + b;
}

CGFloat BINAnimationTimingFunctionCubicIn (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	return c*(t/=d)*t*t + b;
}

CGFloat BINAnimationTimingFunctionCubicInOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	if ((t/=d/2) < 1) return c/2*t*t*t + b;
	return c/2*((t-=2)*t*t + 2) + b;
}

CGFloat BINAnimationTimingFunctionElasticOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	CGFloat p = d*.3;
	CGFloat s, a = 0;
	if (t==0) return b;  if ((t/=d)==1) return b+c;
	if (!a || a < ABS(c)) { a=c; s=p/4; }
	else s = p/(2*M_PI) * asin (c/a);
	return (a*pow(2,-10*t) * sin( (t*d-s)*(2*M_PI)/p ) + c + b);
}

CGFloat BINAnimationTimingFunctionElasticIn (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	CGFloat p = d*.3;
	CGFloat s, a = 0;
	if (t==0) return b;  if ((t/=d)==1) return b+c;
	if (!a || a < ABS(c)) { a=c; s=p/4; }
	else s = p/(2*M_PI) * asin (c/a);
	return -(a*pow(2,10*(t-=1)) * sin( (t*d-s)*(2*M_PI)/p )) + b;
}

CGFloat BINAnimationTimingFunctionElasticInOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	CGFloat p = d*(.3*1.5);
	CGFloat s, a = 0;
	if (t==0) return b;  if ((t/=d/2)==2) return b+c;
	if (!a || a < ABS(c)) { a=c; s=p/4; }
	else s = p/(2*M_PI) * asin (c/a);
	if (t < 1) return -.5*(a*pow(2,10*(t-=1)) * sin( (t*d-s)*(2*M_PI)/p )) + b;
	return a*pow(2,-10*(t-=1)) * sin( (t*d-s)*(2*M_PI)/p )*.5 + c + b;
}

CGFloat BINAnimationTimingFunctionExpoOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	return (t==d) ? b+c : c * (-pow(2, -10 * t/d) + 1) + b;
}

CGFloat BINAnimationTimingFunctionExpoIn (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	return (t==0) ? b : c * pow(2, 10 * (t/d - 1)) + b;
}

CGFloat BINAnimationTimingFunctionExpoInOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	if (t==0) return b;
	if (t==d) return b+c;
	if ((t/=d/2) < 1) return c/2 * pow(2, 10 * (t - 1)) + b;
	return c/2 * (-pow(2, -10 * --t) + 2) + b;
}

CGFloat BINAnimationTimingFunctionQuadOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	return -c *(t/=d)*(t-2) + b;
}

CGFloat BINAnimationTimingFunctionQuadIn (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	return c*(t/=d)*t + b;
}

CGFloat BINAnimationTimingFunctionQuadInOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	if ((t/=d/2) < 1) return c/2*t*t + b;
	return -c/2 * ((--t)*(t-2) - 1) + b;
}

CGFloat BINAnimationTimingFunctionQuartOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	return -c * ((t=t/d-1)*t*t*t - 1) + b;
}

CGFloat BINAnimationTimingFunctionQuartIn (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	return c*(t/=d)*t*t*t + b;
}

CGFloat BINAnimationTimingFunctionQuartInOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	if ((t/=d/2) < 1) return c/2*t*t*t*t + b;
	return -c/2 * ((t-=2)*t*t*t - 2) + b;
}

CGFloat BINAnimationTimingFunctionQuintIn (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	return c*(t/=d)*t*t*t*t + b;
}

CGFloat BINAnimationTimingFunctionQuintOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	return c*((t=t/d-1)*t*t*t*t + 1) + b;
}

CGFloat BINAnimationTimingFunctionQuintInOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	if ((t/=d/2) < 1) return c/2*t*t*t*t*t + b;
	return c/2*((t-=2)*t*t*t*t + 2) + b;
}

CGFloat BINAnimationTimingFunctionSineOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	return c * sin(t/d * (M_PI/2)) + b;
}

CGFloat BINAnimationTimingFunctionSineIn (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	return -c * cos(t/d * (M_PI/2)) + c + b;
}

CGFloat BINAnimationTimingFunctionSineInOut (CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
	return -c/2 * (cos(M_PI*t/d) - 1) + b;
}

CGFloat BINAnimationTimingFunctionCALinear	   (CGFloat t, CGFloat b, CGFloat c, CGFloat d) { return 0; }
CGFloat BINAnimationTimingFunctionCAEaseIn	   (CGFloat t, CGFloat b, CGFloat c, CGFloat d) { return 0; }
CGFloat BINAnimationTimingFunctionCAEaseOut	  (CGFloat t, CGFloat b, CGFloat c, CGFloat d) { return 0; }
CGFloat BINAnimationTimingFunctionCAEaseInOut	(CGFloat t, CGFloat b, CGFloat c, CGFloat d) { return 0; }
#pragma clang diagnostic pop
