//
//  PASShortVideoItemView.h
//  PASInfoLib
//
//  Created by 张勇勇(证券总部经纪业务事业部技术开发团队) on 2020/11/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PASShortVideoItemView : UIView

@property (nonatomic, copy)void(^block)(void);

- (void)setImageName:(NSString *)imageName selectImageName:(NSString *)selectImageName;

- (void)setTextNumber:(NSInteger)num;

@end

NS_ASSUME_NONNULL_END
