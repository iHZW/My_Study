//
//  PASListRightCell.h
//  TestC
//
//  Created by vince on 16/2/17.
//  Copyright © 2016年 vince. All rights reserved.
//

#import "PASLineCell.h"

@interface PASListRightCell : PASLineCell

@property (nonatomic, assign) CGFloat leftWidth;
@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) CGFloat itemHight;
@property (nonatomic, copy) NSArray *itemWidthArray;

- (void)loadViewWithData:(NSArray *)dataArr;

@end
