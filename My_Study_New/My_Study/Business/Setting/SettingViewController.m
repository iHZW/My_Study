//
//  SettingViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/30.
//  Copyright © 2022 HZW. All rights reserved.
//``

#import "ActionModel.h"
#import "AlertHead.h"
#import "CommonSelectedConfig.h"
#import "FileSelectManager.h"
#import "LoginViewController.h"
#import "PASIndicatorTableViewCell.h"
#import "PathConstants.h"
#import "PhotoActionSheetUtil.h"
#import "SSZipArchive.h"
#import "SettingViewController.h"
#import "ZWBaseTableView.h"
#import "ZWColorPickInfoWindow.h"
#import "ZWHttpNetworkData.h"
#import "zhThemeOperator.h"

/** 导入other城市选择器  */
#import "BRPickerView/BRPickerView.h"
#import "EHAddressCompHelper.h"

// 城市选择界面
#if __has_include(<JFCitySelector/JFCitySelector.h>)
#import <JFCitySelector/JFCitySelector.h>
#else
#import "JFCitySelector.h"
#endif

#import "ZWUserManager.h"

#import "MMShareManager.h"
#import "MMShareView.h"
#import "NSString+Tool.h"
#import "ZWOneKeyTextVC.h"

#pragma mark - 二维码头文件
#import "QQScanZXingViewController.h"
#import "StyleDIY.h"
#import "Global.h"
#import "ZWCommonWebPage.h"
#import "MMPushUtil.h"

#define kSectionViewHeight 20
#define ZWNSLog(...) printf("%s\n", [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);

@interface SettingViewController () <UITableViewDelegate, UITableViewDataSource, JFCSTableViewControllerDelegate, EHAddressCompHelperDelegate>

/** other城市选择器  */
@property (nonatomic, strong) EHAddressCompHelper *addressHelper;

@property (nonatomic, strong) NSMutableArray *shareArray;

@property (nonatomic, strong) UILabel *bottomLabel;

@end

@implementation SettingViewController

- (void)initExtendedData {
    [super initExtendedData];

    self.dataArray       = [NSMutableArray arrayWithArray:[self getDataArray]];
    self.style           = UITableViewStylePlain;
    self.tableCellClass  = [PASIndicatorTableViewCell class];
    self.heightForHeader = kSectionViewHeight;
    self.cellHeight      = 60;
    self.title           = @"设置";
}

- (void)loadUIData {
    [super loadUIData];

    //    self.tableView.tableHeaderView = [self getHeaderView];
    self.tableView.tableFooterView = [UIView new];
    //    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.tableView.tableFooterView = self.bottomLabel;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-SafeAreaBottomAreaHeight);
    }];

    @pas_weakify_self
        self.cellConfigBlock = ^(NSIndexPath *_Nonnull indexPath, PASIndicatorTableViewCell *cell) {
        @pas_strongify_self
            cell.isShowRightArrow = YES;

        /** 设置选中背景色  */
        cell.selectionStyle         = UITableViewCellSelectionStyleDefault;
        UIView *selectedView        = [UIView viewForColor:UIColorFromRGB(0x87CEFA) withFrame:cell.frame];
        cell.selectedBackgroundView = selectedView;

        NSArray *tempArray                = PASArrayAtIndex(self.dataArray, indexPath.section);
        ActionModel *model                = PASArrayAtIndex(tempArray, indexPath.row);
        cell.leftLabel.text               = TransToString(model.title);
        cell.leftLabel.font               = PASFont(18);
        cell.leftLabel.zh_textColorPicker = ThemePickerColorKey(ZWColorKey_p5);
    };

    self.cellClickBlock = ^(NSIndexPath *_Nonnull indexPath, id _Nonnull cell) {
        @pas_strongify_self
            ActionModel *model = self.dataArray[indexPath.section][indexPath.row];
        NSString *selectAction = model.actionName;
        if (selectAction.length > 0) {
            SEL seletor = NSSelectorFromString(selectAction);
            ((void (*)(id, SEL))objc_msgSend)(self, seletor);
        }
    };
}

