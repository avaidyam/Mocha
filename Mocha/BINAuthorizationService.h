#import <Foundation/Foundation.h>
#import <ServiceManagement/ServiceManagement.h>

#define kBINAuthorizationServiceRightExecute \
[NSString stringWithCString:kAuthorizationRightExecute encoding:NSUTF8StringEncoding]

FOUNDATION_EXPORT NSString *BINAuthorizationServiceErrorDomain;

@interface BINAuthorizationService : NSObject

@property (nonatomic, assign) BOOL preauthorizesRights;
@property (nonatomic, assign) BOOL preservesRights;
@property (nonatomic, assign) BOOL allowsPartialRights;
@property (nonatomic, assign) BOOL allowsUserInteraction;

@property (nonatomic, copy) NSString *prompt;
@property (nonatomic, copy) NSURL *iconURL;

- (BOOL)authorizeRights:(NSArray *)rightsArray error:(NSError **)error;
- (BOOL)authorizeRights:(NSArray *)rightsArray username:(NSString *)username
			   password:(NSString *)password error:(NSError **)error;

- (BOOL)blessHelperWithLabel:(NSString *)label error:(NSError **)error;
- (BOOL)blessHelperWithLabel:(NSString *)label username:(NSString *)username
					password:(NSString *)password error:(NSError **)error;

@end
