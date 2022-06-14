//
//  PASListRightCell.m
//  TestC
//
//  Created by vince on 16/2/17.
//  Copyright © 2016年 vince. All rights reserved.
//

#import "PASListRightCell.h"
#import "PASListRightItem.h"

#define KRightContentTag 400

@implementation PASListRightCell

- (void)loadLineView
{
    //重写了
}

- (void)removeAllSubviewsInView:(UIView *)view
{
    for (UIView *subView in view.subviews) {
        [subView removeFromSuperview];
    }
}

- (void)createLabelInview:(UIView *)inView frame:(CGRect)frame text:(NSString *)text textColor:(UIColor *)textColor tag:(NSInteger)tag
{
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:frame];
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.contentMode = UIViewContentModeCenter;
    contentLabel.textAlignment = NSTextAlignmentRight;
    contentLabel.textColor = textColor;
    contentLabel.text = text;
    contentLabel.tag = tag;
    [inView addSubview:contentLabel];

}

- (void)resetContent:(NSString *)content textColor:(UIColor *)textColor tag:(NSInteger)tag
{
    UILabel *contentLab = [self.contentView viewWithTag:tag];
    if (!contentLab) {
        
        CGFloat tempWidth = self.itemWidth;
        
        if ([self.itemWidthArray count]>tag) {
            tempWidth = [self.itemWidthArray[tag] floatValue];
        }
        
        CGRect tempFrame = CGRectMake(self.leftWidth +(tag-KRightContentTag)*self.itemWidth, 0,tempWidth, self.itemHight);
        [self createLabelInview:self.contentView frame:tempFrame text:content textColor:textColor tag:tag];
    }
    else
    {
        contentLab.text = content;
        contentLab.textColor = textColor;
    }
}
- (void)loadViewWithData:(NSArray *)dataArr
{
    NSInteger count = 0;
    for (PASListRightItem *item in dataArr) {
        [self resetContent:item.contentStr textColor:item.contentColor tag:count+KRightContentTag];
        count++;
    }
    
}
@end
