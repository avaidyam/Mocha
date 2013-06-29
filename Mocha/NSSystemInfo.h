#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

// System Profile dictionary keys. The values are all strings.
FOUNDATION_EXPORT NSString *NSSystemInfoCPUCount;
FOUNDATION_EXPORT NSString *NSSystemInfoCPUName;
FOUNDATION_EXPORT NSString *NSSystemInfoCPUCoreCount;
FOUNDATION_EXPORT NSString *NSSystemInfoCPUClockSpeed;
FOUNDATION_EXPORT NSString *NSSystemInfoCPUL1Cache;
FOUNDATION_EXPORT NSString *NSSystemInfoCPUL2Cache;
FOUNDATION_EXPORT NSString *NSSystemInfoCPUL3Cache;
FOUNDATION_EXPORT NSString *NSSystemInfoCPUArchitecture;
FOUNDATION_EXPORT NSString *NSSystemInfoModelName;
FOUNDATION_EXPORT NSString *NSSystemInfoPhysicalMemorySize;
FOUNDATION_EXPORT NSString *NSSystemInfoBusClockSpeed;
FOUNDATION_EXPORT NSString *NSSystemInfoGraphicsCards;
FOUNDATION_EXPORT NSString *NSSystemInfoOS;
FOUNDATION_EXPORT NSString *NSSystemInfoOSVersion;
FOUNDATION_EXPORT NSString *NSSystemInfoOSKernelVersion;
FOUNDATION_EXPORT NSString *NSSystemInfoUsername;
FOUNDATION_EXPORT NSString *NSSystemInfoComputerName;
FOUNDATION_EXPORT NSString *NSSystemInfoSystemUptime;
FOUNDATION_EXPORT NSString *NSSystemInfoComputerSerialID;
FOUNDATION_EXPORT NSString *NSSystemInfoDisplayCount;
FOUNDATION_EXPORT NSString *NSSystemInfoDisplayResolutions;
FOUNDATION_EXPORT NSString *NSSystemInfoHardDrivesSpace;
FOUNDATION_EXPORT NSString *NSSystemInfoHardDrivesFreeSpace;

// NSSystemInfo grabs a snapshot of all System Profile
// information and returns it either in a system profile dictionary
// or in data for each individual profile key.
@interface NSSystemInfo : NSObject

+ (NSDictionary *)systemProfile;
+ (NSDictionary *)absoluteSystemProfileWithDetailLevel:(NSString *)detailLevel;

+ (NSString *)CPUCount;
+ (NSString *)CPUName;
+ (NSString *)CPUCoreCount;
+ (NSString *)CPUClockSpeed;

+ (NSString *)CPUL1Cache;
+ (NSString *)CPUL2Cache;
+ (NSString *)CPUL3Cache;
+ (NSString *)CPUArchitecture;

+ (NSString *)currentModelName;
+ (NSString *)currentPhysicalMemorySize;
+ (NSString *)currentBusClockSpeed;
+ (NSString *)currentGraphicsCards;

+ (NSString *)operatingSystem;
+ (NSString *)operatingSystemVersion;
+ (NSString *)operatingSystemKernelVersion;

+ (NSString *)currentUsername;
+ (NSString *)currentComputerName;
+ (NSString *)currentSystemUptime;
+ (NSString *)computerSerialID;

+ (NSString *)displayCount;
+ (NSString *)displayResolutions;
+ (NSString *)hardDrivesSpace;
+ (NSString *)hardDrivesFreeSpace;

@end
