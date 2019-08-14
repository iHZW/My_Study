//
//  PASLineCell.h
//  TestC
//
//  Created by vince on 16/2/16.
//  Copyright © 2016年 vince. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PASLineCell : UITableViewCell

@property (nonatomic, strong) UIView *lineView;

- (void)loadLineView;

@end

@interface PASLeftCell : PASLineCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *codeLabel;
@property (nonatomic, strong) UIView *leftBottomView;

- (void)setLeftWidth:(CGFloat)leftWidth;

- (void)loadContentWithData:(NSDictionary *)dataDict;
@end