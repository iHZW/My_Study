//
//  SettingViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/30.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "SettingViewController.h"
#import "ZWBaseTableView.h"
#import "ZWHttpNetworkData.h"
#import "AlertHead.h"
#import "zhThemeOperator.h"
#import "PASIndicatorTableViewCell.h"
#import "ActionModel.h"
#import "CommonSelectedConfig.h"
#import "FileSelectManager.h"
#import "PhotoActionSheetUtil.h"
#import "ZWColorPickInfoWindow.h"
#import "PathConstants.h"
#import "SSZipArchive.h"

#define kSectionViewHeight              20
#define ZWNSLog(...)  printf("%s\n", [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);


@interface SettingViewController () <UITableViewDelegate, UITableViewDataSource>


@end

@implementation SettingViewController

- (void)initExtendedData
{
    [super initExtendedData];
    
    self.dataArray = [NSMutableArray arrayWithArray:[self getDataArray]];
    self.style = UITableViewStylePlain;
    self.tableCellClass = [PASIndicatorTableViewCell class];
    self.heightForHeader = kSectionViewHeight;
    self.cellHeight = 60;
    self.title = @"设置";

}

- (void)loadUIData
{
    [super loadUIData];
    
//    self.tableView.tableHeaderView = [self getHeaderView];
    self.tableView.tableFooterView = [UIView new];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-SafeAreaBottomAreaHeight);
    }];
    
    @pas_weakify_self
    self.cellConfigBlock = ^(NSIndexPath * _Nonnull indexPath, PASIndicatorTableViewCell *cell) {
        @pas_strongify_self
        cell.isShowRightArrow = YES;
        
        /** 设置选中背景色  */
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        UIView *selectedView = [UIView viewForColor:UIColorFromRGB(0x87CEFA) withFrame:cell.frame];
        cell.selectedBackgroundView = selectedView;

        NSArray *tempArray = PASArrayAtIndex(self.dataArray, indexPath.section);
        ActionModel *model = PASArrayAtIndex(tempArray, indexPath.row);
        cell.leftLabel.text = TransToString(model.title);
        cell.leftLabel.font = PASFont(18);
        cell.leftLabel.zh_textColorPicker = ThemePickerColorKey(ZWColorKey_p5);
    };

    self.cellClickBlock = ^(NSIndexPath * _Nonnull indexPath, id  _Nonnull cell) {
        @pas_strongify_self
        ActionModel *model = self.dataArray[indexPath.section][indexPath.row];
        NSString *selectAction = model.actionName;
        if (selectAction.length >0) {
            SEL seletor = NSSelectorFromString(selectAction);
            ((void (*)(id, SEL))objc_msgSend)(self,seletor);
        }
    };
}


- (NSArray *)getDataArray
{
    NSArray *sec1Arr = @[[ActionModel initWithTitle:@"个人信息" actionName:@"accountInfoSetting"],
                         [ActionModel initWithTitle:@"账户与安全" actionName:@"accountsAndSecurity"]];
   
    NSArray *sec2Arr = @[[ActionModel initWithTitle:@"Alert提示框" actionName:@"alertViewAction"],
                         [ActionModel initWithTitle:@"单选页面" actionName:@"selectedPageAction"],
                         [ActionModel initWithTitle:@"切换皮肤" actionName:@"changeTheme"],
                         [ActionModel initWithTitle:@"文件选择" actionName:@"fileSelect"],
                         [ActionModel initWithTitle:@"拍照/相册/文件" actionName:@"photoFileSelect"],
                         [ActionModel initWithTitle:@"地址微调" actionName:@"changeAddressTrim"]];
    
    NSArray *sec3Arr = @[[ActionModel initWithTitle:@"打开首页底部广告" actionName:@"testShowWindow"],
                         [ActionModel initWithTitle:@"陀螺仪测试界面 ~ 球" actionName:@"testBallViewContorller"]];
    
    NSArray *sec4Arr = @[[ActionModel initWithTitle:@"清除缓存" actionName:@"cleanCacheData"],
                         [ActionModel initWithTitle:@"意见反馈" actionName:@"feedBackDetailInfo"],
                         [ActionModel initWithTitle:@"关于" actionName:@"aboutDetailInfo"]];
    
    NSArray *sec5Arr = @[[ActionModel initWithTitle:@"用户隐私协议" actionName:@"go2PrivicyAgreement"],
                         [ActionModel initWithTitle:@"交易风险提示" actionName:@"go2TradeRiskTip"]];
    
    return @[sec1Arr,sec2Arr,sec3Arr,sec4Arr,sec5Arr];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kSectionViewHeight)];
    sectionHeader.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p1);
    return sectionHeader;
}



