//
//  SelectAddressUtil.m
//  CRM
//
//  Created by js on 2019/12/2.
//  Copyright © 2019 js. All rights reserved.
//

#import "SelectAddressUtil.h"
//#import "CorporationCreateViewModel.h"
#import "AddressView.h"
#import "SPModalView.h"
/** 系统权限类  */
#import "Permission.h"
#import "NSArray+Func.h"
#import "UIView+SVG.h"
#import "UIColor+Extensions.h"
#import "ZWSDK.h"
#import "LocationManager.h"

@interface SelectAddressUtil()<AddressViewDelegate,SPModalViewDelegate>
//@property (nonatomic, strong) CorporationCreateViewModel *viewModel;

@property (nonatomic, copy) NSString *accountId;

@property (nonatomic, strong) SPArea *selectedProvince;
@property (nonatomic, strong) SPArea *selectedCity;
@property (nonatomic, strong) SPArea *selectedArea;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) SPModalView *modalView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) AddressView *addressView;
@property (nonatomic, strong) SPPickerView *pickerView;
@property (nonatomic, strong) NSArray *areaInfos;
@property (nonatomic, copy) SelectAddressCompleteBlock selectCompleteBlock;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *buttonLocationLabel;

@end

@implementation SelectAddressUtil
+ (instancetype)sharedInstance{
    static SelectAddressUtil *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SelectAddressUtil alloc] init];
    });
    return _instance;
}

- (instancetype)init{
    self = [super init];
    if (self){
        [self initConfig];
    }
    return self;
}



- (void)initConfig{
//    @weakify(self)
//    [self.viewModel.requestEventSubject subscribeNext:^(RACEventObject *eventObject) {
//        BaseResponse *baseResponse = eventObject.value;
//        @strongify(self)
//        if (baseResponse.isSuccess){
//            if (eventObject.tag == CORPORATION_CREATE){
//
//            } else {
//                [self.addressView setData:baseResponse.data index:self.index];
//                [self.pickerView sp_scrollToComponent:self.index atComponentScrollPosition:SPPickerViewComponentScrollPositionDefault animated:YES];
//            }
//        }
//    }];
}


- (void)showInViewController:(UIViewController *)viewController complete:(SelectAddressCompleteBlock)completeBlock{
    self.selectCompleteBlock = completeBlock;
    
    self.modalView = [[SPModalView alloc] initWithView:self.contentView inBaseViewController:viewController];
    self.modalView.delegate =self;
    self.modalView.narrowedOff = YES;
    
//    [self.viewModel getAreaData:@"" levelType:@"1"];
    [self.modalView show];
    
    id<PermissionProtocol> permission = [Permission objectForType:PermissionTypeLocationWhenInUse];
    if ([permission isAuthorized]){
        self.buttonLocationLabel.text = @"重新定位";
        self.locationLabel.text = @"";
        [self requestLocation:NO];
    } else {
        self.buttonLocationLabel.text = @"开启定位";
        self.locationLabel.text = @"定位服务未开启";
    }
}

- (void)autoFetchGPRSLocation:(SelectAddressCompleteBlock)completeBlock{
    self.selectCompleteBlock = completeBlock;
    id<PermissionProtocol> permission = [Permission objectForType:PermissionTypeLocationWhenInUse];
    if ([permission isAuthorized]){
        [self requestLocation:YES];
    }
}

- (void)closeControlForSPModalView{
    [self.modalView close];
    self.index = 0;
    self.areaInfos = nil;
    [self.addressView removeAllItem];
}

- (void)sp_pickerViewForAddressView:(SPPickerView *)pickerView model:(SPArea *)model inComponent:(NSInteger)component{
    self.index = component+1;
    self.pickerView = pickerView;
//    [self.viewModel getAreaData:model.areaCode levelType:[NSString stringWithFormat:@"%ld",model.levelType + 1]];
}


- (void)sp_pickerViewForAddressViewTapClose:(SPPickerView *)pickerView{
    [self closeControlForSPModalView];
}


- (void)gprsLocationAction:(id)sender{
    if (self.areaInfos.count == 3){
        [self chooseAddress:self.areaInfos[0] city:self.areaInfos[1] district:self.areaInfos[2]];
    }
}

- (void)requestPermissionAction:(id)sender{
    [Permission requestForType:PermissionTypeLocationWhenInUse notAuthorizedMessage: [self.accountId  isEqual: @""] ? @"此功能需要使用“位置”，打开后，可正常展示附近企业相关信息。<br/><br/>是否同意使用位置？如需使用，请在“系统设置”或授权对话框中允许“位置”权限。" : @"My_Study被禁止访问您的“位置”，将不能正常展示附近企业相关信息。<br/><br/>如需使用，请在“系统设置”或授权对话框中允许“位置”权限。" complete:^(PermissionAuthorizationStatus status) {
        if (status == PermissionAuthorizationStatusAuthorized){
            self.buttonLocationLabel.text = @"重新定位";
            if (self.pagename) {
//                [StatisticsUtil addStatistic:@"change_ip" eventType:@"tap" pageName:self.pagename additionInfo:nil];
            }
            [self requestLocation:NO];
        }
    }];
}