- (void)onShowTotalVersion {
    NSString *version = NSString.eh_appBuildVersion;
    //    NSString *month =  [version substringWithRange:NSMakeRange(0, 2)];
    //    NSString *day = [version substringWithRange:NSMakeRange(2, 2)];
    //    NSString *hour = [version substringWithRange:NSMakeRange(4, 2)];
    //    NSString *minute = [version substringWithRange:NSMakeRange(6, 2)];
    //    NSString *second = [version substringWithRange:NSMakeRange(8, 2)];
    //    NSString *formatVersion = [NSString stringWithFormat:@"%@-%@ %@:%@:%@", month, day, hour, minute, second];
    //    self.bottomLabel.text = [NSString stringWithFormat:@"版本v%@ 日期 %@",NSString.eh_mainVersion, formatVersion];

    NSString *dateFormat    = @"MM-dd HH:mm:ss";
    NSDate *resultDate      = [NSDate br_dateFromString:version dateFormat:@"MMddHHmmss"];
    NSString *formatTime    = [NSDate br_stringFromDate:resultDate dateFormat:dateFormat];
    NSString *resultVersion = [NSString stringWithFormat:@"版本v%@ 日期 %@", NSString.eh_mainVersion, formatTime];
    NSLog(@"formatTime = %@", formatTime);
    self.bottomLabel.text = TransToString(resultVersion);
}

#pragma mark -  Lazy loading
/** 懒加载地址选择器  */
- (EHAddressCompHelper *)addressHelper {
    if (!_addressHelper) {
        _addressHelper          = [[EHAddressCompHelper alloc] init];
        _addressHelper.delegate = self;
    }
    return _addressHelper;
}

- (NSArray *)getDataArray {
    NSArray *sec1Arr = @[[ActionModel initWithTitle:@"个人信息" actionName:@"accountInfoSetting"],
                         [ActionModel initWithTitle:@"账户与安全" actionName:@"accountsAndSecurity"],
                         [ActionModel initWithTitle:@"二维码扫描" actionName:@"scanningQRCode"],
                         [ActionModel initWithTitle:@"我的二维码" actionName:@"myQRCode"]];

    NSArray *sec2Arr = @[[ActionModel initWithTitle:@"Alert提示框" actionName:@"alertViewAction"],
                         [ActionModel initWithTitle:@"单选页面" actionName:@"selectedPageAction"],
                         [ActionModel initWithTitle:@"切换皮肤" actionName:@"changeTheme"],
                         [ActionModel initWithTitle:@"文件选择" actionName:@"fileSelect"],
                         [ActionModel initWithTitle:@"拍照/相册/文件" actionName:@"photoFileSelect"],
                         [ActionModel initWithTitle:@"城市选择器" actionName:@"citySelect"],
                         [ActionModel initWithTitle:@"另一种城市选择器" actionName:@"otherCitySelect"],
                         [ActionModel initWithTitle:@"地址微调" actionName:@"changeAddressTrim"],
                         [ActionModel initWithTitle:@"视频" actionName:@"jumpSJVideoPage"],
                         [ActionModel initWithTitle:@"文字转语音" actionName:@"textToSpeechPage"],
                         [ActionModel initWithTitle:@"多边形多拽" actionName:@"drawPolygonView"],

    ];

    NSArray *sec3Arr = @[[ActionModel initWithTitle:@"打开首页底部广告" actionName:@"testShowWindow"],
                         [ActionModel initWithTitle:@"陀螺仪测试界面 ~ 球" actionName:@"testBallViewContorller"],
                         [ActionModel initWithTitle:@"自定义Swiper组件" actionName:@"testSwiperComponent"]];

    NSArray *sec4Arr = @[[ActionModel initWithTitle:@"清除缓存" actionName:@"cleanCacheData"],
                         [ActionModel initWithTitle:@"意见反馈" actionName:@"feedBackDetailInfo"],
                         [ActionModel initWithTitle:@"关于" actionName:@"aboutDetailInfo"]];

    NSArray *sec5Arr = @[[ActionModel initWithTitle:@"用户隐私协议" actionName:@"go2PrivicyAgreement"],
                         [ActionModel initWithTitle:@"交易风险提示" actionName:@"go2TradeRiskTip"],
                         [ActionModel initWithTitle:@"推送测试" actionName:@"push_test"]];

    return @[sec1Arr, sec2Arr, sec3Arr, sec4Arr, sec5Arr];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionHeader                  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kSectionViewHeight)];
    sectionHeader.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p1);
    return sectionHeader;
}

