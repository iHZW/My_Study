//
//  MMPickerView.h
//  MMBaseComponent
//
//  Created by Zhiwei Han on 2023/1/28.
//

#import <MMBaseComponent/MMBaseComponent.h>

NS_ASSUME_NONNULL_BEGIN

@class MMPickerView;

typedef NS_ENUM(NSUInteger, MMPickerFormatterStyle) {
    MMPickerFormatterStyleDefault = 0, // 年月日  2010-09-02
    MMPickerFormatterStyleLongTime,    // 年月日时分  2010-09-02 11:02
    MMPickerFormatterStyleTime,        // 时分 11:02
    MMPickerFormatterStyleMonth,       // 年月 2010-09
    MMPickerFormatterStyleCustom       // 月日时分 2010年09月 10:11  (特殊---只能往后选)
};

@protocol MMPickerViewDelegate <NSObject>

@optional

- (void)mmpickerDidChange:(MMPickerView *)mmpicker;

- (void)cancelForPic;

- (void)sureForPic:(NSDictionary *)value;

@end

@interface MMPickerView : EHBaseView

@property (nonatomic, assign) MMPickerFormatterStyle type;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *defaultData; // 默认选中 格式按照type上的注释格式  默认是当前时间
@property (nonatomic, weak) id<MMPickerViewDelegate> delegate;

@property (nonatomic, assign) BOOL hasConfirmButton;

// 初始化配置完需要调用一下
- (void)configComplete;

@end
NS_ASSUME_NONNULL_END
