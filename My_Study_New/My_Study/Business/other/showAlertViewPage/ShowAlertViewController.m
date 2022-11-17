//
//  ShowAlertViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/2.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ShowAlertViewController.h"
#import "PASIndicatorTableViewCell.h"
#import "ActionModel.h"
#import <objc/runtime.h>
#import "NSString+Adaptor.h"
/** alert头文件  */
#import "AlertHead.h"
#import "AlertDefaultCustomCenterView.h"

#import "ZWCommonWebPage.h"
#import "HTMLLabel.h"
#import "UIApplication+Ext.h"
#import "TABAnimated.h"
#import "GCDCommon.h"
#import "TrimAddressCell.h"

@interface ShowAlertViewController () <HTMLLabelDelegate>

@end

@implementation ShowAlertViewController


 -   (void)initExtendedData
    {
      [super initExtendedData];
    
  // self.dataArray = [NSMutableArray arrayWithArray:[self getDataArray]];
    self.tableCellClass = [PASIndicatorTableViewCell class];
          self.style = UITableViewStylePlain;
  self.cellHeight = 60  ;
          self.title = @"展示Alert";
      }


- (void)loadUIData
{
    [super loadUIData];
    
    // 设置tabAnimated相关属性
    // 可以不进行手动初始化，将使用默认属性
    self.tableView.tabAnimated = [TABTableAnimated animatedWithCellClass:[TrimAddressCell class] cellHeight:100];
    self.tableView.tabAnimated.canLoadAgain = YES;
    [TABAnimated sharedAnimated].closeCache = YES;
    self.tableView.tabAnimated.superAnimationType = TABViewSuperAnimationTypeShimmer;
//    self.tableView.tabAnimated.adjustBlock = ^(TABComponentManager * _Nonnull manager) {
//        manager.animation(0).up(10).left(20).radius(10).width(40).height(40);
//        manager.create(1).left(-15).down(10).radius(5).width(200).height(25).reducedWidth(20).toLongAnimation();
//        manager.create(2).leftEqualTo(1).topEqualToBottom_offset(1, 5).radius(5).width(100).height(15).reducedWidth(-10).toShortAnimation();
//    };
    
    self.tableView.tabAnimated.adjustBlock = ^(TABComponentManager * _Nonnull manager) {
//        manager.animation(1).width(200).height(20).reducedWidth(30).toShortAnimation();
//        manager.animation(2).width(150).height(20).reducedWidth(20).toLongAnimation();
        manager.animation(1).width(200).height(20);
        manager.animation(2).width(150).height(20);
    };
    
//    [self.tableView setEditing:YES animated:YES];
    
    @pas_weakify_self
    self.cellConfigBlock = ^(NSIndexPath * _Nonnull indexPath, PASIndicatorTableViewCell * _Nonnull cell) {
        @pas_strongify_self
        ActionModel *model = PASArrayAtIndex(self.dataArray, indexPath.row);
        cell.leftLabel.text = TransToString(model.title);
        cell.leftLabel.font = PASFont(18);
        cell.leftLabel.zh_textColorPicker = ThemePickerColorKey(ZWColorKey_p5);
    };
    
    self.cellClickBlock = ^(NSIndexPath * _Nonnull indexPath, id  _Nonnull cell) {
        @pas_strongify_self
        ActionModel *model = PASArrayAtIndex(self.dataArray, indexPath.row);
        NSString *selectAction = TransToString(model.actionName);
        if (ValidString(selectAction)) {
            SEL sel = NSSelectorFromString(selectAction);
            ((void (*)(id, SEL))objc_msgSend)(self, sel);
        }
    };
}


- (NSArray *)getDataArray
{
    NSArray *secArr = @[[ActionModel initWithTitle:@"常见Alert" actionName:@"showCommonAlertView"],
                        [ActionModel initWithTitle:@"展示默认的AlertUtil" actionName:@"showACommonlertUtil"],
                        [ActionModel initWithTitle:@"常见Alert,多选项" actionName:@"showCommonAlertViewMut"],
                        [ActionModel initWithTitle:@"自定义centerView的Alert" actionName:@"showCustomAlertView"],
                        [ActionModel initWithTitle:@"底部弹出AlertSheet,带自定义view的" actionName:@"showAlertSheetView"],
                        [ActionModel initWithTitle:@"底部弹出AlertSheet多选项,通用样式" actionName:@"showComonAlertSheetView"]];

    return secArr;
}