- (UIView *)getHeaderView {
    UIView *headerView                  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 80)];
    headerView.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p8);
    [headerView addSubview:self.tableViewHeader];
    self.tableViewHeader.leftLabel.text   = @"设置相关信息";
    self.tableViewHeader.rightLabel2.text = @"🚓";
    [self.tableViewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(headerView);
    }];
    return headerView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self onShowTotalVersion];

    [self.tableView reloadData];
}

#pragma mark - action
/**
 *  个人信息
 */
- (void)accountInfoSetting {
    ZWUserManager *user     = [ZWUserManager sharedInstance];
    user.name               = @"user";
    ZWUserManager *manager  = [[ZWUserManager alloc] init];
    manager.age             = 32;
    ZWUserManager *manager1 = [ZWUserManager new];
    manager1.gender         = 1;
    ZWUserManager *manager2 = [ZWUserManager copy];
    manager2.nichName       = @"manager2";
    NSLog(@"\nuser = %p\nmanager = %p\nmanager1 = %p\nmanager2 = %p", user, manager, manager1, manager2);

    [self __testShareView];
}

- (NSMutableArray *)shareArray {
    if (!_shareArray) {
        _shareArray = [NSMutableArray array];
        [_shareArray addObject:MMPlatformNameSms];
        [_shareArray addObject:MMPlatformNameEmail];
        [_shareArray addObject:MMPlatformNameSina];
        [_shareArray addObject:MMPlatformNameWechat];
        [_shareArray addObject:MMPlatformNameQQ];
        [_shareArray addObject:MMPlatformNameAlipay];
    }
    return _shareArray;
}

- (void)__testShareView {
    MMShareView *shareView = [[MMShareView alloc] initWithItems:self.shareArray itemSize:CGSizeMake(80, 100) DisplayLine:NO];
    shareView              = [self addShareContent:shareView];
    shareView.itemSpace    = 10;
    @weakify(self)
        shareView.action = ^(MMShareItem *_Nonnull item) {
        @strongify(self)
        //        [self ];
    };
    [shareView showFromControlle:self];
}

