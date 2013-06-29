#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <dlfcn.h>

#import "NSString+BINExtensions.h"

#define NSBundlePath [[NSBundle mainBundle] bundlePath]

// Assume that if the user has a ~/Applications folder, they'd prefer their applications to go there.
static NSString *__NSPreferredInstallLocation(BOOL *isUserDirectory) {
	
#if 0
	NSArray *userApplicationsDirs = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES);
	if ([userApplicationsDirs count] > 0) {
		NSString *userApplicationsDir = [userApplicationsDirs objectAtIndex:0];
		BOOL isDirectory;
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:userApplicationsDir isDirectory:&isDirectory] && isDirectory) {
			NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:userApplicationsDir error:NULL];
			
			// Check if there is at least one ".app" inside the directory.
			for (NSString *contentsPath in contents) {
				if ([[contentsPath pathExtension] isEqualToString:@"app"]) {
					if (isUserDirectory)
						*isUserDirectory = YES;
					return [userApplicationsDir stringByResolvingSymlinksAndAliases];
				}
			}
		}
	}
#endif

	// No user Applications directory in use. Return the machine local Applications directory
	if(isUserDirectory) *isUserDirectory = NO;
	return [[NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSLocalDomainMask, YES) lastObject]
			stringByResolvingSymlinksAndAliases];
}

static BOOL __NSIsInsideApplicationsFolder(NSString *path) {
	NSEnumerator *e = [NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSAllDomainsMask, YES) objectEnumerator];
	NSString *appDirPath = nil;
	while((appDirPath = [e nextObject]))
		if([path hasPrefix:appDirPath])
			return YES;
	
	return [[path pathComponents] containsObject:@"Applications"];
}

static BOOL __NSIsInsideDownloadsFolder(NSString *path) {
	NSEnumerator *e = [NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSAllDomainsMask, YES) objectEnumerator];
	NSString *downloadsDirPath = nil;
	while((downloadsDirPath = [e nextObject]))
		if([path hasPrefix:downloadsDirPath])
			return YES;
	
	return [[path pathComponents] containsObject:@"Downloads"];
}

static BOOL __NSAppWasLaunchedFromMountedDisk() {
	return [NSBundlePath hasPrefix:@"/Volumes/"] && ![[NSFileManager defaultManager] isWritableFileAtPath:NSBundlePath];
}

