/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

@import AppKit.NSCell;
@import AppKit.NSView;

// TODO: Runtime Level Property Forwarding

typedef NS_ENUM(NSUInteger, NSImagePickerDisplayContext) {
	
	/*! NSImagePickerDisplayContextPopover causes the NSImagePicker to
		display as a popover attached to its positioningView.
	 */
	NSImagePickerDisplayContextPopover,
	
	/*! NSImagePickerDisplayContextSheet causes the NSImagePicker to
		display as a window sheet attached to its positioningView's window.
	 */
	NSImagePickerDisplayContextSheet,
	
	/*! NSImagePickerDisplayContextModal causes the NSImagePicker to
		display as a standalone modal panel. The positioningView is ignored.
	 */
	NSImagePickerDisplayContextModal
};

/*! The NSImagePicker is a multi-context display which allows users to choose 
 *	images by browsing the file system. It provides a Recent Pictures pane,
 *	supports image cropping, and supports taking snapshots from the FaceTime HD Camera.
 *	This class is a wrapper around IKPictureTaker, designed to implement a
 *	modernized/more Cocoa-like API. 
 *
 *	Though it is a subclass of NSCell, it cannot be used as a cell itself, and
 *	does nothing when used as one. The purpose of being an NSCell subclass is to
 *	allow easy Interface Builder outlet building. In addition to the block-based
 *	completionHandler, you can create the NSImagePicker as a generic object in 
 *	Interface Builder and set its selector to an action.
 */
@interface NSImagePicker : NSCell

/*! Allow NSImagePicker video capture. Defaults to YES.
 */
@property (nonatomic, assign) BOOL allowsVideoCapture;

/*! Allow NSPicker file selection. Defaults to YES.
 */
@property (nonatomic, assign) BOOL allowsFileChoosing;

/*! Allow NSPicker to update the recent pictures. Defaults to YES.
 */
@property (nonatomic, assign) BOOL updatesRecentPicture;

/*! Allow NSPicker image editing. Defaults to YES.
 */
@property (nonatomic, assign) BOOL allowsEditing;

/*! Allow NSPicker image effects. Defaults to NO.
 */
@property (nonatomic, assign) BOOL showsEffects;

/*! Allow NSPicker to display recently used pictures. Defaults to NO.
 */
@property (nonatomic, assign) BOOL showsRecentPicture;

/*! Allow NSPicker to automatically add the Contacts Card image for the Me
	user at the end of the Recent Pictures pane. Defaults to NO.
 */
@property (nonatomic, assign) BOOL showsContactsPicture;

/*! Determine whether the NSImagePicker should remain open after the user selects done.
	This allows the application to programmatically dismiss the panel. Defaults to NO.
 */
@property (nonatomic, assign) BOOL remainsOpenAfterValidation;

/*! Provide additional informational text in the NSImagePicker display. 
	Defaults to "Drag Image Here".
 */
@property (nonatomic, copy) NSString *informationalText;

/*! Provide image transforms to the NSImagePicker in a serializable 
	dictionary. Defaults to nil.
 */
@property (nonatomic, strong) NSDictionary *imageTransforms;

/*! The maximum output image size yielded by the NSImagePicker. Defaults to NSZeroSize.
 */
@property (nonatomic, assign) NSSize maxSize;

/*! If set to an image, NSImagePicker will automatically show an image at
	the end of the Recent Pictures pane, that means "no picture." Defaults to nil.
 */
@property (nonatomic, strong) NSImage *emptyPicture;

/*! The NSImagePicker can be provided an inputImage to display initially.
	It is never modified by the NSImagePicker.
 */
@property (nonatomic, strong) NSImage *inputImage;

/*! Once the NSImagePicker has been closed, either programatically or through
	user interaction, the outputImage will hold the picked image.
 */
@property (nonatomic, strong, readonly) NSImage *outputImage;

/*! The completionHandler is invoked when the NSImagePicker is closed either
	programatically or through user interaction. This completionHandler is
	called regardless of whether the target and action have been set.
 */
@property (nonatomic, copy) dispatch_block_t completionHandler;

/*! The positioningView informs the NSImagePicker at display-time how
	to orient and position itself and where to do so. If the context
	specified is NSImagePickerDisplayContextSheet, the positoningView's
	window will be used as the anchor window for the NSImagePicker.
 */
@property (nonatomic, strong) IBOutlet NSView *positioningView;

/*! The context of the NSImagePicker determines how it is displayed.
	See NSImagePickerDisplayContext for more information.
 */
@property (nonatomic, assign) NSImagePickerDisplayContext context;

/*! Displays the NSImagePicker in the context associated with it.
 * \param sender The object to use as the sender of the event. This object must
				 be a subclass of NSResponder, but if the positioningView is not
				 set, and this object is a subclass of NSView, it may be 
				 considered as the positioningView.
 */
- (IBAction)show:(id)sender;

@end
