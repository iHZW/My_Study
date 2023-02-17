//
//  MMPickerControl.h
//  MMBaseComponent
//
//  Created by Zhiwei Han on 2023/1/28.
//

#import <MMBaseComponent/MMBaseComponent.h>

NS_ASSUME_NONNULL_BEGIN

/** 取消回调  */
typedef void (^CancelAction)(void);
/** 确认回调  */
typedef void (^ConfirmAction)(NSDictionary *);

@interface MMPickerControl : EHBaseView

@property (nonatomic, copy) CancelAction cancelHander;

@property (nonatomic, copy) ConfirmAction confirmHander;

+ (void)showAnimation:(NSDictionary *)param
        confirmHander:(ConfirmAction)confirm
         cancelHander:(CancelAction)cancel;

@end

NS_ASSUME_NONNULL_END
