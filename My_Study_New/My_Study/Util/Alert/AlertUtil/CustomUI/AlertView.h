//
//  AlertView.h
//  CRM
//
//  Created by js on 2020/2/20.
//  Copyright © 2020 js. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertAction.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^AlertHtmlTagClickHandler)(NSString *url, NSString *text);

typedef NS_ENUM(NSUInteger, ActionType) {
    ActionTypeAlert = 0,
    ActionTypeActionSheet = 1
};

@interface AlertActionCell: UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@end

typedef UIView *_Nonnull(^MakeViewBlock)(void);
typedef void (^CellDidLoad)(AlertActionCell *);
@interface AlertView : UIView
@property (nonatomic, strong,readonly) UIView *contentView;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) NSArray *actions;
@property (nonatomic, assign) BOOL disableBgTap;
@property (nonatomic, assign) BOOL showClose;

//点击按钮 ，自动关闭
@property (nonatomic, assign) BOOL autoCloseClicked;
@property (nonatomic, strong,nullable) AlertAction *footerAction;
@property (nonatomic, assign) ActionType actionType;

@property (nonatomic, copy, nullable) MakeViewBlock customTopViewBlock;
@property (nonatomic, copy, nullable) MakeViewBlock customCenterViewBlock;
@property (nonatomic, copy, nullable) MakeViewBlock customBottomViewBlock;
@property (nonatomic, copy, nullable) CellDidLoad cellDidLoadBlock;

@property (nonatomic, strong, nullable) UIFont *titleFont;
@property (nonatomic, strong, nullable) UIFont *messageFont;

@property (nonatomic, copy, nullable) dispatch_block_t didHiddenBlock;

/** html 文本点击事件回调  */
@property (nonatomic, copy) AlertHtmlTagClickHandler htmlTagClickHandler ;

- (void)show;
- (void)showInView:(UIView *)parentView;
- (void)moveToView:(UIView *)parentView;
- (void)hidden;

+ (void)updateCurrentAlertView:(nullable AlertView *)alertView;

+ (AlertView *)currentAlertView;
@end

NS_ASSUME_NONNULL_END
