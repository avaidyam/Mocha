#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>

typedef CGFloat(*BINAnimationTimingFunction)(CGFloat, CGFloat, CGFloat, CGFloat);

@class BINAnimationPeriod;
typedef void (^BINAnimationUpdateBlock)(BINAnimationPeriod *period);
typedef void (^BINAnimationCompleteBlock)();

@protocol BINAnimationLerpPeriod

- (NSValue *)animatedValueForProgress:(CGFloat)progress;
- (void)setProgress:(CGFloat)progress;

@end

@interface BINAnimationPeriod : NSObject

@property (nonatomic, assign) CGFloat startValue;
@property (nonatomic, assign) CGFloat endValue;
@property (nonatomic, assign) CGFloat animatedValue;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat delay;
@property (nonatomic, assign) CGFloat startOffset;

+ (instancetype)periodWithStartValue:(CGFloat)aStartValue
							endValue:(CGFloat)anEndValue
							duration:(CGFloat)duration;

@end

@interface BINAnimationLerpPeriod : BINAnimationPeriod

@property (nonatomic, copy) NSValue *startLerp;
@property (nonatomic, copy) NSValue *endLerp;
@property (nonatomic, copy) NSValue *animatedLerp;

+ (instancetype)periodWithStartValue:(NSValue *)aStartValue
							endValue:(NSValue *)anEndValue
							duration:(CGFloat)duration;

@end

@interface BINAnimationPointLerpPeriod : BINAnimationLerpPeriod <BINAnimationLerpPeriod>

+ (instancetype)periodWithStartPoint:(CGPoint)aStartPoint
							endPoint:(CGPoint)anEndPoint
							duration:(CGFloat)duration;
- (CGPoint)startPoint;
- (CGPoint)animatedPoint;
- (CGPoint)endPoint;

@end

@interface BINAnimationSizeLerpPeriod : BINAnimationLerpPeriod <BINAnimationLerpPeriod>

+ (instancetype)periodWithStartSize:(CGSize)aStartSize
							endSize:(CGSize)anEndSize
						   duration:(CGFloat)duration;
- (CGSize)startSize;
- (CGSize)animatedSize;
- (CGSize)endSize;

@end

@interface BINAnimationRectLerpPeriod : BINAnimationLerpPeriod <BINAnimationLerpPeriod>

+ (instancetype)periodWithStartRect:(CGRect)aStartRect
							endRect:(CGRect)anEndRect
						   duration:(CGFloat)duration;
- (CGRect)startRect;
- (CGRect)animatedRect;
- (CGRect)endRect;

@end

@interface BINAnimationOperation : NSObject

@property (nonatomic, strong) BINAnimationPeriod *period;
@property (nonatomic, strong) NSObject *target;
@property (nonatomic, assign) SEL updateSelector;
@property (nonatomic, assign) SEL completeSelector;
@property (nonatomic, assign) BINAnimationTimingFunction timingFunction;

@property (nonatomic, copy) BINAnimationCompleteBlock startBlock;
@property (nonatomic, copy) BINAnimationUpdateBlock updateBlock;
@property (nonatomic, copy) BINAnimationCompleteBlock completeBlock;

@property (nonatomic, assign) CGFloat *boundRef;
@property (nonatomic, strong) id boundObject;
@property (nonatomic, assign) SEL boundGetter;
@property (nonatomic, assign) SEL boundSetter;
@property (nonatomic, assign) BOOL override;

@end

@interface BINAnimation : NSObject

@property (nonatomic, assign, readonly) CGFloat timeOffset;
@property (nonatomic, assign) BINAnimationTimingFunction defaultTimingFunction;
@property (nonatomic, assign) BOOL useBuiltInAnimationsWhenPossible;

+ (BINAnimation *)sharedInstance;

+ (BINAnimationOperation *)animate:(id)object property:(NSString *)property
					   from:(CGFloat)from to:(CGFloat)to duration:(CGFloat)duration
			 timingFunction:(BINAnimationTimingFunction)timingFunction
					 target:(NSObject *)target completeSelector:(SEL)selector;

+ (BINAnimationOperation *)animate:(CGFloat *)ref from:(CGFloat)from
						 to:(CGFloat)to duration:(CGFloat)duration
			 timingFunction:(BINAnimationTimingFunction)timingFunction
					 target:(NSObject *)target completeSelector:(SEL)selector;

