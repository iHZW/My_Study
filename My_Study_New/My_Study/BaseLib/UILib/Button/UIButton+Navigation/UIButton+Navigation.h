//
//  UIButton+Navigation.h
//  TZYJ_IPhone
//
//  Created by Howard on 15/7/27.
//
//

#import <Foundation/Foundation.h>

@interface UIButton (Navigation)
+ (UIButton *)customNormalButton:(UIButtonType)btnType frame:(CGRect)frame offsetSize:(CGSize)offsetSize title:(NSString *)title image:(UIImage *)image align:(NSTextAlignment)align;

+ (UIButton *)customLeftButton:(UIButtonType)btnType frame:(CGRect)frame title:(NSString *)title image:(UIImage *)image;

+ (UIButton *)customRightButton:(UIButtonType)btnType frame:(CGRect)frame title:(NSString *)title image:(UIImage *)image;

- (void)refreshRightIconLeftTextButton:(UIEdgeInsets)edgeInset midOffset:(CGFloat)midOffset align:(NSTextAlignment)align;

@end
