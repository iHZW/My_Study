//
//  PASShortVideoAgreeAnimationView.h
//  PASInfoLib
//
//  Created by 张勇勇(证券总部经纪业务事业部技术开发团队) on 2020/12/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PASShortVideoAgreeAnimationView : UIView

- (void)startAnimationWithCompletion:(void(^)(void))block;

@end

NS_ASSUME_NONNULL_END