+ (BINAnimationOperation *)animate:(id)object property:(NSString *)property
					   from:(CGFloat)from to:(CGFloat)to duration:(CGFloat)duration;

+ (BINAnimationOperation *)animate:(CGFloat *)ref from:(CGFloat)from
						 to:(CGFloat)to duration:(CGFloat)duration;

+ (BINAnimationOperation *)lerp:(id)object property:(NSString *)property
					period:(BINAnimationLerpPeriod <BINAnimationLerpPeriod> *)period
			timingFunction:(BINAnimationTimingFunction)timingFunction
					target:(NSObject *)target completeSelector:(SEL)selector;

- (BINAnimationOperation *)addAnimationOperation:(BINAnimationOperation *)operation;
- (BINAnimationOperation *)addAnimationPeriod:(BINAnimationPeriod *)period
							  target:(NSObject *)target selector:(SEL)selector;
- (BINAnimationOperation *)addAnimationPeriod:(BINAnimationPeriod *)period
							  target:(NSObject *)target selector:(SEL)selector
					  timingFunction:(BINAnimationTimingFunction)timingFunction;
- (void)removeAnimationOperation:(BINAnimationOperation *)animationOperation;

+ (BINAnimationOperation *)animate:(id)object property:(NSString *)property
					   from:(CGFloat)from to:(CGFloat)to duration:(CGFloat)duration
			 timingFunction:(BINAnimationTimingFunction)timingFunction
				updateBlock:(BINAnimationUpdateBlock)updateBlock
			  completeBlock:(BINAnimationCompleteBlock)completeBlock;

+ (BINAnimationOperation *)animate:(CGFloat *)ref from:(CGFloat)from
						 to:(CGFloat)to duration:(CGFloat)duration
			 timingFunction:(BINAnimationTimingFunction)timingFunction
				updateBlock:(BINAnimationUpdateBlock)updateBlock
			  completeBlock:(BINAnimationCompleteBlock)completeBlock;

+ (BINAnimationOperation *)lerp:(id)object property:(NSString *)property
					period:(BINAnimationLerpPeriod <BINAnimationLerpPeriod> *)period
			timingFunction:(BINAnimationTimingFunction)timingFunction
			   updateBlock:(BINAnimationUpdateBlock)updateBlock
			 completeBlock:(BINAnimationCompleteBlock)completeBlock;

- (BINAnimationOperation *)addAnimationPeriod:(BINAnimationPeriod *)period
						 updateBlock:(BINAnimationUpdateBlock)updateBlock
					 completionBlock:(BINAnimationCompleteBlock)completeBlock;
- (BINAnimationOperation *)addAnimationPeriod:(BINAnimationPeriod *)period
						 updateBlock:(BINAnimationUpdateBlock)updateBlock
					 completionBlock:(BINAnimationCompleteBlock)completionBlock
					  timingFunction:(BINAnimationTimingFunction)timingFunction;

@end

CGFloat BINAnimationTimingFunctionLinear(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionCALinear(CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat BINAnimationTimingFunctionBackOut(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionBackIn(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionBackInOut(CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat BINAnimationTimingFunctionBounceOut(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionBounceIn(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionBounceInOut(CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat BINAnimationTimingFunctionCircOut(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionCircIn(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionCircInOut(CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat BINAnimationTimingFunctionCubicOut(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionCubicIn(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionCubicInOut(CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat BINAnimationTimingFunctionElasticOut(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionElasticIn(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionElasticInOut(CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat BINAnimationTimingFunctionExpoOut(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionExpoIn(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionExpoInOut(CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat BINAnimationTimingFunctionQuadOut(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionQuadIn(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionQuadInOut(CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat BINAnimationTimingFunctionQuartOut(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionQuartIn(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionQuartInOut(CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat BINAnimationTimingFunctionQuintOut(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionQuintIn(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionQuintInOut(CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat BINAnimationTimingFunctionSineOut(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionSineIn(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionSineInOut(CGFloat, CGFloat, CGFloat, CGFloat);

CGFloat BINAnimationTimingFunctionCAEaseIn(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionCAEaseOut(CGFloat, CGFloat, CGFloat, CGFloat);
CGFloat BINAnimationTimingFunctionCAEaseInOut(CGFloat, CGFloat, CGFloat, CGFloat);
