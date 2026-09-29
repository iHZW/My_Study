//
//  PASShortVideoAgreeAnimationView.m
//  PASInfoLib
//
//  Created by 张勇勇(证券总部经纪业务事业部技术开发团队) on 2020/12/2.
//

#import "PASShortVideoAgreeAnimationView.h"
#import "Masonry.h"

#define LineWidth 27.50f
#define LineHeight 13.0f
#define BackWidth 35.5f
#define BackHeight 35.5f
#define ImageWidth 20.5f
#define ImageHeight 19.5f

@interface PASShortVideoAgreeAnimationView ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIImageView *lineView;

@property (nonatomic, strong) UIImageView *backView;

@end

@implementation PASShortVideoAgreeAnimationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backView = [[UIImageView alloc] init];
        self.backView.image = [UIImage imageNamed:@"shortvideo_agree_back"];
        self.lineView = [[UIImageView alloc] init];
        self.lineView.image = [UIImage imageNamed:@"shortvideo_agree_line"];
        self.imageView = [[UIImageView alloc] init];
        self.imageView.image = [UIImage imageNamed:@"shortvideo_agree_normal_animation"]; //
        
        [self addSubview:self.backView];
        [self addSubview:self.lineView];
        [self addSubview:self.imageView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(8.0f);
            make.width.mas_equalTo(LineWidth);
            make.height.mas_equalTo(LineHeight);
        }];
        
        [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(LineHeight);
            make.width.mas_equalTo(BackWidth);
            make.height.mas_equalTo(BackHeight);
        }];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.backView);
            make.width.mas_equalTo(ImageWidth);
            make.height.mas_equalTo(ImageHeight);
        }];
        self.lineView.transform = CGAffineTransformMakeScale(0.0, 0.0);

    }
    return self;
}

- (void)startAnimationWithCompletion:(void(^)(void))block
{
    self.imageView.image = [UIImage imageNamed:@"shortvideo_agree_normal_animation"];
    [UIView animateWithDuration:0.1 animations:^{
        self.imageView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    } completion:^(BOOL finished) {
        self.imageView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.imageView.image = [UIImage imageNamed:@"shortvideo_agree_select_animation"];
        [UIView animateWithDuration:0.1 animations:^{
            self.lineView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            self.imageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            self.lineView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            self.imageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            [UIView animateWithDuration:0.1 animations:^{
                self.lineView.transform = CGAffineTransformMakeScale(1.3, 1.3);
                self.imageView.transform = CGAffineTransformMakeScale(1.5, 1.5);
            } completion:^(BOOL finished) {
                self.lineView.transform = CGAffineTransformMakeScale(0.0, 0.0);
                self.imageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                if (block) {
                    block();
                }
                self.hidden = YES;
            }];
            
        }];
    }];
}

@end
