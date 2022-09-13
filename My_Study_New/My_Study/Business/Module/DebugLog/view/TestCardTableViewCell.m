//
//  TestCardTableViewCell.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/9/10.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "TestCardTableViewCell.h"

@implementation TestCardTableViewCell

+ (CGFloat)cellHeight
{
    return 80;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self loadSubViews];
    }
    return self;
}

- (void)loadSubViews
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 10, kMainScreenWidth - 10*2, [TestCardTableViewCell cellHeight]-20)];
    view.layer.cornerRadius = 10.0;
    view.backgroundColor = UIColor.whiteColor;
    // 给bgView边框设置阴影
    view.layer.shadowOpacity = 0.1;
    view.layer.shadowColor = UIColor.blackColor.CGColor;
    view.layer.shadowRadius = 5;
    view.layer.shadowOffset = CGSizeMake(1,1);
    self.bgView = view;
    
    [self addSubview:self.bgView];
    [view addSubview:self.titleLabel];
    [view addSubview:self.subTitleLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_offset(10);
        make.top.mas_offset(10);
        make.width.mas_offset(150);
        make.height.mas_offset(30);
        
//        make.left.mas_equalTo(self.bgView.mas_left).mas_offset(10);
//        make.top.mas_equalTo(self.bgView.mas_top).mas_equalTo(10);
//        make.bottom.mas_equalTo(self.bgView.mas_bottom).mas_equalTo(-10);
//        make.width.mas_equalTo(150);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right).mas_offset(30);
        make.top.mas_equalTo(self.bgView).mas_equalTo(10);
        make.bottom.mas_equalTo(self.bgView).mas_equalTo(-10);
        make.width.mas_equalTo(50);
    }];
    
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = PASFont(13);
        _titleLabel.text = @"更新于2019-01-11";
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel
{
    if (!_subTitleLabel) {
        _subTitleLabel = [UILabel labelWithFrame:CGRectZero text:@"" textColor:UIColor.redColor];
        _subTitleLabel.font = PASFont(13);
        _subTitleLabel.text = @"更新于2019-01-11";
    }
    return _subTitleLabel;
}

//- (UIView *)bgView
//{
//    if (!_bgView) {
//        _bgView = [UIView new];
//    }
//    return _bgView;
//}

@end
