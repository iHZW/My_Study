//
//  AskKlineTableViewCell.m
//  My_Study
//
//  Created by Zhiwei Han on 2023/9/7.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "AskKlineTableViewCell.h"
#import "KLineViewController.h"
#import "GCDCommon.h"
#import "UIView+Tool.h"

@interface AskKlineTableViewCell ()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) KLineChart *kChart;

@end

@implementation AskKlineTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self _setUI];
    }
    return self;
}

- (void)_setUI {
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.kChart];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(10);
        make.left.offset(10);
        make.right.offset(-10);
        make.bottom.offset(-10);
    }];
    
    [self.kChart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView.mas_left).offset(15);
        make.top.equalTo(self.bgView.mas_top).offset(15);
        make.right.equalTo(self.bgView.mas_right).offset(-15);
        make.bottom.equalTo(self.bgView.bottom).offset(-40);
    }];
    
    performBlockDelay(dispatch_get_main_queue(), 0.0, ^{
        [self.bgView mm_createByCAGradientLayer:UIColorFromRGB(0xFF2D51) endColor:UIColorFromRGB(0xFFFFFF) layerFrame:self.bgView.bounds direction:0];
    });
    
}




- (void)configModel:(AskLineChartModel *)model {
    [self.kChart setKLineArray:model.kLineArray type:model.kType];
    [self.kChart updateChart];
}


#pragma mark -  Lazy loading
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [UIView viewWithFrame:CGRectZero];
        [_bgView setCornerRadius:8.0];
    }
    return _bgView;
}

- (KLineChart *)kChart {
    if (!_kChart) {
        _kChart = [[KLineChart alloc] initWithFrame:CGRectZero];
        
    }
    return _kChart;
}


@end