- (UIView *)getHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 80)];
    headerView.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p8);
    [headerView addSubview:self.tableViewHeader];
    self.tableViewHeader.leftLabel.text = @"设置相关信息";
    self.tableViewHeader.rightLabel2.text = @"🚓";
    [self.tableViewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(headerView);
    }];
    return headerView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}



#pragma mark - action
/**
 *  个人信息
 */
- (void)accountInfoSetting
{
    
}

/**
 *  账户与安全
 */
- (void)accountsAndSecurity
{
    
}

/**
 *  Alert提示框
 */
- (void)alertViewAction
{
    
    [ZWM.router executeURLNoCallBack: ZWRouterPageShowAlertViewController];
    
}

/**
 *  切换皮肤
 */
- (void)changeTheme
{
    NSArray *themeAray = @[AppThemeLight, AppThemeNight, AppThemeStyle1, AppThemeStyle2, AppThemeStyle3];
    [UIAlertUtil showAlertTitle:@"切换皮肤" message:@"" cancelButtonTitle:@"取消" otherButtonTitles:themeAray alertControllerStyle:UIAlertControllerStyleActionSheet actionBlock:^(NSInteger index) {
        if (index > 0) {
            NSString *themeKey = PASArrayAtIndex(themeAray, index - 1);
            [zhThemeOperator changeThemeStyleWithKey:themeKey];
        }
    } superVC:self];
}

/**
 *  切换环境
 */
- (void)fileSelect
{
    [ZWM.router executeURLNoCallBack:ZWRouterPageFileSelectViewController];
}

/**
 *  拍照/相册/文件
 */
- (void)photoFileSelect
{
    @pas_weakify_self
    [PhotoActionSheetUtil showPhotoAlert:9 complete:^(NSArray<PHAssetModel *> * _Nonnull list) {
        @pas_strongify_self
        /* 判断是文件 */
        PHAssetModel *item  = [list firstObject];
        if (item.isFile || !item) {
            [self dealWithFile:item];
            return;
        }
        NSMutableArray * paths = [NSMutableArray array];
        for (PHAssetModel * item in list) {
            [paths addObject:[item.originalPath substringFromIndex:7]];
        }
        NSLog(@"paths = %@", paths);
    } isShowFile:YES];
}

/**
 *  地址微调
 */
- (void)changeAddressTrim
{
    [ZWM.router executeURLNoCallBack:ZWRouterPageLocationTrimViewController];
}

/**
 *  清除缓存
 */
- (void)cleanCacheData
{
    BOOL isCrash = NO;
    /**
     *  try catch 异常捕获 局限性,只能捕获 数组越界 等异常 其他异常捕获不到
     */
    @try {
        NSMutableArray *data = [NSMutableArray array];
//        id a = [data objectAtIndex:2];
        [data addObject:nil];
    } @catch (NSException *exception) {
        NSLog(@ "%s\n%@" , __FUNCTION__, exception);
    } @finally {
        
    }
    NSLog(@"isCrash = %@", @(isCrash));
    
    NSString *hybridserverPath = [PathConstants gcdWebServerRootDirectory];
    NSString *filePath = [NSBundle.mainBundle pathForResource:@"safe" ofType:@"zip"];
    NSString *preversionPath = [PathConstants preversionDirectory];
    NSString *downPath = [PathConstants downLoadDirectory];
    NSString *fileName = @"safe.zip";
    NSString *toDownLoadPath = [NSString stringWithFormat:@"%@/%@", downPath, fileName];
    NSString *toPreversionPath = [NSString stringWithFormat:@"%@/%@", preversionPath, fileName];

    @weakify(self)
    [SSZipArchive unzipFileAtPath:filePath toDestination:hybridserverPath progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
        
    } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
        @strongify(self)
        if (succeeded) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            BOOL isSuccessOne = [fileManager copyItemAtPath:filePath toPath:toDownLoadPath error:&error];
            BOOL isSuccessTwo = [fileManager copyItemAtPath:filePath toPath:toPreversionPath error:&error];
            NSLog(@"isSuccessOne = %d\nisSuccessTwo = %d", isSuccessOne, isSuccessTwo);
        }
    }];
    
}

