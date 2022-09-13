//
//  CardTableViewCell.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/9/10.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CardTableViewCell : UITableViewCell

+ (CGFloat)cellHeight;

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIImageView *leftImg;
@property (nonatomic, strong) UILabel *infoLab;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *contentLab;
@property (nonatomic, strong) UILabel *timeLab;
@property (nonatomic, strong) UILabel *priceLab;

@end

NS_ASSUME_NONNULL_END