// 添加分享的内容
- (MMShareView *)addShareContent:(MMShareView *)shareView {
    [shareView addText:@"分享测试"];
    [shareView addURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    [shareView addImage:[UIImage imageNamed:@"share_alipay"]];

    return shareView;
}

- (void)shareSDK {
    ShareParam *shareParam = [ShareParam new];
    shareParam.desc        = @"测试说明";

    ShareObject *model = [[ShareObject alloc] init];
    model.name         = @"Wechat";
    model.shareParam   = shareParam;
    [MMShareManager shareObject:model complete:^(BOOL y, NSError *_Nullable error){
        //        [Toast show:error.localizedDescription];
    }];

    //    [ShareClient openMiniApp:<#(nonnull ShareObject *)#> complete:<#^(BOOL, NSError * _Nullable)completeBlock#>]
    //
    //    [ShareClient wxLogin:^(NSString * ret, NSError * error) {
    //        @strongify(self)
    //        if (!error){
    //            //[self showProgress];
    //            [self.loginViewModel wxLogin:ret];
    //        } else {
    //            [self startOneKeyAuth];
    //        }
    //    }];
}

/**
 *  账户与安全
 */
- (void)accountsAndSecurity {
}


#pragma mark - 二维码扫描
- (void)scanningQRCode {
    QQScanZXingViewController *vc = [QQScanZXingViewController new];
    vc.style = [StyleDIY qqStyle];
    vc.cameraInvokeMsg = @"相机启动中";
    vc.continuous = [Global sharedManager].continuous;
    vc.orientation = [StyleDIY videoOrientation];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 我的二维码
- (void)myQRCode {
    [self.navigationController pushViewController:[NSClassFromString(@"FindViewController") new] animated:YES];
}




/**
 *  Alert提示框
 */
- (void)alertViewAction {
    [ZWM.router executeURLNoCallBack:ZWRouterPageShowAlertViewController];
}

/**
 *  切换皮肤
 */
- (void)changeTheme {
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
- (void)fileSelect {
    [ZWM.router executeURLNoCallBack:ZWRouterPageFileSelectViewController];
}

/**
 *  拍照/相册/文件
 */
- (void)photoFileSelect {
    @pas_weakify_self
        [PhotoActionSheetUtil showPhotoAlert:9 complete:^(NSArray<PHAssetModel *> *_Nonnull list) {
            @pas_strongify_self
                /* 判断是文件 */
                PHAssetModel *item = [list firstObject];
            if (item.isFile || !item) {
                [self dealWithFile:item];
                return;
            }
            NSMutableArray *paths = [NSMutableArray array];
            for (PHAssetModel *item in list) {
                [paths addObject:[item.originalPath substringFromIndex:7]];
            }
            NSLog(@"paths = %@", paths);
        } isShowFile:YES];
}

/**
 *  城市选择器
 */
- (void)citySelect {
    // 自定义配置...
    JFCSConfiguration *config = [[JFCSConfiguration alloc] init];
    // 关闭拼音搜索
    config.isPinyinSearch = NO;
    // 配置热门城市
    config.popularCitiesMutableArray = [self defealtPopularCities];
    // 配置浮窗类型为中心toast
    config.indexViewType = EHIndexViewStyleCenterToast;

    JFCSTableViewController *vc = [[JFCSTableViewController alloc] initWithConfiguration:config delegate:self];
    [self.navigationController pushViewController:vc animated:YES];
}

// 自定义热门城市
- (NSMutableArray<JFCSPopularCitiesModel *> *)defealtPopularCities {
    JFCSPopularCitiesModel *bjModel = [[JFCSPopularCitiesModel alloc] initWithName:@"北京" type:JFCSPopularCitiesTypeCity];
    JFCSPopularCitiesModel *shModel = [[JFCSPopularCitiesModel alloc] initWithName:@"上海" type:JFCSPopularCitiesTypeCity];
    JFCSPopularCitiesModel *gzModel = [[JFCSPopularCitiesModel alloc] initWithName:@"广州" type:JFCSPopularCitiesTypeCity];
    JFCSPopularCitiesModel *szModel = [[JFCSPopularCitiesModel alloc] initWithName:@"深圳" type:JFCSPopularCitiesTypeCity];
    JFCSPopularCitiesModel *hzModel = [[JFCSPopularCitiesModel alloc] initWithName:@"杭州" type:JFCSPopularCitiesTypeCity];
    return [NSMutableArray arrayWithObjects:bjModel, shModel, gzModel, szModel, hzModel, nil];
}

/**
 * 另一种城市选择器
 */
- (void)otherCitySelect {
    [self.addressHelper showAddressView];
}

/**
 *  地址微调
 */
- (void)changeAddressTrim {
    [ZWM.router executeURLNoCallBack:ZWRouterPageLocationTrimViewController];
}

/**
 * 视频
 */
- (void)jumpSJVideoPage {
    [ZWM.router executeURLNoCallBack:ZWRouterPageSJVideoController];
}

/**
 * 文字转语音
 */
- (void)textToSpeechPage {
    [ZWM.router executeURLNoCallBack:ZWRouterPageTextToSpeechViewController];
}

/**
 * 绘制多边形
 */
- (void)drawPolygonView {
    [ZWM.router executeURLNoCallBack:ZWRouterPageDrawPolygonViewController];
}


- (void)_testOpenDebugHml {
    NSString *hybridserverPath = [PathConstants gcdWebServerRootDirectory];
    NSString * webPath = [NSString stringWithFormat:@"%@/debug.html",hybridserverPath];
    NSURL *webUrl = [NSURL fileURLWithPath:webPath];
    
    ZWCommonWebPage *webPage = [[ZWCommonWebPage alloc] init];
    [webPage loadUrl:webUrl];
    
    [self.navigationController pushViewController:webPage animated:YES];
}

/**
 *  清除缓存
 */
- (void)cleanCacheData {
    BOOL isCrash = NO;
    /**
     *  try catch 异常捕获 局限性,只能捕获 数组越界 等异常 其他异常捕获不到
     */
    //    @try {
    //        NSMutableArray *data = [NSMutableArray array];
    //        //        id a = [data objectAtIndex:2];
    //        [data addObject:nil];
    //    } @catch (NSException *exception) {
    //        NSLog(@ "%s\n%@", __FUNCTION__, exception);
    //    } @finally {
    //    }
    //    NSLog(@"isCrash = %@", @(isCrash));

//        [self _testOpenDebugHml];
//    
//        return;
    
    NSString *copyFileName = @"demo";
    /** 复制本地demo.html到沙目录  */
    NSString *demoHtmlPath = [NSBundle.mainBundle pathForResource:copyFileName ofType:@"html"];
    NSString *toDemoHtmlPath = [NSString stringWithFormat:@"%@/%@.html", [PathConstants gcdWebServerRootDirectory], copyFileName];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL isSuccessOne = [fileManager copyItemAtPath:demoHtmlPath toPath:toDemoHtmlPath error:&error];
    
    
//    NSString *zipFileName = @"debug";
    NSString *zipFileName = @"dist";
    NSString *hybridserverPath = [PathConstants gcdWebServerRootDirectory];
    NSString *filePath = [NSBundle.mainBundle pathForResource:zipFileName ofType:@"zip"];
    NSString *preversionPath = [PathConstants preversionDirectory];
    NSString *downPath = [PathConstants downLoadDirectory];
    NSString *fileName = [NSString stringWithFormat:@"%@.zip", zipFileName];;
    NSString *toDownLoadPath = [NSString stringWithFormat:@"%@/%@", downPath, fileName];
    NSString *toPreversionPath = [NSString stringWithFormat:@"%@/%@", preversionPath, fileName];

    [SSZipArchive unzipFileAtPath:filePath toDestination:hybridserverPath progressHandler:^(NSString *_Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {

    } completionHandler:^(NSString *_Nonnull path, BOOL succeeded, NSError *_Nullable error) {
        if (succeeded) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            BOOL isSuccessOne = [fileManager copyItemAtPath:filePath toPath:toDownLoadPath error:&error];
            BOOL isSuccessTwo = [fileManager copyItemAtPath:filePath toPath:toPreversionPath error:&error];
            NSLog(@"isSuccessOne = %d\nisSuccessTwo = %d", isSuccessOne, isSuccessTwo);
        }
    }];

    [self _testDebugZip];
}

#pragma mark - 测试H5zip包
- (void)_testDebugZip {
    NSString *copyFileName = @"images";
    NSString *hybridserverPath = [PathConstants gcdWebServerRootDirectory];
    NSString *filePath = [NSBundle.mainBundle pathForResource:copyFileName ofType:@"zip"];
    NSString *preversionPath = [PathConstants preversionDirectory];
    NSString *downPath = [PathConstants downLoadDirectory];
    NSString *fileName = [NSString stringWithFormat:@"%@.zip", copyFileName];
    NSString *toDownLoadPath = [NSString stringWithFormat:@"%@/%@", downPath, fileName];
    NSString *toPreversionPath = [NSString stringWithFormat:@"%@/%@", preversionPath, fileName];

    [SSZipArchive unzipFileAtPath:filePath toDestination:hybridserverPath progressHandler:^(NSString *_Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {

    } completionHandler:^(NSString *_Nonnull path, BOOL succeeded, NSError *_Nullable error) {
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
- (void)feedBackDetailInfo {
    NSString *hybridserverPath = [PathConstants gcdWebServerRootDirectory];
    NSString *downPath         = [PathConstants downLoadDirectory];
    NSString *preversionPath   = [PathConstants preversionDirectory];
    NSString *fileName         = @"safe.zip";
    NSString *filePath         = [NSString stringWithFormat:@"%@/%@", downPath, fileName];

    @weakify(self)
        [SSZipArchive unzipFileAtPath:filePath toDestination:hybridserverPath progressHandler:^(NSString *_Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {

        } completionHandler:^(NSString *_Nonnull path, BOOL succeeded, NSError *_Nullable error) {
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
- (void)aboutDetailInfo {
    NSString *format = @"%@_1111_%.2f_3333";
    ZWDebugLog(format, @"0000", @"22222");
    NSString *formatStr = ZWDebugLogStr(format, @"666", 888.2);
    formatStr           = ZWFormatterUrl(format, @"777", 0.006);
    NSLog(@"formatStr = %@", formatStr);
    
    NSString *url = @"https://pages/subPkgsTax/taxClubDetail/index/?id=1005431829342217&news_section=undefined&pushTimeBbzl=1691673134079&openChannelBbzl=wechat&templateNameBbzl=%E5%85%B3%E4%BA%8E%E5%8D%B0%E8%8A%B1%E7%A8%8E%E4%B8%AD%E7%9A%84%E4%B9%B0%E5%8D%96%E5%90%88%E5%90%8C%EF%BC%8C%E9%87%87%E8%B4%AD%E7%9A%84%E5%95%86%E5%93%81%E7%AD%BE%E7%9A%84%E6%98%AF%E6%A1%86%E6%9E%B6%E5%90%88%E5%90%8C%EF%BC%8C%E7%84%B6%E5%90%8E%E9%87%87%E8%B4%AD%E5%AD%98%E5%9C%A8%E5%B9%B3%E9%94%80%E8%BF%94%E5%88%A9%EF%BC%8C%E6%98%AF%E5%90%A6%E5%9C%A8%E8%AE%A1%E7%A8%8E%E6%97%B6%E5%8F%AF%E6%89%A3%E5%87%8F%E7%9B%B8%E5%BA%94%E8%BF%94%E5%88%A9%E9%87%91%E9%A2%9D%EF%BC%9F&templateContentBbzl=%E6%A0%B9%E6%8D%AE%E3%80%8A%E5%8D%B0%E8%8A%B1%E7%A8%8E%E6%B3%95%E3%80%8B%E7%AC%AC%E4%BA%94%E6%9D%A1%26ldquo...%E5%BA%94%E7%A8%8E%E5%90%88%E5%90%8C%E7%9A%84%E8%AE%A1%E7%A8%8E%E4%BE%9D%E6%8D%AE%EF%BC%8C%E4%B8%BA%E5%90%88%E5%90%8C%E6%89%80%E5%88%97%E7%9A%84%E9%87%91%E9%A2%9D%EF%BC%8C%E4%B8%8D%E5%8C%85%E6%8B%AC%E5%88%97%E6%98%8E%E7%9A%84%E5%A2%9E%E5%80%BC%E7%A8%8E%E7%A8%8E%E6%AC%BE&rdquo...";
    NSURL *tempUrl = [NSURL URLWithString:url];
    NSLog(@"tempUrl = %@", tempUrl);

    //    LoginViewController *oneKeyLoginVc = [[LoginViewController alloc] init];
    //    oneKeyLoginVc.oneKeyLogin = YES;
    //    [self presentViewController:oneKeyLoginVc animated:YES completion:nil];
    //    [self.navigationController pushViewController:oneKeyLoginVc animated:YES];
}

static inline void ZWDebugLog(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *message       = [[NSString alloc] initWithFormat:format arguments:args];
    NSString *hodoerMessage = [NSString stringWithFormat:@"\n------------WMRemoteLog外部打印:------------\n%@", message];
    ZWNSLog(@"abc");
    ZWNSLog(hodoerMessage, args);
    ZWNSLog(@"def");
    va_end(args);
}

static inline NSString *ZWDebugLogStr(NSString *format, ...) {
    NSString *resultStr = @"";
    va_list args;
    va_start(args, format);
    resultStr = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return resultStr;
}

/**
 *  用户隐私协议
 */
- (void)go2PrivicyAgreement {
}

- (void)dealWithFile:(PHAssetModel *)fileItem {
    if (fileItem) {
    }

    //    弱引用表
    //    NSMapTable
}

/**
 *  交易风险提示
 */
- (void)go2TradeRiskTip {
    [ZWM.router executeURLNoCallBack:ZWRouterRunLoopPermanentViewController];
}

/**
 *  单选界面
 */
- (void)selectedPageAction {
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    mutDict[kIsLoadSureBtn]      = @(NO);
    mutDict[kDataList]           = @[@{kSelectName: @"111", @"type": @"1"},
                           @{kSelectName: @"222", @"type": @"2"},
                           @{kSelectName: @"333", @"type": @"3"},
                           @{kSelectName: @"444", @"type": @"4"}];
    mutDict[kSelectName]         = @"444";

    RouterParam *param = [RouterParam makeWith:ZWRouterPageChangeEnvViewController destURL:@"SelectedViewController" params:mutDict.copy type:RouterTypeNavigate context:nil success:^(NSDictionary *result) {
        if ([result isKindOfClass:NSDictionary.class]) {
            NSLog(@"result = %@", result);
        }
    } fail:^(NSError *error){

    }];

    [ZWM.router executeRouterParam:param];
}

/**
 *  打开首页底部广告
 */
- (void)testShowWindow {
    [[ZWColorPickInfoWindow shareInstance] showView];
    CALayer *layer        = [[CALayer alloc] init];
    layer.shouldRasterize = YES; // 可以光栅化
    layer.cornerRadius    = 10;
    layer.masksToBounds   = YES;
    //    layer.mask
}

/**
 *  陀螺仪测试界面 ~ 球
 */
- (void)testBallViewContorller {
    [ZWM.router executeURLNoCallBack:ZWRouterPageBallViewController];
}

/**
 * 自定义Swiper组件
 */
- (void)testSwiperComponent {
    [ZWM.router executeURLNoCallBack:ZWRouterPageCustomSwiperController];
}

/**
 * 测试推送
 */
- (void)push_test {
    [self pushLocalNotification:@"测试本地推送使用"];
}

- (void)pushLocalNotification:(NSString *)title {
    
    [MMPushUtil pushLocalNotification:title userInfo:@{@"payload" : @{}}];

    return;
    // 创建本地通知时，清理之前所有的本地通知，注意：根据App具体的功能自行修改
    // 清理所有本地通知，程序启动时清理，注意：根据App具体功能需求自行修改，如果App内有其他本地通知，更加需要注意是否要清理所有通知
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    NSString *gmid                   = nil;
    UILocalNotification *localNotify = [[UILocalNotification alloc] init];
    NSDate *pushDate                 = [NSDate dateWithTimeIntervalSinceNow:1];

    localNotify.fireDate                   = pushDate;
    localNotify.timeZone                   = [NSTimeZone defaultTimeZone];
    localNotify.repeatInterval             = kCFCalendarUnitDay;
    localNotify.soundName                  = UILocalNotificationDefaultSoundName;
    localNotify.alertBody                  = [NSString stringWithFormat:@"Payload : %@\ntime : %@", title, [self formateTime:[NSDate date]]];
    localNotify.alertAction                = NSLocalizedString(@"View Details", nil);
    NSArray *notifyArray                   = [[UIApplication sharedApplication] scheduledLocalNotifications];
    int count                              = (int)[notifyArray count];
    localNotify.applicationIconBadgeNumber = count + 1;
    // 备注：点击统计需要
    if (gmid != nil) {
        NSDictionary *userInfoDict = @{@"_gmid_": gmid};
        localNotify.userInfo       = userInfoDict;
    }
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotify];
}

- (NSString *)formateTime:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:date];
    return dateTime;
}

#pragma mark-- JFCSTableViewControllerDelegate

- (void)viewController:(JFCSTableViewController *)viewController didSelectCity:(JFCSBaseInfoModel *)model {
    // 选择城市后...
    NSLog(@"name %@ code %zd pinyin %@ alias %@ firstLetter %@", model.name, model.code, model.pinyin, model.alias, model.firstLetter);
    //    [self.cityBtn setTitle:model.name forState:UIControlStateNormal];
}

#pragma mark - EHAddressCompHelperDelegate
- (void)areaViewEndChange:(NSString *)text areaCode:(NSString *)areaCode {
    NSLog(@"text:%@ areaCode:%@", text, areaCode);
}

#pragma mark -  Lazy loading
- (UILabel *)bottomLabel {
    if (!_bottomLabel) {
        _bottomLabel = [UILabel labelWithFrame:CGRectMake(0, 0, kMainScreenWidth, 60) text:@"" textColor:UIColorFromRGB(0X111111)];
    }
    return _bottomLabel;
}

@end
