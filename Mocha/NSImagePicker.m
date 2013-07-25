/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import "NSImagePicker.h"

@import Quartz.ImageKit.IKPictureTaker;

@interface NSImagePicker ()
@property (nonatomic, strong) IKPictureTaker *pictureTaker;
@end

@implementation NSImagePicker

- (id)init {
	if((self = [super init])) {
		self.pictureTaker = [IKPictureTaker  new];
	}
	return self;
}

- (NSImage *)inputImage {
	return self.pictureTaker.inputImage;
}

- (NSImage *)outputImage {
	return self.pictureTaker.outputImage;
}

- (void)setInputImage:(NSImage *)inputImage {
	self.pictureTaker.inputImage = inputImage;
}

- (void)show:(id)sender {
	SEL action = @selector(pictureTakerDidEnd:returnCode:contextInfo:);
	NSView *view = self.positioningView ?: ([sender isKindOfClass:NSView.class] ? sender : nil);
	if(self.context == NSImagePickerDisplayContextPopover) {
		if(!view) return;
		[self.pictureTaker popUpRecentsMenuForView:view withDelegate:self
									didEndSelector:action contextInfo:NULL];
	} else if(self.context == NSImagePickerDisplayContextSheet) {
		if(!view.window) return;
		[self.pictureTaker beginPictureTakerSheetForWindow:view.window withDelegate:self
											didEndSelector:action contextInfo:NULL];
	} else if(self.context == NSImagePickerDisplayContextModal) {
		[self.pictureTaker beginPictureTakerWithDelegate:self didEndSelector:action contextInfo:NULL];
	}
}

- (void)pictureTakerDidEnd:(IKPictureTaker *)taker returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[NSApp sendAction:self.action to:self.target from:self];
	if(self.completionHandler) self.completionHandler();
}

- (BOOL)allowsVideoCapture {
	return [[self.pictureTaker valueForKey:IKPictureTakerAllowsVideoCaptureKey] boolValue];
}

- (BOOL)allowsFileChoosing {
	return [[self.pictureTaker valueForKey:IKPictureTakerAllowsFileChoosingKey] boolValue];
}

- (BOOL)updatesRecentPicture {
	return [[self.pictureTaker valueForKey:IKPictureTakerUpdateRecentPictureKey] boolValue];
}

- (BOOL)allowsEditing {
	return [[self.pictureTaker valueForKey:IKPictureTakerAllowsEditingKey] boolValue];
}

- (BOOL)showsEffects {
	return [[self.pictureTaker valueForKey:IKPictureTakerShowEffectsKey] boolValue];
}

- (NSString *)informationalText {
	return [self.pictureTaker valueForKey:IKPictureTakerInformationalTextKey];
}

- (NSDictionary *)imageTransforms {
	return [self.pictureTaker valueForKey:IKPictureTakerImageTransformsKey];
}

- (NSSize)maxSize {
	return [[self.pictureTaker valueForKey:IKPictureTakerOutputImageMaxSizeKey] sizeValue];
}

- (BOOL)showsRecentPicture {
	return [[self.pictureTaker valueForKey:IKPictureTakerShowRecentPictureKey] boolValue];
}

- (BOOL)showsContactsPicture {
	return [[self.pictureTaker valueForKey:IKPictureTakerShowAddressBookPictureKey] boolValue];
}

- (NSImage *)emptyPicture {
	return [self.pictureTaker valueForKey:IKPictureTakerShowEmptyPictureKey];
}

- (BOOL)remainsOpenAfterValidation {
	return [[self.pictureTaker valueForKey:IKPictureTakerRemainOpenAfterValidateKey] boolValue];
}

- (void)setAllowsVideoCapture:(BOOL)flag {
	[self.pictureTaker setValue:@(flag) forKey:IKPictureTakerAllowsVideoCaptureKey];
}

- (void)setAllowsFileChoosing:(BOOL)flag {
	[self.pictureTaker setValue:@(flag) forKey:IKPictureTakerAllowsFileChoosingKey];
}

- (void)setUpdatesRecentPicture:(BOOL)flag {
	[self.pictureTaker setValue:@(flag) forKey:IKPictureTakerUpdateRecentPictureKey];
}

- (void)setAllowsEditing:(BOOL)flag {
	[self.pictureTaker setValue:@(flag) forKey:IKPictureTakerAllowsEditingKey];
}

- (void)setShowsEffects:(BOOL)flag {
	[self.pictureTaker setValue:@(flag) forKey:IKPictureTakerShowEffectsKey];
}

- (void)setInformationalText:(NSString *)informationalText {
	[self.pictureTaker setValue:informationalText forKey:IKPictureTakerInformationalTextKey];
}

- (void)setImageTransforms:(NSDictionary *)imageTransforms {
	[self.pictureTaker setValue:imageTransforms forKey:IKPictureTakerImageTransformsKey];
}

- (void)setMaxSize:(NSSize)maxSize {
	[self.pictureTaker setValue:[NSValue valueWithSize:maxSize] forKey:IKPictureTakerOutputImageMaxSizeKey];
}

- (void)setShowsRecentPicture:(BOOL)flag {
	[self.pictureTaker setValue:@(flag) forKey:IKPictureTakerShowRecentPictureKey];
}

- (void)setShowsContactsPicture:(BOOL)flag {
	[self.pictureTaker setValue:@(flag) forKey:IKPictureTakerShowAddressBookPictureKey];
}

- (void)setEmptyPicture:(NSImage *)emptyPicture {
	[self.pictureTaker setValue:emptyPicture forKey:IKPictureTakerShowEmptyPictureKey];
}

- (void)setRemainsOpenAfterValidation:(BOOL)flag {
	[self.pictureTaker setValue:@(flag) forKey:IKPictureTakerRemainOpenAfterValidateKey];
}

@end
