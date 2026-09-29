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

@property (nonatomic, strong) UILabel *desLabel;

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
    [self.bgView addSubview:self.desLabel];
    
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
        make.height.mas_equalTo(kLineViewHeight);
    }];
    
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.kChart.mas_bottom).offset(kKLineBetweenSpace);
        make.left.right.equalTo(self.kChart);
        make.bottom.equalTo(self.bgView);
    }];
    
    performBlockDelay(dispatch_get_main_queue(), 0.0, ^{
        [self.bgView mm_createByCAGradientLayer:UIColorFromRGB(0xcca4e3) midColor:UIColorFromRGB(0xFFFFFF) endColor:UIColorFromRGB(0xFFFFFF) layerFrame:self.bgView.bounds direction:0];
    });
    
}




- (void)configModel:(AskLineChartModel *)model {
    [self.kChart setKLineArray:model.kLineArray type:model.kType];
    [self.kChart updateChart];
    self.desLabel.text = model.desName;
    
    [self.kChart setNeedsDisplay];
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
        _kChart = [[KLineChart alloc] initWithFrame:CGRectMake(25, 25, [UIScreen mainScreen].bounds.size.width - 50, kLineViewHeight)];
        _kChart.backgroundColor = UIColor.whiteColor;
//        _kChart.isShowVolIndexView = NO;
    }
    return _kChart;
}


- (UILabel *)desLabel {
    if (!_desLabel) {
        _desLabel = [UILabel labelWithFrame:CGRectZero text:@"" textColor:UIColorFromRGB(0x333333) font:PASFont(15)];
        _desLabel.numberOfLines = 0;
    }
    return _desLabel;
}

@end
