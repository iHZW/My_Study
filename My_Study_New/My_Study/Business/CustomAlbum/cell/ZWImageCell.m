//
//  ZWImageCell.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWImageCell.h"
#import "PHAssetModel.h"
#import "UIColor+Ext.h"

@interface ZWImageCell ()

@property (nonatomic ,strong) UIImageView * imageVc;

@property (nonatomic ,strong) UIView * maskVc;

@property (nonatomic ,strong) UIView * actionView;

@property (nonatomic ,strong) UILabel * countLabel;

@end

@implementation ZWImageCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initViews];
    }
    return self;
}

- (void)initViews{
    _imageVc = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    _imageVc.contentMode = UIViewContentModeScaleAspectFill;
    _imageVc.clipsToBounds = YES;
    _imageVc.userInteractionEnabled = YES;
    [self.contentView addSubview:_imageVc];
    
    _maskVc = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    _maskVc.alpha = 0.5;
    _maskVc.hidden = YES;
    [self.contentView addSubview:_maskVc];
    
    _actionView = [[UIView alloc]initWithFrame:CGRectMake(self.frame.size.width / 2, 0, self.frame.size.width / 2, self.frame.size.width / 2)];
    [self.contentView addSubview:_actionView];
    
    _chooseIcon = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(_actionView.frame) - 4 - 22, 4, 22, 22)];
    _chooseIcon.contentMode = UIViewContentModeScaleAspectFill;
    _chooseIcon.clipsToBounds = YES;
    _chooseIcon.image = [UIImage imageNamed:@"Icon_camera_nav_unchoose"];
    _chooseIcon.userInteractionEnabled = YES;
    [_actionView addSubview:_chooseIcon];
    
    _countLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(_actionView.frame) - 4 - 22, 4, 22, 22)];
    _countLabel.layer.cornerRadius = 10;
    _countLabel.clipsToBounds = YES;
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.textColor = [UIColor colorFromHexCode:@"#FFFFFF"];
    _countLabel.backgroundColor = [UIColor colorFromHexCode:@"#4F7AFD"];
    _countLabel.font = PASFont(14);
    [_actionView addSubview:_countLabel];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]init];
    [tap addTarget:self action:@selector(changeImageChooseStatu)];
    [_actionView addGestureRecognizer:tap];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _imageVc.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    _maskVc.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    _actionView.frame = CGRectMake(self.frame.size.width / 2, 0, self.frame.size.width / 2, self.frame.size.width / 2);
    _chooseIcon.frame = CGRectMake(CGRectGetWidth(_actionView.frame) - 4 - 22, 4, 22, 22);
    _countLabel.frame = CGRectMake(CGRectGetWidth(_actionView.frame) - 4 - 22, 4, 22, 22);
}

- (void)update:(PHAssetModel *)model selIndex:(NSInteger)selindex hasSelectMax:(BOOL)hasSelectMax{
    self.model = model;
    if ([ZWAlbumManager manager].selectType == ZWAlbumSelectTypeSingle) {
        _actionView.hidden = YES;
    }else if ([ZWAlbumManager manager].selectType == ZWAlbumSelectTypeMore){
        if ([[ZWAlbumManager manager] checkIsVideo:model.asset]) {
            _actionView.hidden = YES;
        }else{
            _actionView.hidden = NO;
            if (model.selStatus == 0) {
                _chooseIcon.hidden = NO;
                _countLabel.hidden = YES;
                if (hasSelectMax) {
                    [self maskStatuUnSelect];
                }else{
                    [self maskStatuNormal];
                }
            }else{
                _chooseIcon.hidden = YES;
                _countLabel.hidden = NO;
//                if (hasSelectMax) {
//                    [self maskStatuSelect];
//                }else{
//                    [self maskStatuNormal];
//                }
                [self maskStatuSelect];
            }
        }
    }
    __weak ZWImageCell * weakSelf = self;
    [[ZWAlbumManager manager] thumbnail:model.asset complete:^(UIImage * _Nonnull result) {
        weakSelf.imageVc.image  = result;
    }];
    _countLabel.text = [NSString stringWithFormat:@"%@",@(selindex)];
}

- (void)maskStatuSelect{
    self.maskVc.hidden = NO;
    self.maskVc.backgroundColor = [UIColor colorFromHexCode:@"#000000"];
}

- (void)maskStatuUnSelect{
    self.maskVc.hidden = NO;
    self.maskVc.backgroundColor = [UIColor colorFromHexCode:@"#FFFFFF"];
}

- (void)maskStatuNormal{
    self.maskVc.hidden = YES;
}

#pragma mark delegate

- (void)changeImageChooseStatu{
    if (_delegate && [_delegate respondsToSelector:@selector(zwImageCellDidChangeStatus:data:)]) {
        [_delegate zwImageCellDidChangeStatus:self data:self.model];
    }
}

- (void)showAnimation:(void(^)(BOOL finished))complete{
    _countLabel.transform = CGAffineTransformMakeScale(0.6, 0.6);
    [UIView animateWithDuration:0.2f delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:5 options:UIViewAnimationOptionCurveLinear animations:^{
        self.countLabel.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (complete) {
            complete(finished);
        }
    }];
}


@end
