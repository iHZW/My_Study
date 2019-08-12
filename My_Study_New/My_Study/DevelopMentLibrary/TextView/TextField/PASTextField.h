//
//  PASTextField.h
//  PASecuritiesApp
//
//  Created by Weirdln on 16/5/8.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PASTextField : UITextField

@property (nonatomic) CGFloat leftOffset;
@property (nonatomic) CGFloat rightOffset;

@property (nonatomic, strong, readonly) UILabel *rightTipLabel;

@end
