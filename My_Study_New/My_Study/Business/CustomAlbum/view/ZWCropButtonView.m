//
//  ZWCropButtonView.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWCropButtonView.h"

@implementation ZWCropButtonView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initViews];
    }
    return self;
}

- (void)initViews{
    UIView * lineVc = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
    lineVc.backgroundColor = [UIColor whiteColor];
    lineVc.alpha  = 0.5;
    [self addSubview:lineVc];
    
    UIButton * leftButton = [[UIButton alloc]initWithFrame:CGRectMake(20, 12.5, 32, 20)];
    leftButton.titleLabel.font = PASFont(15);
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftButton];
    
    UIButton * rightButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 20 - 32, 12.5, 32, 20)];
    rightButton.titleLabel.font = PASFont(15);
    [rightButton setTitle:@"完成" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightButton];
}

- (void)cancelAction{
    BlockSafeRun(self.buttonHander,0);
}

- (void)confirmAction{
    BlockSafeRun(self.buttonHander,1);
}


@end
