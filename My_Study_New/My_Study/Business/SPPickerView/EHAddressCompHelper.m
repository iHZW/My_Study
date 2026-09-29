//
//  EHAddressCompHelper.m
//  My_Study
//
//  Created by hzw on 2022/11/18.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "EHAddressCompHelper.h"
#import "AddressView.h"
#import "SPModalView.h"
#import "UIApplication+Ext.h"

#import "LeftDrawerDataLoader.h"

@interface EHAddressCompHelper () <SPModalViewDelegate, AddressViewDelegate>

@property (nonatomic, strong) AddressView *addressView;

@property (nonatomic, strong) SPPickerView *pickerView;

@property (nonatomic, strong) SPModalView *modalView;
/** 请求地址信息使用  */
@property (nonatomic, strong) LeftDrawerDataLoader *dataLoader;

@end

@implementation EHAddressCompHelper

- (instancetype)init {
    if (self = [super init]) {
        self.addressView.tag = 0;
        
        self.dataLoader = [[LeftDrawerDataLoader alloc] init];
    }
    return self;
}

- (void)showAddressView {
    __weak EHAddressCompHelper *weakSelf = self;
    [self reqSubItemDatas:@"" levelType:@"1" complete:^(NSArray *_Nonnull datas) {
        [weakSelf.addressView setData:datas index:0];
    }];

    _modalView             = [[SPModalView alloc] initWithView:self.addressView inBaseViewController:[UIApplication displayViewController]];
    _modalView.narrowedOff = YES;
    _modalView.delegate    = self;
    [_modalView show];
}

- (void)reqSubItemDatas:(NSString *)areaCode
              levelType:(NSString *)levelType
               complete:(void (^)(NSArray *_Nonnull datas))complete {
//    BaseRequest *requset       = [BaseRequest defaultRequest];
//    NSMutableDictionary *param = [NSMutableDictionary dictionary];
//    if (areaCode.length > 0) {
//        [param setObject:areaCode forKey:@"areaCode"];
//    }
//    if (levelType.length > 0) {
//        [param setObject:levelType forKey:@"levelType"];
//    }
//    requset.data = param;
//    [WM.http post:CORP_CREATE_AREA requestModel:requset complete:^(ResultObject *_Nonnull result) {
//        BlockSafeRun(complete, result.data);
//    }];
    
    
    [self.dataLoader sendRequestAddressList:^(NSInteger status, id  _Nullable result) {
        BlockSafeRun(complete, result[@"data"]);
    }];
    

}

- (void)dismissAddressView {
    [_modalView close];
    [self.addressView removeAllItem];
}

#pragma mark SPModalViewDelegate

- (void)closeControlForSPModalView {
    [self dismissAddressView];
}

#pragma mark AddressViewDelegate

- (void)sp_pickerViewForAddressView:(SPPickerView *)pickerView model:(SPArea *)model inComponent:(NSInteger)component {
    self.pickerView                      = pickerView;
    __weak EHAddressCompHelper *weakSelf = self;
    [self reqSubItemDatas:model.areaCode levelType:@"" complete:^(NSArray *_Nonnull datas) {
        [weakSelf.addressView setData:datas index:component + 1];
        [pickerView sp_scrollToComponent:component + 1 atComponentScrollPosition:SPPickerViewComponentScrollPositionDefault animated:YES];
    }];
}

- (void)sp_pickerViewForAddressViewTapClose:(SPPickerView *)pickerView {
    [self dismissAddressView];
}

#pragma 初始化

- (AddressView *)addressView {
    if (!_addressView) {
        _addressView          = [[AddressView alloc] init];
        _addressView.frame    = CGRectMake(0, 0, kScreenWidth, 400);
        _addressView.delegate = self;
        @weakify(self)
            _addressView.lastComponentClickedBlock = ^(SPArea *selectedProvince, SPArea *selectedCity, SPArea *selectedDistrict) {
            @strongify(self)
                [self dismissAddressView];
            if (self.delegate && [self.delegate respondsToSelector:@selector(areaViewEndChange:areaCode:)]) {
                [self.delegate areaViewEndChange:[NSString stringWithFormat:@"%@/%@/%@", selectedProvince.areaName, selectedCity.areaName, selectedDistrict.areaName] areaCode:[NSString stringWithFormat:@"%@/%@/%@", selectedProvince.areaCode, selectedCity.areaCode, selectedDistrict.areaCode]];
            }
        };
    }
    return _addressView;
}

@end
