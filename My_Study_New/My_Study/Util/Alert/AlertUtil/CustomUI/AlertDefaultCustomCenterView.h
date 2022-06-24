//
//  AlertDefaultCustomCenterView.h
//  CRM
//
//  Created by Zhiwei Han on 2022/6/17.
//  Copyright © 2022 CRM. All rights reserved.
//

#import <UIKit/UIKit.h>

/* 默认title字体大小 */
#define kAlertDefaultTitleFont   PASFont(13)
#define kAlertDefaultMsgFont    PASFont(13)

#define kAlertDefaultTitleString @"你确定要删除记录吗？"
#define kAlertDefaultMsgString   @"删除后，与其相关的数据也将被删除，并无法恢复，确认删除吗？"

#define kAlertTitleLabelLeftSpace        24

/* 需要特殊处理的场景 (线索、客户、联系人、商机) */
#define kStagesArray            @[ClientStage_Clue,ClientStage_Customer,ClientStage_Contacts,ClientStage_Niche]


NS_ASSUME_NONNULL_BEGIN

@interface AlertDefaultCustomCenterView : UIView

@property (nonatomic, copy) NSString *titleName;

@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, copy) NSString *msg;

@property (nonatomic, strong) UIColor *msgColor;

@property (nonatomic, strong) UIFont *msgFont;

@end

NS_ASSUME_NONNULL_END