//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//
//    [self.tableView tab_startAnimation];
//
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView tab_startAnimationWithCompletion:^{
        NSLog(@"000000");

        [self handleData];
    }];
    
    
//    for (int i = 0; i < 100000 ; i++) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            NSLog(@"currentThread = %@", [NSThread currentThread]);
//        });
////        performBlockOnCustomQueue(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), NULL, NO, ^{
////            NSLog(@"currentThread = %@", [NSThread currentThread]);
////        });
//    }
   
}

- (void)handleData
{
    NSLog(@"-----start------");
    performBlockDelay(dispatch_get_main_queue(), 3.0, ^{
        NSLog(@"-----end------");
        [self.tableView tab_endAnimationEaseOut];
        self.dataArray = [NSMutableArray arrayWithArray:[self getDataArray]];
        [self.tableView reloadData];
    });
}



#pragma mark - action  SEL
/**
 *  常见Alert  中间视图非自定义
 */
- (void)showCommonAlertView
{
    [self showAlertView: NO];
}

/**
 *  常见Alert,多选项
 */
- (void)showCommonAlertViewMut
{
    [UIAlertUtil showAlertTitle:@"温馨提示" message:@"描述信息" cancelButtonTitle:@"取消" otherButtonTitles:@[@"选项一",@"选项二",@"选项三"] alertControllerStyle:UIAlertControllerStyleAlert actionBlock:^(NSInteger index) {
        NSLog(@"%@", @(index));
    } superVC:self];
}

/**
 *  自定义centerView的Alert
 */
- (void)showCustomAlertView
{
    [self showAlertView: YES];
}

/**
 *  底部弹出AlertSheet,带自定义view的
 */
- (void)showAlertSheetView
{
    [self showAlertSheet];
}

/**
 *  底部弹出AlertSheet多选项,通用样式
 */
- (void)showComonAlertSheetView
{
    [UIAlertUtil showAlertTitle:@"温馨提示" message:@"描述信息" cancelButtonTitle:@"取消" otherButtonTitles:@[@"选项一",@"选项二",@"选项三"] alertControllerStyle:UIAlertControllerStyleActionSheet actionBlock:^(NSInteger index) {
        NSLog(@"%@", @(index));
    } superVC:self];
}

/**
 *  展示默认的AlertUtil
 */
- (void)showACommonlertUtil
{
    [AlertUtil confirm:@"确定" msg:@"确定删除吗" cancelBlock:^{
        NSLog(@"点击取消");
    } okBlock:^{
        NSLog(@"点击确定");
    }];
}



- (void)showAlertView:(BOOL)isExistCenterView
{
    AlertView *alertView = [[AlertView alloc] init];
    alertView.title = @"温馨提示";
    if (isExistCenterView) {
        CGFloat popWidth = kMainScreenWidth - 48*2;
        NSString *titleName = kAlertDefaultTitleString;
        CGFloat titleHeight = [NSString getHeightWithText:titleName font:kAlertDefaultTitleFont width:popWidth - kAlertTitleLabelLeftSpace*2];
        NSString *msg = kAlertDefaultMsgString;
        CGFloat msgHeight = [NSString getHeightWithText:msg font:kAlertDefaultTitleFont width:popWidth - kAlertTitleLabelLeftSpace*2];
        
        CGFloat popHeight = 16 + titleHeight + 8 + msgHeight;
        alertView.customCenterViewBlock = ^UIView * _Nonnull{
            AlertDefaultCustomCenterView * pop = [[AlertDefaultCustomCenterView alloc] initWithFrame:CGRectMake(0, 0, popWidth, popHeight)];
            pop.titleName = titleName;
            pop.titleFont = kAlertDefaultTitleFont;
            pop.titleColor = UIColorFromRGB(0x333333);
            pop.msg = msg;
            pop.msgFont = kAlertDefaultMsgFont;
            pop.msgColor = UIColorFromRGB(0xFF4266);
            return pop;
        };
    } else {
        alertView.messageFont = PASFont(12);
        alertView.message = @"同意<a href='https://www.baidu.com'>《销氪用户协议》</a>、<a href='https://github.com/iHZW'>《销氪个人信息保护政策》</a>和<a href='https://github.com/iHZW/HZWDemo'>《HZWDemo》</a>";
//        @pas_weakify(alertView)
        @weakify(alertView)
        alertView.htmlTagClickHandler = ^(NSString * _Nonnull url, NSString * _Nonnull text) {
            @strongify(alertView)
            [alertView hidden];
            
            ZWCommonWebPage *vc = [[ZWCommonWebPage alloc] init];
            vc.titleName = __String_Not_Nil(text);
            vc.url = __String_Not_Nil(url);
//            vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
//            [self presentViewController:vc animated:YES completion:nil];
            [self.navigationController pushViewController:vc animated:YES];
        };
    }

    @weakify(alertView)
    alertView.actions = @[
//        [AlertAction defaultCancelAction:@"取消" clickCallback:^{
//            @strongify(alertView)
//            [alertView hidden];
//        }],
        [AlertAction defaultConfirmAction:@"确认" clickCallback:^{
            @strongify(alertView)
            [alertView hidden];
        }]
    ];
    [alertView show];
}




