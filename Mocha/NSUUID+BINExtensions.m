#import "NSUUID+BINExtensions.h"
#import <objc/runtime.h>
#include <uuid/uuid.h>

@interface BINUUID : NSObject <NSCopying, NSCoding> {
	uuid_t _uuid;
}

+ (id)UUID;
- (id)init;
- (id)initWithUUIDBytes:(const uuid_t)bytes;
- (id)initWithUUIDString:(NSString *)string;
- (void)getUUIDBytes:(uuid_t)uuid;
- (NSString *)UUIDString;

@end

@implementation BINUUID

+ (void)load {
	if(!NSClassFromString(@"NSUUID"))
		objc_registerClassPair(objc_allocateClassPair(BINUUID.class, "NSUUID", 0));
}

+ (id)UUID {
	return [[self alloc] init];
}

- (id)init {
	if((self = [super init]))
		uuid_generate_random(_uuid);
	return self;
}

- (id)initWithUUIDBytes:(const uuid_t)bytes {
	if((self = [super init]))
		uuid_copy(_uuid, bytes);
	return self;
}

- (id)initWithUUIDString:(NSString *)string {
	if((self = [super init]))
		if(uuid_parse([string UTF8String], _uuid) != 0)
			self = nil;
	return self;
}

- (void)getUUIDBytes:(uuid_t)uuid {
	uuid_copy(uuid, _uuid);
}

- (NSString *)UUIDString {
	uuid_string_t string;
	uuid_unparse_upper(_uuid, string);
	
	return [NSString stringWithUTF8String:string];
}

- (BOOL)isEqual:(id)object {
	if(self == object)
		return YES;
	if([object isKindOfClass:self.class]) {
		uuid_t uuid;
		[object getUUIDBytes:uuid];
		return uuid_compare(_uuid, uuid) == 0;
	}
	return NO;
}

- (NSUInteger)hash {
	NSData *data = [[NSData alloc] initWithBytes:_uuid length:sizeof(_uuid)];
	return data.hash;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@ %p> %@", self.class, self, self.UUIDString];
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

+ (BOOL)supportsSecureCoding {
	return YES;
}

- (id)initWithCoder:(NSCoder *)coder {
	if (coder.allowsKeyedCoding) {
		NSUInteger length = 0;
		const uint8_t *uuid = [coder decodeBytesForKey:@"NS.uuidbytes" returnedLength:&length];
		
		if(length == sizeof(uuid_t))
			return [self initWithUUIDBytes:uuid];
		else return [self init];
	} else @throw [NSException exceptionWithName:NSInvalidArgumentException
										  reason:@"-[NSUUID initWithCoder]: NSUUIDs cannot be decoded by non-keyed coders"
										userInfo:nil];
}

- (void)encodeWithCoder:(NSCoder *)coder {
	if(coder.allowsKeyedCoding)
		[coder encodeBytes:_uuid length:sizeof(_uuid) forKey:@"NS.uuidbytes"];
	else @throw [NSException exceptionWithName:NSInvalidArgumentException
										reason:@"-[NSUUID encodeWithCoder]: NSUUIDs cannot be encoded by non-keyed coders"
									  userInfo:nil];
}

@end
