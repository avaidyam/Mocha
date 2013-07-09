/*
 *  Mocha.framework
 *
 *  Copyright (c) 2013 Galaxas0. All rights reserved.
 *  For more copyright and licensing information, please see LICENSE.md.
 */

#import <AppKit/NSControl.h>

@class BINInspectorBarItem;
@class BINInspectorBar;

@interface BINInspectorBar : NSControl

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic) CGFloat itemWidth;
@property (nonatomic) BOOL multipleSelection;
@property (nonatomic, copy) dispatch_block_t changedSelectionHandler;

- (BINInspectorBarItem *)selectedItem;
- (NSInteger)selectedIndex;
- (NSArray *)selectedItems;
- (NSIndexSet *)selectedIndexes;

- (IBAction)selectAll;
- (void)selectIndex:(NSUInteger)index;
- (void)selectItem:(BINInspectorBarItem *)item;
- (void)selectIndexes:(NSIndexSet *)indexes byExtendingSelection:(BOOL)extending;

- (IBAction)deselectAll;
- (void)deselectIndex:(NSUInteger)index;
- (void)deselectIndexes:(NSIndexSet *)indexes;

@end

@interface BINInspectorBarItem : NSObject

@property (nonatomic, strong) NSImage *icon;
@property (nonatomic, copy) NSString *tooltip;
@property (nonatomic, unsafe_unretained) BINInspectorBar *tabBar;

- (id)initWithIcon:(NSImage *)image tooltip:(NSString *)tooltipString;
+ (BINInspectorBarItem *)itemWithIcon:(NSImage *)image tooltip:(NSString *)tooltipString;

@end