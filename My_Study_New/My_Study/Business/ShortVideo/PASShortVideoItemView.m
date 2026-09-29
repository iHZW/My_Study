//
//  PASShortVideoItemView.m
//  PASInfoLib
//
//  Created by 张勇勇(证券总部经纪业务事业部技术开发团队) on 2020/11/24.
//

#import "PASShortVideoItemView.h"
#import "Masonry.h"
#import "UIColor+Extensions.h"
#import "ZWSDK.h"

#define ButtonSize 35.5f
//#define LabelHeight 30.f

@interface PASShortVideoItemView ()

@property (nonatomic, strong) UIButton *topImageButton;
@property (nonatomic, strong) UILabel *bottomLabel;

@end

@implementation PASShortVideoItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.topImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.topImageButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.bottomLabel = [UILabel new];
        self.bottomLabel.textColor = UIColorFromRGB(0xffffff);
        self.bottomLabel.font = PASFont(10.0f);
        self.bottomLabel.shadowColor = UIColorFromRGBA(0x000000, 0.5f);
        self.bottomLabel.shadowOffset = CGSizeMake(0, 1);
        self.bottomLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.topImageButton];
        [self addSubview:self.bottomLabel];
        [self.topImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(ButtonSize);
            make.top.centerX.equalTo(self);
        }];
        [self.bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.top.equalTo(self.topImageButton.mas_bottom);
        }];
    }
    return self;
}

- (void)buttonAction:(UIButton *)btn
{
    if (self.block) {
        self.block();
    }
}

- (void)setImageName:(NSString *)imageName selectImageName:(NSString *)selectImageName
{
    if (imageName.length > 0) {
        [self.topImageButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    if (selectImageName.length > 0) {
        [self.topImageButton setImage:[UIImage imageNamed:selectImageName] forState:UIControlStateSelected];
    }
}

- (void)setTextNumber:(NSInteger)num
{
    if (num > 10000) {
        double n = num/10000.0f;
        self.bottomLabel.text = [NSString stringWithFormat:@"%.1fw", n];
    } else {
        self.bottomLabel.text = [NSString stringWithFormat:@"%ld", num];
    }
}

@end
