#import <Foundation/Foundation.h>
#import "NSObject+BINExtensions.h"

#if !MOCHA_10_8

// Note: NSUUID is not toll-free bridged with CFUUID. Use UUID strings to convert
// between CFUUID and NSUUID, if needed. NSUUIDs are not guaranteed to be comparable
// by pointer value (as CFUUIDRef is); use isEqual: to compare two NSUUIDs.
@interface NSUUID : NSObject <NSCopying, NSCoding>

// Create a new autoreleased NSUUID with RFC 4122 version 4 random bytes.
+ (id)UUID;

// Create a new NSUUID with RFC 4122 version 4 random bytes.
- (id)init;

// Create an NSUUID from a string such as "E621E1F8-C36C-495A-93FC-0C247A3E6E5F".
// Returns nil for invalid strings.
- (id)initWithUUIDString:(NSString *)string;

// Create an NSUUID with the given bytes */
- (id)initWithUUIDBytes:(const uuid_t)bytes;

// Get the individual bytes of the receiver */
- (void)getUUIDBytes:(uuid_t)uuid;

// Return a string description of the UUID, such as "E621E1F8-C36C-495A-93FC-0C247A3E6E5F".
- (NSString *)UUIDString;

@end

#endif