static BOOL __NSDeleteItemAtPath(NSString *path) {
	if ([[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
													 source:[path stringByDeletingLastPathComponent]
												destination:@""
													  files:[NSArray arrayWithObject:[path lastPathComponent]]
														tag:NULL]) {
		return YES;
	} else {
		NSLog(@"__NSDeleteItemAtPath failed for path '%@'", path);
		return NO;
	}
}

static BOOL __NSInstallWithAuthorization(NSString *srcPath, NSString *dstPath, BOOL *canceled) {
	if(canceled)
		*canceled = NO;
	if(![dstPath hasSuffix:@".app"])
		return NO;
	if([[dstPath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
		return NO;
	if([[srcPath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
		return NO;
	
	AuthorizationRef authRef;
	OSStatus err = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment,
									   kAuthorizationFlagDefaults, &authRef);
	if (err != errAuthorizationSuccess)
		return NO;

	AuthorizationItem myItems = {kAuthorizationRightExecute, 0, NULL, 0};
	AuthorizationRights myRights = {1, &myItems};
	AuthorizationFlags myFlags = kAuthorizationFlagInteractionAllowed |
								 kAuthorizationFlagPreAuthorize |
								 kAuthorizationFlagExtendRights;
	err = AuthorizationCopyRights(authRef, &myRights, NULL, myFlags, NULL);
	if (err != errAuthorizationSuccess) {
		if (err == errAuthorizationCanceled && canceled)
			*canceled = YES;
		goto fail;
	}
	
	// On 10.7, AuthorizationExecuteWithPrivileges is deprecated. We want to still use it since there's no
	// good alternative (without requiring code signing). We'll look up the function through dyld and fail
	// if it is no longer accessible. If Apple removes the function entirely this will fail gracefully. If
	// they keep the function and throw some sort of exception, this won't fail gracefully, but that's a
	// risk we'll have to take for now.
	static OSStatus (*security_AuthorizationExecuteWithPrivileges)(AuthorizationRef authorization, const char *pathToTool,
																   AuthorizationFlags options, char * const *arguments,
																   FILE **communicationsPipe) = NULL;
	if (!security_AuthorizationExecuteWithPrivileges)
		security_AuthorizationExecuteWithPrivileges = dlsym(RTLD_DEFAULT, "AuthorizationExecuteWithPrivileges");
	if (!security_AuthorizationExecuteWithPrivileges)
		goto fail;

	{ // Delete Destination Path
		char *args[] = { "-rf", (char *)[dstPath fileSystemRepresentation], NULL };
		err = security_AuthorizationExecuteWithPrivileges(authRef, "/bin/rm", kAuthorizationFlagDefaults, args, NULL);
		if(err != errAuthorizationSuccess)
			goto fail;
		
		int status;
		pid_t pid = wait(&status);
		if (pid == -1 || !WIFEXITED(status))
			goto fail;
	}
	
	{ // Copy to Destination Path
		char *args[] = {"-pR", (char *)[srcPath fileSystemRepresentation], (char *)[dstPath fileSystemRepresentation], NULL};
		err = security_AuthorizationExecuteWithPrivileges(authRef, "/bin/cp", kAuthorizationFlagDefaults, args, NULL);
		if(err != errAuthorizationSuccess)
			goto fail;
		
		int status;
		pid_t pid = wait(&status);
		if (pid == -1 || !WIFEXITED(status) || WEXITSTATUS(status))
			goto fail;
	}

success:
	AuthorizationFree(authRef, kAuthorizationFlagDefaults);
	return YES;
fail:
	AuthorizationFree(authRef, kAuthorizationFlagDefaults);
	return NO;
}

static BOOL __NSCopyBundle(NSString *srcPath, NSString *dstPath) {
	NSError *error = nil;
	if([[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:dstPath error:&error])
		return YES;
	else NSLog(@"__NSCopyBundle: Could not copy '%@' to '%@' (%@)", srcPath, dstPath, error);
	return NO;
}

static void __NSRelaunchFromPath(NSString *destinationPath) {
	pid_t pid = [[NSProcessInfo processInfo] processIdentifier];
	NSString *wait = [NSString stringWithFormat:@"while [ `ps -p %d | wc -l` -gt 1 ]; do sleep 0.1; done;", pid];
	NSString *xattr = [NSString stringWithFormat:@"/usr/bin/xattr -d -r com.apple.quarantine '%@';", destinationPath];
	NSString *open = [NSString stringWithFormat:@"open '%@'", destinationPath];
	
	NSString *script = [NSString stringWithFormat:@"(%@ %@ %@) &", wait, xattr, open];
	[NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:@[@"-c", script]];
	
	// Unmount the hosting disk if applicable.
	if (__NSAppWasLaunchedFromMountedDisk()) {
		script = [NSString stringWithFormat:@"(sleep 5 && hdiutil detach '%@') &",
				  [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent]];
		[NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:@[@"-c", script]];
	}
	exit(0);
}

void NSMoveToApplicationsFolderIfNecessary(NSString *firstRunUserDefaultsKey);
void NSMoveToApplicationsFolderIfNecessary(NSString *firstRunUserDefaultsKey) {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:firstRunUserDefaultsKey])
		return;
	if (__NSIsInsideApplicationsFolder(NSBundlePath))
		return;
	
	BOOL installToUserApplications = NO;
	NSString *applicationsDirectory = __NSPreferredInstallLocation(&installToUserApplications);
	NSString *bundleName = [NSBundlePath lastPathComponent];
	NSString *destinationPath = [applicationsDirectory stringByAppendingPathComponent:bundleName];
	
	BOOL needAuthorization = ([[NSFileManager defaultManager] isWritableFileAtPath:applicationsDirectory] == NO);
	needAuthorization |= ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath] &&
						  ![[NSFileManager defaultManager] isWritableFileAtPath:destinationPath]);
	
	NSAlert *alert = [NSAlert new];
	{
		alert.messageText = (installToUserApplications ? @"Move to Applications folder in your Home folder?" :
														 @"Move to Applications folder?");
		
		NSString *informativeText = @"I can move myself to the Applications folder if you'd like.";
		if(needAuthorization)
			informativeText = [informativeText stringByAppendingString:@" Note that this will require an administrator password."];
		else if(__NSIsInsideDownloadsFolder(NSBundlePath))
			informativeText = [informativeText stringByAppendingString:@" This will keep your Downloads folder uncluttered."];
		alert.informativeText = informativeText;
		
		[alert addButtonWithTitle:@"Move to Applications Folder"];
		NSButton *cancelButton = [alert addButtonWithTitle:@"Do Not Move"];
		cancelButton.keyEquivalent = @"\e";
		alert.showsSuppressionButton = YES;
	}
	
	if(![NSApp isActive])
		[NSApp activateIgnoringOtherApps:YES];
	if ([alert runModal] == NSAlertFirstButtonReturn) {
		NSLog(@"NSMoveToApplicationsFolderIfNecessary is moving to the Applications folder.");
		
		if(needAuthorization) {
			BOOL authorizationCanceled;
			if(!__NSInstallWithAuthorization(NSBundlePath, destinationPath, &authorizationCanceled)) {
				if (authorizationCanceled) {
					NSLog(@"NSMoveToApplicationsFolderIfNecessary was cancelled by the user.");
					return;
				} else {
					NSLog(@"NSMoveToApplicationsFolderIfNecessary could not copy to %@ with authorization.", destinationPath);
					goto fail;
				}
			}
		} else {
			if([[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
				BOOL destinationIsRunning = NO;
				for(NSRunningApplication *runningApplication in [[NSWorkspace sharedWorkspace] runningApplications]) {
					NSString *executablePath = [[runningApplication executableURL] path];
					if([executablePath hasPrefix:destinationPath]) {
						destinationIsRunning = YES;
						break;
					}
				}
				
				if(destinationIsRunning) {
					NSLog(@"NSMoveToApplicationsFolderIfNecessary is switching to an open copy of the application.");
					[[NSTask launchedTaskWithLaunchPath:@"/usr/bin/open" arguments:@[destinationPath]] waitUntilExit];
					exit(0);
				} else if (!__NSDeleteItemAtPath([applicationsDirectory stringByAppendingPathComponent:bundleName]))
					goto fail;
			}
			
 			if(!__NSCopyBundle(NSBundlePath, destinationPath)) {
				NSLog(@"NSMoveToApplicationsFolderIfNecessary could not copy to %@.", destinationPath);
				goto fail;
			}
		}
		
		if(!__NSAppWasLaunchedFromMountedDisk() && !__NSDeleteItemAtPath(NSBundlePath))
			NSLog(@"NSMoveToApplicationsFolderIfNecessary could not delete application after moving!");
		__NSRelaunchFromPath(destinationPath);
	} else if(alert.suppressionButton.state == NSOnState)
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:firstRunUserDefaultsKey];
	return;
	
fail: {
		alert = [NSAlert new];
		alert.messageText = @"Could not move to Applications folder";
	}
}
