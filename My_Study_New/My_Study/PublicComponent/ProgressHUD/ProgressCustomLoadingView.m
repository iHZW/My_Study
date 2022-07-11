//
//  ProgressCustomLoadingView.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ProgressCustomLoadingView.h"

#define kLoadingSize 56
#define kLoadingImageSizeWidth 30
#define kLoadingImageSizeHeight 41

@interface ProgressCustomLoadingView()

@property (nonatomic, strong) UIImageView *gifView;

@end

@implementation ProgressCustomLoadingView

+ (ProgressCustomLoadingView *)progressCustomView{
    ProgressCustomLoadingView *customView = [[ProgressCustomLoadingView alloc] init];
    customView.backgroundColor = [UIColor clearColor];
    customView.alpha = 0.9;
    customView.layer.cornerRadius = kLoadingSize / 2.0;
    customView.layer.shadowOpacity = 1;
    customView.layer.shadowOffset = CGSizeMake(0, 1);
    customView.layer.shadowRadius = 19 / 2.0;
    customView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.09].CGColor;
    customView.clipsToBounds = NO;
    [customView initViews];
    return customView;
}

- (void)initViews{
    self.gifView = [[UIImageView alloc]initWithFrame:CGRectMake((kLoadingSize - kLoadingImageSizeWidth ) / 2, (kLoadingSize - kLoadingImageSizeHeight ) / 2, kLoadingImageSizeWidth, kLoadingImageSizeHeight)];

    NSMutableArray *upArr = @[].mutableCopy;
    for (NSInteger i = 0; i <= 30; i++) {
        [upArr addObject:[NSString stringWithFormat:@"kRefresh_%06ld",i]];
    }
    
    NSMutableArray *imageArr = @[].mutableCopy;
    [upArr enumerateObjectsUsingBlock:^(NSString * str, NSUInteger idx, BOOL * _Nonnull stop) {
        [imageArr addObject:[UIImage imageNamed:str]];
    }];
    
    NSString *firstImage = upArr.firstObject;
    self.gifView.image = [UIImage imageNamed:firstImage];
    //一秒=25帧
    //images * 1/30th of a second (i.e. 30 fps)
    self.gifView.animationDuration = 30.0 / 25.0;
    [self.gifView setAnimationImages:imageArr];
    
    [self addSubview:self.gifView];
    
    [self.gifView startAnimating];
}

- (CGSize)intrinsicContentSize{
    return CGSizeMake(kLoadingSize, kLoadingSize);
}

@end
