#import <Foundation/Foundation.h>

static LSSharedFileListRef __NSGlobalLoginItems;
__attribute__((constructor)) void __NSGlobalLoginItemsInitializer() {
	__NSGlobalLoginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
}

static LSSharedFileListItemRef __NSFindItemWithURLInFileList(NSURL *wantedURL, LSSharedFileListRef fileList) {
	if(wantedURL == NULL || fileList == NULL)
        return NULL;
	
	// Get the URL's file attributes. That includes the NSFileSystemFileNumber.
	// comparing the file number is better than comparing URLs
	// because it doesn't have to deal with case sensitivity
	
	NSDictionary *wantedAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[(NSURL *)wantedURL path] error:nil];
    NSArray *listSnapshot = (__bridge NSArray *)(LSSharedFileListCopySnapshot(fileList, NULL));
    for (id itemObject in listSnapshot) {
		
        LSSharedFileListItemRef item = (__bridge LSSharedFileListItemRef) itemObject;
        UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
        CFURLRef currentItemURL = NULL;
        LSSharedFileListItemResolve(item, resolutionFlags, &currentItemURL, NULL);
		
		NSDictionary *currentAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[(__bridge NSURL *)currentItemURL path] error:nil];
		if(currentAttributes && [currentAttributes isEqual:wantedAttributes]) {
			CFRelease(currentItemURL);
            return item;
        }
        if(currentItemURL)
            CFRelease(currentItemURL);
    }
    return NULL;
}

BOOL NSWillLaunchItemAtURLOnLogin(NSURL *itemURL, BOOL *hidden) {
	LSSharedFileListItemRef item = __NSFindItemWithURLInFileList(itemURL, __NSGlobalLoginItems);
	if(hidden != NULL) {
		if(item) *hidden = [(__bridge id)LSSharedFileListItemCopyProperty(item, kLSSharedFileListLoginItemHidden) boolValue];
		else *hidden = NO;
	}
	return item != nil;
}

void NSLaunchItemAtURLOnLogin(NSURL *itemURL, BOOL enabled, BOOL hidden) {
    LSSharedFileListItemRef existingItem = __NSFindItemWithURLInFileList(itemURL, __NSGlobalLoginItems);
	if(enabled && (existingItem == NULL)) {
		if(!hidden) {
			LSSharedFileListInsertItemURL(__NSGlobalLoginItems, kLSSharedFileListItemBeforeFirst,
										  NULL, NULL, (__bridge CFURLRef)itemURL, NULL, NULL);
		} else {
			NSDictionary *properties = @{(__bridge id)kLSSharedFileListLoginItemHidden : @(hidden)};
			LSSharedFileListInsertItemURL(__NSGlobalLoginItems, kLSSharedFileListItemBeforeFirst,
										  NULL, NULL, (__bridge CFURLRef)itemURL, (__bridge CFDictionaryRef)properties, NULL);
		}
	} else if (!enabled && (existingItem != NULL)) {
		LSSharedFileListItemRemove(__NSGlobalLoginItems, existingItem);
	}
}