/** ActionTypeActionSheet  */
- (void)showAlertSheet
{
    NSString *privacyStr = @"同意<a href='https://www.baidu.com'>《用户协议》</a>、<a href='https://github.com/iHZW'>《个人信息保护政策》</a>和<a href='https://github.com/iHZW/HZWDemo'>《HZWDemo》</a>";

    AlertView *alertView = [[AlertView alloc] init];
    alertView.title = @"温馨提示";
    alertView.actionType = ActionTypeAlert;
    alertView.messageFont = PASFont(12);
    alertView.message = privacyStr;
    
//    @weakify(alertView)
//    alertView.customCenterViewBlock = ^UIView * _Nonnull{
//        @strongify(alertView)
//        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 127)];
//        HTMLLabel *htmlLabel = [[HTMLLabel alloc] initWithFrame:CGRectMake(32, 10, kMainScreenWidth - 64, 60)];
//        htmlLabel.numberOfLines = 0;
//        htmlLabel.font = PASFont(12);
////        htmlLabel.textColor = UIColorFromRGB(0x999999);
//        htmlLabel.text = privacyStr;
//        htmlLabel.delegate = self;
//
//        htmlLabel.htmlTagClickHandler = ^(NSString *url, NSString *text) {
//            @strongify(alertView)
//            [alertView hidden];
//            ZWCommonWebPage *vc = [[ZWCommonWebPage alloc] init];
//            vc.titleName = __String_Not_Nil(text);
//            vc.url = __String_Not_Nil(url);
////            vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
////            [self presentViewController:vc animated:YES completion:nil];
//            [[UIApplication displayViewController].navigationController pushViewController:vc animated:YES];
//        };
//
//        CGSize textSize = [htmlLabel sizeThatFits:CGSizeMake(CGRectGetWidth(htmlLabel.frame), INFINITY)];
//        htmlLabel.height = textSize.height;
//        [bottomView addSubview:htmlLabel];
//
//        UIButton *agreeBtn = [UIButton buttonWithFrame:CGRectMake(32, CGRectGetMaxY(htmlLabel.frame) + 20, kMainScreenWidth - 64, 50) title:@"同意并继续" font:PASFont(16) titleColor:UIColorFromRGB(0xFFFFFF) block:^{
//            @strongify(alertView)
//            [alertView hidden];
//        }];
//        [agreeBtn setCornerRadius:8];
//        agreeBtn.backgroundColor = UIColorFromRGB(0x3F5FFD);
//        [bottomView addSubview:agreeBtn];
//        bottomView.frame = CGRectMake(0, 0, kMainScreenWidth, CGRectGetMaxY(agreeBtn.frame) + 20);
//        return bottomView;
//    };
    
    alertView.didHiddenBlock = ^{
        
    };
    [alertView show];
}



#pragma mark - HTMLLabelDelegate
//- (BOOL)HTMLLabel:(HTMLLabel *)label shouldOpenURL:(NSURL *)URL
//{
//    return NO;
//}

//- (void)HTMLLabel:(HTMLLabel *)label tappedLinkWithURL:(NSURL *)URL bounds:(CGRect)bounds
//{
//    [self hiddenPrivacyAlertView];
//    [ZWM.router executeURLNoCallBack:ZWDebugPageHome];
//}

@end