- (void)requestLocation:(BOOL)autoFetch{
    @weakify(self)
    [[LocationManager shareLocationManager] requestLocationWithReGeocode:YES completionBlock:^(JXLocation *location, NSError *error) {
        @strongify(self)
        if(error == nil){
            [self requestLocationAreaInfo:location.zone autoFetch:autoFetch];
        } else {

        }
    }];
}

- (void)requestLocationAreaInfo:(NSString *)areaCode autoFetch:(BOOL)autoFetch{
//    BaseRequest *request = [BaseRequest defaultRequest];
//    request.data = @{
//        @"areaCode" : __String_Not_Nil(areaCode)
//    };
//    @weakify(self)
//    [WM.http post:API_ADDRESS_AREAINFO requestModel:request complete:^(ResultObject * result) {
//        @strongify(self)
//        if (result.isSuccess){
//           NSArray *areaInfos = [JSONUtil parseObjectArrays:result.data targetClass:SPArea.class];
//            self.areaInfos = areaInfos;
//            if (autoFetch){
//                if (self.areaInfos.count == 3){
//                    [self chooseAddress:self.areaInfos[0] city:self.areaInfos[1] district:self.areaInfos[2]];
//                }
//            } else {
//                [self updateLocationView];
//            }
//        }
//    }];
}

- (void)updateLocationView{
    NSString *name = [[self.areaInfos flatMap:^id _Nonnull(SPArea  *item) {
        return item.areaName;
    }] componentsJoinedByString:@"/"];
    self.locationLabel.text = name;
}
#pragma mark - Properties

- (UIView *)contentView{
    if (!_contentView){
        _contentView = [[UIView alloc] init];
        _contentView.frame = CGRectMake(0, 0, kScreenWidth, 460);
        [_contentView addSubview:self.headerView];
        [_contentView addSubview:self.addressView];

    }
    return _contentView;
}

- (UIView *)headerView{
    if (!_headerView){
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 86)];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, kScreenWidth - 32, 13)];
        titleLabel.font = PASFont(13);
        titleLabel.textColor = [UIColor colorFromHexString:@"#999999"];
        titleLabel.text = @"当前定位";
        [_headerView addSubview:titleLabel];
        
        
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage svg_imageNamed:@"Icon_location"]];
        icon.frame = CGRectMake(16, 45, 14, 15);
        [_headerView addSubview:icon];
        
        UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(36, 30, kScreenWidth - 36 - 68, 45)];
        locationLabel.font = PASFont(15);
        locationLabel.textColor = [UIColor colorFromHexString:@"#333333"];
        locationLabel.text = @"";
        locationLabel.userInteractionEnabled = YES;
        self.locationLabel = locationLabel;
        [_headerView addSubview:locationLabel];
        UITapGestureRecognizer *gprsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gprsLocationAction:)];
        [locationLabel addGestureRecognizer:gprsTap];
        
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth - 68, 30, 68, 45)];
        [_headerView addSubview:rightView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(requestPermissionAction:)];
        [rightView addGestureRecognizer:tap];
        
        UILabel *buttonLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 68,15)];
        buttonLocationLabel.font = PASFont(13);
        buttonLocationLabel.textColor = [UIColor colorFromHexString:@"#4F7AFD"];
        self.buttonLocationLabel = buttonLocationLabel;
        [rightView addSubview:buttonLocationLabel];
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 76, kScreenWidth, 10)];
        separatorView.backgroundColor = [UIColor colorFromHexString:@"#F7F7F7"];
        [_headerView addSubview:separatorView];
        
    }
    return _headerView;
}

- (AddressView *)addressView {
    
    if (!_addressView) {
        _addressView = [[AddressView alloc] init];
        _addressView.frame = CGRectMake(0, 86, kScreenWidth, 374);
        _addressView.delegate = self;
        // 最后一列的行被点击的回调
        @weakify(self)
        _addressView.lastComponentClickedBlock = ^(SPArea *selectedProvince, SPArea *selectedCity, SPArea *selectedDistrict) {
            @strongify(self)
            [self chooseAddress:selectedProvince city:selectedCity district:selectedDistrict];
        };
    }
    return _addressView;
}

- (void)chooseAddress:(SPArea *)selectedProvince city:(SPArea *)selectedCity district:(SPArea *)selectedDistrict{
    [self.modalView hide];
    self.index = 0;
    self.areaInfos = nil;
    [self.addressView removeAllItem];
    BlockSafeRun(self.selectCompleteBlock,selectedProvince,selectedCity,selectedDistrict);
}


//- (CorporationCreateViewModel *)viewModel{
//    if (!_viewModel){
//        _viewModel = [[CorporationCreateViewModel alloc] initWith:[CRMVMConverter converter:SPArea.class]];
//    }
//    return _viewModel;
//}
@end
