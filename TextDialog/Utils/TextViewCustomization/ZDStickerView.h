//
//  ZDStickerView.h
//  TextDialog
//
//  Created by iOSHero on 12/19/14.
//  Copyright (c) 2014 iOSHero. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPGripViewBorderView.h"

#define kSPUserResizableViewGlobalInset 10.0
#define kSPUserResizableViewDefaultMinWidth 100
#define kSPUserResizableViewInteractiveBorderSize 10.0
#define kZDStickerViewControlSize 30.0

@protocol ZDStickerViewDelegate;

@interface ZDStickerView : UIView
{
    SPGripViewBorderView *borderView;
}

@property (assign, nonatomic) UITextView *contentView;
@property (nonatomic) BOOL preventsPositionOutsideSuperview; //default = YES
@property (nonatomic) BOOL preventsResizing; //default = NO
@property (nonatomic) BOOL preventsDeleting; //default = NO
@property (nonatomic) CGFloat minWidth;
@property (nonatomic) CGFloat minHeight;

@property (strong, nonatomic) id <ZDStickerViewDelegate> delegate;

- (void)hideDelHandle;
- (void)showDelHandle;
- (void)hideEditingHandles;
- (void)showEditingHandles;

@end

@protocol ZDStickerViewDelegate <NSObject>
@required
@optional
- (void)stickerViewDidBeginEditing:(ZDStickerView *)sticker;
- (void)stickerViewDidEndEditing:(ZDStickerView *)sticker;
- (void)stickerViewDidCancelEditing:(ZDStickerView *)sticker;
- (void)stickerViewDidClose:(ZDStickerView *)sticker;
- (void)moveToLeft:(CGFloat)dx Top:(CGFloat)dy;
- (void)stickerViewDidSizeChanged;

@end


