//
//  AddressView.h
//  SPPickerView
//
//  Created by Libo on 2018/8/31.
//  Copyright © 2018年 Cookie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPArea.h"
#import "SPPageMenu.h"
#import "SPPickerView.h"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@protocol AddressViewDelegate <NSObject>

/**
 * 点击具体的row
 * pickerView
 * model 选中的model
 * component 第几列
 **/
- (void)sp_pickerViewForAddressView:(SPPickerView *)pickerView model:(SPArea *)model inComponent:(NSInteger)component;

- (void)sp_pickerViewForAddressViewTapClose:(SPPickerView *)pickerView;

@end

@interface AddressView : UIView

@property (nonatomic, strong) NSArray *datas;

@property (nonatomic, weak) id<AddressViewDelegate> delegate;

@property (nonatomic, copy) void(^lastComponentClickedBlock)(SPArea *selectedProvince,SPArea *selectedCity,SPArea *selectedDistrict);

/**
 * list 数据源
 * index 第几列（0，1，2）
 */
- (void)setData:(NSArray *)list index:(NSInteger)index;

- (void)removeAllItem;

@end
