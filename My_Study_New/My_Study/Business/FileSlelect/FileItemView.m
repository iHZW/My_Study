//
//  FileItemView.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "FileItemView.h"
#import "UIImageView+WebCache.h"

#define kCloseBtnWidth          60

@interface FileItemView ()

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *sizeLabe;

@property (nonatomic, strong) UIButton *closeBtn;

@end

@implementation FileItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self loadSubViews];
    }
    return self;
}


- (void)loadSubViews
{
    [self addSubview:self.iconImageView];
    
    UIView *centerView = [UIView viewWithFrame:CGRectZero];
    [self addSubview:centerView];
    [centerView addSubview:self.titleLabel];
    [centerView addSubview:self.sizeLabe];
    
    [self addSubview:self.closeBtn];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(kContentSideHorizSpace);
        make.top.equalTo(self.mas_top).offset(10);
        make.bottom.equalTo(self.mas_bottom).offset(-10);
        make.width.equalTo(self.iconImageView.mas_height);
    }];
    
    [centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.iconImageView.mas_right).offset(10);
        make.right.equalTo(self.mas_right).offset(-(kCloseBtnWidth + 5));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(centerView);
    }];
    
    [self.sizeLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(centerView);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
    }];
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self);
        make.left.equalTo(centerView.mas_right).offset(5);
    }];
    
}


- (void)setIconName:(NSString *)iconName
{
    _iconName = iconName;
//    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:TransToString(iconName)] placeholderImage:[UIImage imageNamed:@"file_text_icon"]];
    self.iconImageView.image = [UIImage imageNamed:iconName];
}

- (void)setTitleName:(NSString *)titleName
{
    _titleName = titleName;
    self.titleLabel.text = titleName;
}

- (void)setSize:(NSString *)size
{
    _size = size;
    self.sizeLabe.text = TransToString(size);
}

- (void)setCloseIconName:(NSString *)closeIconName
{
    _closeIconName = closeIconName;
    [self.closeBtn setImage:[UIImage imageNamed:TransToString(closeIconName)] forState:UIControlStateNormal];
}

- (void)dealWithCloseBtnAction
{
    BlockSafeRun(self.closeActionBlock);
}



#pragma mark - lazyLoad
- (UIImageView *)iconImageView
{
    if (!_iconImageView) {
        _iconImageView = [UIImageView imageViewForImage:[UIImage imageNamed:@""] withFrame:CGRectZero];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _iconImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithFrame:CGRectZero text:@"" textColor:UIColorFromRGB(0x111111) font:PASFont(14) textAlignment:NSTextAlignmentLeft];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _titleLabel;
}

- (UILabel *)sizeLabe
{
    if (!_sizeLabe) {
        _sizeLabe = [UILabel labelWithFrame:CGRectZero text:@"" textColor:UIColorFromRGB(0x111111) font:PASFont(12) textAlignment:NSTextAlignmentLeft];
    }
    return _sizeLabe;
}

- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        @pas_weakify_self
        _closeBtn = [UIButton buttonWithFrame:CGRectZero title:@"" font:PASFont(12) titleColor:UIColorFromRGB(0x111111) block:^{
            @pas_strongify_self
            [self dealWithCloseBtnAction];
        }];
        [_closeBtn setImage:[UIImage imageNamed:@"Icon_close"] forState:UIControlStateNormal];
    }
    return _closeBtn;
}


@end
