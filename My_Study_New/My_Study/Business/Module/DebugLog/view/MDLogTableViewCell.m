//
//  MDLogTableViewCell.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/15.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "MDLogTableViewCell.h"
#import "NSString+Adaptor.h"

#define kTitleBetweenSpace       5


@interface MDLogTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic, strong) UIButton *iconBtn;
/* 包裹视图居中处理 */
@property (nonatomic, strong) UIView *containerView;

@end

@implementation MDLogTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self loadSubViews];
//        self.subTitleName = @"";
    }
    return self;
}

- (void)loadSubViews
{
//    [self.contentView addSubview:self.containerView];
//    [self.contentView addSubview:self.iconBtn];
//    [self.containerView addSubview:self.titleLabel];
//    [self.containerView addSubview:self.subTitleLabel];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 5, kMainScreenWidth - 10*2 , 50)];
    view.layer.cornerRadius = 10.0;
    view.backgroundColor = UIColor.whiteColor;
    // 给bgView边框设置阴影
    view.layer.shadowOpacity = 0.1;
    view.layer.shadowColor = UIColor.blackColor.CGColor;
    view.layer.shadowRadius = 5;
    view.layer.shadowOffset = CGSizeMake(1,1);
    self.containerView = view;
    
    [self addSubview:view];
    [view addSubview:self.titleLabel];
    [view addSubview:self.subTitleLabel];
    
    [view addSubview:self.iconBtn];


}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(10);
        make.right.mas_offset(-10);
        make.bottom.mas_offset(-5);
        make.top.mas_offset(5);
//        make.left.centerY.mas_equalTo(self.contentView);
//        make.right.mas_equalTo(self.contentView.mas_right).mas_offset(-kCommonLeftSpace-40);
//        make.height.mas_equalTo(CGRectGetHeight(self.frame)-20);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView);
        make.left.mas_equalTo(self.containerView.mas_left).mas_offset(kCommonLeftSpace);
//        make.height.mas_equalTo(25);
        make.right.mas_equalTo(self.containerView).mas_offset(-kCommonLeftSpace-40);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(kTitleBetweenSpace);
        make.bottom.mas_equalTo(self.containerView.mas_bottom);
    }];
    
    [self.iconBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.containerView);
        make.right.mas_equalTo(self.containerView.mas_right).mas_offset(-kCommonLeftSpace);
        make.width.mas_equalTo(40);
    }];
}

- (void)setTitleName:(NSString *)titleName
{
    _titleName = titleName;
    self.titleLabel.text = TransToString(titleName);
    
    CGFloat width = CGRectGetWidth(self.frame) - kCommonLeftSpace;
    NSString *testStr = @"你好\n我是";
    CGFloat twoLineHeight = [NSString getHeightWithText:testStr font:self.titleLabel.font width:width];
    CGFloat titleLabelHeight = [NSString getHeightWithText:titleName font:self.titleLabel.font width:width];
    self.titleLabel.numberOfLines = titleLabelHeight > twoLineHeight ? 2 : 1;
}

- (void)setSubTitleName:(NSString *)subTitleName
{
    _subTitleName = subTitleName;
    self.subTitleLabel.text = TransToString(subTitleName);
    
    if (ValidString(subTitleName)) {
        [self.subTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(kTitleBetweenSpace);
        }];
    } else {
        [self.subTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom);
        }];
    }
}


- (void)setIconName:(NSString *)iconName
{
    _iconName = iconName;
    [self.iconBtn setImage:[UIImage imageNamed:TransToString(iconName)] forState:UIControlStateNormal];
}


#pragma mark - lazyLoad
- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithFrame:CGRectZero text:@"" textColor:UIColorFromRGB(0x111111) font:PASFont(16) textAlignment:NSTextAlignmentLeft];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel
{
    if (!_subTitleLabel) {
        _subTitleLabel = [UILabel labelWithFrame:CGRectZero text:@"" textColor:UIColorFromRGB(0x666666) font:PASFont(12) textAlignment:NSTextAlignmentLeft];
    }
    return _subTitleLabel;
}

- (UIButton *)iconBtn
{
    if (!_iconBtn) {
        _iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_iconBtn setImage:[UIImage imageNamed:@"icon_arrow_right"] forState:UIControlStateNormal];
    }
    return _iconBtn;
}

//- (UIView *)containerView
//{
//    if (!_containerView) {
//
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 5, kMainScreenWidth - 10*2, 60-10)];
//        view.layer.cornerRadius = 10;
//        view.backgroundColor = UIColor.greenColor;
//        // 给bgView边框设置阴影
//        view.layer.shadowOpacity = 0.1;
//        view.layer.shadowColor = UIColor.blackColor.CGColor;
//        view.layer.shadowRadius = 5;
//        view.layer.shadowOffset = CGSizeMake(1,1);
//
//        _containerView = view;
//    }
//    return _containerView;
//}

@end
