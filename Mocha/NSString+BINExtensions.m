/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import "NSString+BINExtensions.h"
#include <sys/stat.h>

@implementation NSString (BINStringAmbivalentEquivalencyExtensions)

- (CGFloat)equivalencyToString:(NSString *)otherString {
	return [self equivalencyToString:otherString ambivalence:0.0f favorSmallerWords:NO reducePenaltyForLongerWords:NO];
}

- (CGFloat)equivalencyToString:(NSString *)otherString ambivalence:(CGFloat)ambivalence {
	return [self equivalencyToString:otherString ambivalence:ambivalence favorSmallerWords:NO reducePenaltyForLongerWords:NO];
}

- (CGFloat)equivalencyToString:(NSString *)anotherString ambivalence:(CGFloat)ambivalence
			 favorSmallerWords:(BOOL)favor reducePenaltyForLongerWords:(BOOL)reduce {
	
	NSMutableCharacterSet *workingInvalidCharacterSet = [NSCharacterSet lowercaseLetterCharacterSet];
	[workingInvalidCharacterSet formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
	[workingInvalidCharacterSet addCharactersInString:@" "];
	NSCharacterSet *invalidCharacterSet = [workingInvalidCharacterSet invertedSet];
	
	NSString *string = [[[self decomposedStringWithCanonicalMapping] componentsSeparatedByCharactersInSet:invalidCharacterSet] componentsJoinedByString:@""];
	NSString *otherString = [[[anotherString decomposedStringWithCanonicalMapping] componentsSeparatedByCharactersInSet:invalidCharacterSet] componentsJoinedByString:@""];
	
	if([string isEqualToString:otherString])
		return 1.0f;
	if([otherString length] == 0)
		return 0.0f;
	
	CGFloat totalCharacterScore = 0;
	BOOL startOfStringBonus = NO;
	CGFloat fuzzies = 1;
	CGFloat finalScore;
	
	for(NSInteger index = 0; index < otherString.length; index++) {
		CGFloat characterScore = 0.1;
		NSInteger indexInString = NSNotFound;
		
		NSString *chr = [otherString substringWithRange:NSMakeRange(index, 1)];
		NSRange rangeChrLowercase = [string rangeOfString:chr.lowercaseString];
		NSRange rangeChrUppercase = [string rangeOfString:chr.uppercaseString];
		
		if(rangeChrLowercase.location == NSNotFound && rangeChrUppercase.location == NSNotFound)
			fuzzies += 1 - ambivalence;
		else if (rangeChrLowercase.location != NSNotFound && rangeChrUppercase.location != NSNotFound)
			indexInString = MIN(rangeChrLowercase.location, rangeChrUppercase.location);
		else if(rangeChrLowercase.location != NSNotFound || rangeChrUppercase.location != NSNotFound)
			indexInString = rangeChrLowercase.location != NSNotFound ? rangeChrLowercase.location : rangeChrUppercase.location;
		else
			indexInString = MIN(rangeChrLowercase.location, rangeChrUppercase.location);
		
		if(indexInString != NSNotFound && [[string substringWithRange:NSMakeRange(indexInString, 1)] isEqualToString:chr])
			characterScore += 0.1;
		
		if(indexInString == 0) {
			characterScore += 0.6;
			if(index == 0)
				startOfStringBonus = YES;
		} else if(indexInString != NSNotFound) {
			if([[string substringWithRange:NSMakeRange(indexInString - 1, 1)] isEqualToString:@" "])
				characterScore += 0.8;
		}
		
		if(indexInString != NSNotFound)
			string = [string substringFromIndex:indexInString + 1];
		totalCharacterScore += characterScore;
	}
	
	if(favor)
		return totalCharacterScore / string.length;
	CGFloat otherStringScore = totalCharacterScore / otherString.length;
	
	if(reduce) {
		CGFloat percentageOfMatchedString = otherString.length / string.length;
		CGFloat wordScore = otherStringScore * percentageOfMatchedString;
		finalScore = (wordScore + otherStringScore) / 2;
	} else
		finalScore = ((otherStringScore * ((CGFloat)(otherString.length) / (CGFloat)(string.length))) + otherStringScore) / 2;
	finalScore = finalScore / fuzzies;
	
	if(startOfStringBonus && finalScore + 0.15 < 1)
		finalScore += 0.15;
	return finalScore;
}

@end

@implementation NSString (BINSymlinkAliasAdditions)

- (NSString *)stringByResolvingSymlinksAndAliases {
	NSString *path = [self stringByStandardizingPath];
	if (![path hasPrefix:@"/"])
		return nil;
	
	NSArray *pathComponents = [path pathComponents];
	NSString *resolvedPath = [pathComponents objectAtIndex:0];
	pathComponents = [pathComponents subarrayWithRange:NSMakeRange(1, [pathComponents count] - 1)];
	
	for (NSString *component in pathComponents) {
		resolvedPath = [resolvedPath stringByAppendingPathComponent:component];
		resolvedPath = [resolvedPath stringByIterativelyResolvingSymlinkOrAlias];
		if (!resolvedPath)
			return nil;
	}
	
	return resolvedPath;
}

- (NSString *)stringByIterativelyResolvingSymlinkOrAlias {
	NSString *path = self;
	NSString *aliasTarget = nil;
	struct stat fileInfo;
	
	if (lstat([[NSFileManager defaultManager] fileSystemRepresentationWithPath:path], &fileInfo) < 0)
		return nil;
	
	while (S_ISLNK(fileInfo.st_mode) ||
		   (!S_ISDIR(fileInfo.st_mode) &&
			(aliasTarget = [path stringByConditionallyResolvingAlias]) != nil)) {
			   if (S_ISLNK(fileInfo.st_mode)) {
				   NSString *symlinkPath = [path stringByConditionallyResolvingSymlink];
				   if (!symlinkPath) {
					   return nil;
				   }
				   path = symlinkPath;
			   } else {
				   path = aliasTarget;
			   }
			   
			   if (lstat([[NSFileManager defaultManager]
						  fileSystemRepresentationWithPath:path], &fileInfo) < 0) {
				   path = nil;
				   continue;
			   }
		   }
	
	return path;
}

- (NSString *)stringByResolvingAlias {
	NSString *aliasTarget = [self stringByConditionallyResolvingAlias];
	if (aliasTarget)
		return aliasTarget;
	return nil;
}

- (NSString *)stringByResolvingSymlink {
	NSString *symlinkTarget = [self stringByConditionallyResolvingSymlink];
	if (symlinkTarget)
		return symlinkTarget;
	return nil;
}

- (NSString *)stringByConditionallyResolvingSymlink {
	NSString *symlinkPath = [[NSFileManager defaultManager] destinationOfSymbolicLinkAtPath:self error:NULL];
	if (!symlinkPath)
		return nil;
	
	if (![symlinkPath hasPrefix:@"/"]) {
		symlinkPath = [[self stringByDeletingLastPathComponent] stringByAppendingPathComponent:symlinkPath];
		symlinkPath = [symlinkPath stringByStandardizingPath];
	}
	return symlinkPath;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (NSString *)stringByConditionallyResolvingAlias {
	NSString *resolvedPath = nil;
	CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (__bridge CFStringRef)self, kCFURLPOSIXPathStyle, NO);
	
	if (url != NULL) {
		FSRef fsRef;
		if (CFURLGetFSRef(url, &fsRef)) {
			Boolean targetIsFolder, wasAliased;
			OSErr err = FSResolveAliasFileWithMountFlags(&fsRef, false, &targetIsFolder, &wasAliased, kResolveAliasFileNoUI);
			if ((err == noErr) && wasAliased) {
				
				CFURLRef resolvedUrl = CFURLCreateFromFSRef(kCFAllocatorDefault, &fsRef);
				if (resolvedUrl != NULL) {
					resolvedPath = (__bridge id)CFURLCopyFileSystemPath(resolvedUrl, kCFURLPOSIXPathStyle);
					CFRelease(resolvedUrl);
				}
			}
		}
		CFRelease(url);
	}
	return resolvedPath;
}
#pragma clang diagnostic pop

@end