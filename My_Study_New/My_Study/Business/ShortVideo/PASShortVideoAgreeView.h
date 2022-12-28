//
//  PASShortVideoAgreeView.h
//  Pods
//
//  Created by 张勇勇(证券总部经纪业务事业部技术开发团队) on 2020/12/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PASShortVideoAgreeView : UIView

@property (nonatomic, copy)void(^block)(BOOL isAgree);

@property (nonatomic, assign) BOOL selected;

- (void)setImageName:(NSString *)imageName selectImageName:(NSString *)selectImageName;

- (void)setTextNumber:(NSInteger)num;

@end

NS_ASSUME_NONNULL_END