/**
 *  意见反馈
 */
- (void)feedBackDetailInfo
{
    NSString *hybridserverPath = [PathConstants gcdWebServerRootDirectory];
    NSString *downPath = [PathConstants downLoadDirectory];
    NSString *preversionPath = [PathConstants preversionDirectory];
    NSString *fileName = @"safe.zip";
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", downPath, fileName];
    
    @weakify(self)
    [SSZipArchive unzipFileAtPath:filePath toDestination:hybridserverPath progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
        
    } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
        @strongify(self)
        NSLog(@"succeeded = %@", @(succeeded));
        if (succeeded) {
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            BOOL isSuccessOne = [fileManager removeItemAtPath:downPath error:&error];
            NSLog(@"isSuccessOne = %d", isSuccessOne);
        }
    }];
        
}

/**
 *  关于
 */
- (void)aboutDetailInfo
{
    
    
    
    NSString *format = @"%@_1111_%.2f_3333";
    ZWDebugLog(format, @"0000", @"22222");
    NSString *formatStr = ZWDebugLogStr(format, @"666", 888.2);
    formatStr = ZWFormatterUrl(format, @"777", 0.006);
    NSLog(@"formatStr = %@", formatStr);
}

static inline void ZWDebugLog (NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    NSString *hodoerMessage = [NSString stringWithFormat:@"\n------------WMRemoteLog外部打印:------------\n%@", message];
    ZWNSLog(@"abc");
    ZWNSLog(hodoerMessage, args);
    ZWNSLog(@"def");
    va_end(args);
}

static inline NSString * ZWDebugLogStr (NSString *format, ...) {
    NSString *resultStr = @"";
    va_list args;
    va_start(args, format);
    resultStr = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return  resultStr;
}



/**
 *  用户隐私协议
 */
- (void)go2PrivicyAgreement
{

}

- (void)dealWithFile:(PHAssetModel *)fileItem {
    if (fileItem) {

    }
}


/**
 *  交易风险提示
 */
- (void)go2TradeRiskTip
{

}

/**
 *  单选界面
 */
- (void)selectedPageAction
{
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    mutDict[kIsLoadSureBtn] = @(NO);
    mutDict[kDataList] = @[@{kSelectName : @"111", @"type": @"1"},
                           @{kSelectName : @"222", @"type": @"2"},
                           @{kSelectName : @"333", @"type": @"3"},
                           @{kSelectName : @"444", @"type": @"4"}];
    mutDict[kSelectName] = @"444";
    
    RouterParam *param = [RouterParam makeWith:ZWRouterPageChangeEnvViewController destURL:@"SelectedViewController" params:mutDict.copy type:RouterTypeNavigate context:nil success:^(NSDictionary *result) {
        if ([result isKindOfClass:NSDictionary.class]){
            NSLog(@"result = %@", result);
        }
        
    } fail:^(NSError * error) {
        
    }];
    
    [ZWM.router executeRouterParam:param];
}

/**
 *  打开首页底部广告
 */
- (void)testShowWindow
{
    [[ZWColorPickInfoWindow shareInstance] showView];
    
}

/**
 *  陀螺仪测试界面 ~ 球
 */
- (void)testBallViewContorller
{
    [ZWM.router executeURLNoCallBack:ZWRouterPageBallViewController];
}

@end
