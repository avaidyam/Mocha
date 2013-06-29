#import "BINAuthorizationService.h"

NSString *BINAuthorizationServiceErrorDomain = @"BINAuthorizationServiceErrorDomain";

static NSString* NSStringForSecErrorCode(OSStatus status) {
    NSBundle *securityBundle = [NSBundle bundleWithIdentifier:@"com.apple.security"];
    NSString *statusString = [NSString stringWithFormat:@"%d", status];
    return [securityBundle localizedStringForKey:statusString value:statusString table:@"SecErrorMessages"];
}

@implementation BINAuthorizationService {
	AuthorizationRef _authRef;
}

- (void)dealloc {
	 AuthorizationFree(_authRef, kAuthorizationFlagDefaults);
}

- (BOOL)authorizeRights:(NSArray *)rightsArray error:(NSError *__autoreleasing *)error {
	return [self authorizeRights:rightsArray username:nil password:nil error:error];
}

- (BOOL)authorizeRights:(NSArray *)rightsArray username:(NSString *)username
			   password:(NSString *)password error:(NSError *__autoreleasing *)error {
	
	// Prepare the authorization flags.
    AuthorizationFlags authFlags = kAuthorizationFlagExtendRights;
	if(self.preauthorizesRights)
		authFlags |= kAuthorizationFlagPreAuthorize;
	if(self.preservesRights)
		authFlags |= kAuthorizationFlagDestroyRights;
	if(self.allowsPartialRights)
		authFlags |= kAuthorizationFlagPartialRights;
	if(self.allowsUserInteraction)
		authFlags |= kAuthorizationFlagInteractionAllowed;
	
	// Prepare all authorization rights applicable.
	UInt32 rightsCount = 0;
    AuthorizationItem rights[rightsArray.count];
	for(NSString *right in rightsArray) {
		rights[rightsCount].name = (char *)[right.copy UTF8String];
		rightsCount++;
	}
    AuthorizationRights authRights = {.count = rightsCount, .items = rights};
    
	NSInteger totalEnvCount = 0;
	if(username != nil)
		totalEnvCount++;
	if(password != nil)
		totalEnvCount++;
	if(self.prompt != nil)
		totalEnvCount++;
	if(self.iconURL != nil)
		totalEnvCount++;
	
	// Add all possible environment items for use while authorizing.
	UInt32 environmentCount = 0;
    AuthorizationItem environment[totalEnvCount];
	if(username != nil) {
		char *user = (char *)[username.copy UTF8String];
		environment[environmentCount] = (AuthorizationItem) {
			.name = kAuthorizationEnvironmentUsername,
			.value = user,
			.valueLength = strlen(user)
		};
		environmentCount++;
	}
	if(password != nil) {
		char *pass = (char *)[password.copy UTF8String];
		environment[environmentCount] = (AuthorizationItem) {
			.name = kAuthorizationEnvironmentPassword,
			.value = pass,
			.valueLength = strlen(pass)
		};
		environmentCount++;
	}
	if(self.prompt != nil) {
		char *prompt = (char *)[self.prompt.copy UTF8String];
		environment[environmentCount] = (AuthorizationItem) {
			.name = kAuthorizationEnvironmentPrompt,
			.value = prompt,
			.valueLength = strlen(prompt)
		};
		environmentCount++;
	}
	if(self.iconURL != nil) {
		char *iconPath = (char *)[self.iconURL.path.copy UTF8String];
		environment[environmentCount] = (AuthorizationItem) {
			.name = kAuthorizationEnvironmentIcon,
			.value = iconPath,
			.valueLength = strlen(iconPath)
		};
		environmentCount++;
	}
    AuthorizationEnvironment authEnvironment = {.count = environmentCount, .items = environment};
	
	// Remove all references to username and password.
	username = nil;
	password = nil;
	
	// Authorize.
    OSStatus status = AuthorizationCreate(&authRights, &authEnvironment, authFlags, &_authRef);
    if(status != errAuthorizationSuccess) {
		*error = [NSError errorWithDomain:BINAuthorizationServiceErrorDomain code:status
								 userInfo:@{ NSLocalizedDescriptionKey : NSStringForSecErrorCode(status) }];
	}
	
	return status == errAuthorizationSuccess;
}

- (BOOL)blessHelperWithLabel:(NSString *)label error:(NSError *__autoreleasing *)error {
	return [self blessHelperWithLabel:label username:nil password:nil error:error];
}

- (BOOL)blessHelperWithLabel:(NSString *)label username:(NSString *)username
					password:(NSString *)password error:(NSError *__autoreleasing *)error {
	BOOL returnValue = [self authorizeRights:@[[NSString stringWithFormat:@"%s", kSMRightBlessPrivilegedHelper]]
									username:username password:password error:error];
	if(returnValue) {
		CFErrorRef _error = nil;
		returnValue = SMJobBless(kSMDomainSystemLaunchd, (__bridge CFStringRef)label, _authRef, &_error);
		*error = [(__bridge NSError *)_error copy];
	}
	
	return returnValue;
}

@end
