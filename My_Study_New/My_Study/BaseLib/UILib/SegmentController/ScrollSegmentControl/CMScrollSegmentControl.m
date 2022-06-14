//
//  CMScrollSegmentControl.m
//  PASecuritiesApp
//
//  Created by Howard on 16/2/3.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "CMScrollSegmentControl.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewCategory.h"
#import "PASUIDefine.h"


@implementation CMScrollSegmentViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.cellBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cellBtn.backgroundColor = [UIColor clearColor];
        [self.cellBtn setUserInteractionEnabled:NO];
        [self.cellBtn setFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.cellBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.cellBtn];
        self.sepView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, CGRectGetHeight(frame))];
        [self.sepView setBackgroundColor:[UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.0]];
        [self.sepView setCenter:CGPointMake(CGRectGetWidth(frame)-CGRectGetWidth(self.sepView.frame) * 0.5, CGRectGetHeight(frame) * .5)];
        [self.contentView addSubview:self.sepView];
        
        self.indicatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame) - 3, CGRectGetWidth(frame), 3)];
        self.indicatorImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.contentView addSubview:self.indicatorImageView];
        
        self.badgeLabel = [UILabel labelWithFrame:CGRectMake(CGRectGetWidth(frame) - 10, 5, 10, 10) text:@"" textColor:PAS_COLOR_WHITE];
        self.badgeLabel.hidden = YES;
        self.badgeLabel.font = [UIFont systemFontOfSize:10];
        self.badgeLabel.cornerRadius = 5;
        self.badgeLabel.clipsToBounds = YES;
        self.badgeLabel.backgroundColor = UIColorFromRGB(0xe2233e);
        [self.contentView addSubview:self.badgeLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [self.cellBtn setFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    [self.badgeLabel setFrame:CGRectMake(CGRectGetWidth(self.bounds) - 10, 5, 10, 10)];
    [self.sepView setFrame:CGRectMake(0, 0, 1, CGRectGetHeight(self.bounds))];
    [self.sepView setCenter:CGPointMake(CGRectGetWidth(self.bounds)-CGRectGetWidth(self.sepView.frame) * 0.5, CGRectGetHeight(self.bounds) * .5)];
}

@end


@interface CMScrollSegmentControl () <UICollectionViewDataSource, UICollectionViewDelegate>

/**
 *  支持滚动的区域容器
 */
@property (nonatomic, strong) UICollectionView *containerView;
@property (nonatomic, strong) CALayer *selectedSegmentLayer;
@property (nonatomic, strong) NSIndexPath *tmpIndexPath;
@property (nonatomic, strong) UIView *toplineView;
@property (nonatomic, strong) UIView *bottomlineView;
@property (nonatomic) CGFloat xOffset;
@property (nonatomic) CGFloat yOffset;
@property (nonatomic) NSInteger selectedIndex;

@end


@implementation CMScrollSegmentControl

#pragma mark - private's

- (CGFloat)totalContentWidth
{
    __block CGFloat total = .0;
    [self.listData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        total += self.itemWidthBlock(idx);
    }];
    
    return total;
}

- (CGFloat)totalContentSizeBeforeIndex:(NSInteger)index
{
    __block CGFloat total = .0;
    [self.listData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < index) {
            total += self.itemWidthBlock(idx);
        } else {
            *stop = YES;
        }
    }];
    
    return total;
}

- (CGRect)frameForSelectionIndicator
{
    CGFloat stringWidth                  = [[self.listData objectAtIndex:self.selectedIndex] sizeWithAttributes:@{NSFontAttributeName:self.selectFont}].width;
    CGFloat yPos                         = _alignType == IndicatorAlignmentTop ? 0.0 : CGRectGetHeight(self.bounds)- self.indicatorHeight;
    CGFloat itemWidth                    = _segmentItemWidth;
    CGFloat widthTillBeforeSelectedIndex = (_segmentItemWidth * self.selectedIndex);
    CGFloat widthTillEndOfSelectedIndex = (_segmentItemWidth * self.selectedIndex) + _segmentItemWidth;
    
    if (self.itemWidthBlock) {  // 不等宽Segment处理
        itemWidth                    = self.itemWidthBlock(self.selectedIndex);
        widthTillBeforeSelectedIndex = [self totalContentSizeBeforeIndex:self.selectedIndex];
        widthTillEndOfSelectedIndex  = widthTillBeforeSelectedIndex + itemWidth;
    }
    
    if (self.indicatorMode == CustomSegmentIndicatorResizesToStringWidth) {
        CGFloat curStringWidth = MIN(stringWidth, itemWidth);
        CGFloat x              = ((widthTillEndOfSelectedIndex - widthTillBeforeSelectedIndex) / 2) + (widthTillBeforeSelectedIndex - curStringWidth / 2);
        
        return CGRectMake(x, yPos, curStringWidth, self.indicatorHeight);
    } else if (self.indicatorMode == CustomSegmentIndicatorCustomWidth) {
        
        return CGRectMake(widthTillBeforeSelectedIndex + (itemWidth - _indicatorWidth) * .5, yPos, _indicatorWidth, self.indicatorHeight);
    } else {
        return CGRectMake(widthTillBeforeSelectedIndex, yPos, itemWidth, self.indicatorHeight);
    }
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

#pragma mark - public's
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.font               = [UIFont fontWithName:@"Avenir-Light" size:19.0f];
        self.selectFont         = [UIFont fontWithName:@"Avenir-Light" size:19.0f];
        self.borderColor        = [UIColor colorWithWhite:.9 alpha:.7];
        self.textColor          = [UIColor blackColor];
        self.selectTextColor    = [UIColor blueColor];
        self.indicatorColor     = [UIColor blueColor];
        self.seporatorColor     = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.0];
        self.indicatorHeight    = 5;
        self.indicatorMode      = CustomSegmentIndicatorResizesToStringWidth;
        self.segmentItemWidth   = frame.size.width / 4;
        self.selectedIndex      = 0;
        self.alignType          = IndicatorAlignmentBottom;
        self.showSeporator      = NO;
        self.indicatorWidth     = self.segmentItemWidth * .6;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        
        self.containerView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 1, frame.size.width, frame.size.height-2) collectionViewLayout:flowLayout];
        [self.containerView setScrollsToTop:NO];
        [self.containerView setShowsHorizontalScrollIndicator:NO];
        [self.containerView setShowsVerticalScrollIndicator:NO];
        self.containerView.delegate = self;
        self.containerView.dataSource = self;
        [self addSubview:self.containerView];
        
        self.containerView.backgroundColor = [UIColor clearColor];
        
        //注册cell和ReusableView（相当于头部）
        [self.containerView registerClass:[CMScrollSegmentViewCell class] forCellWithReuseIdentifier:@"cell"];
        [self.containerView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ReusableView"];
        
        self.selectedSegmentLayer = [CALayer layer];
        self.selectedSegmentLayer.backgroundColor = self.indicatorColor.CGColor;
        [self.containerView.layer addSublayer:self.selectedSegmentLayer];
        
        _toplineView = [[UIView alloc] initWithFrame:CGRectMake(0, 1, frame.size.width, 1)];
        [self addSubview:_toplineView];
        [_toplineView setBackgroundColor:_borderColor];
        _bottomlineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame) - 1, frame.size.width, 1)];
        [_bottomlineView setBackgroundColor:_borderColor];
        [self addSubview:_bottomlineView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [self.containerView setFrame:CGRectMake(0, 1, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)-2)];
    [self.toplineView setFrame:CGRectMake(0, 1, CGRectGetWidth(self.bounds), 1)];
    [self.bottomlineView setFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 1, CGRectGetWidth(self.bounds), 1)];
}

- (void)setIndicatorColor:(UIColor *)color
{
    _indicatorColor = color;
    self.selectedSegmentLayer.backgroundColor = color.CGColor;
}

- (void)setListData:(NSArray *)list
{
    _listData = list;
    self.selectedIndex = _selectedIndex < [list count] ? _selectedIndex : 0;
    
    [self.containerView reloadData];
}

- (void)setBadgeDataArray:(NSArray *)badgeArray
{
    _badgeDataArray = badgeArray;
    [self.containerView reloadData];
}

- (void)setBorderColor:(UIColor *)color
{
    _borderColor = color;
    [_bottomlineView setBackgroundColor:_borderColor];
    [_toplineView setBackgroundColor:_borderColor];
}

/**
 *  重新指定选择的Segment Item
 *
 *  @param index 选择索引
 */
- (void)changeSelectIndex:(NSUInteger)index
{
    if (index < [self.listData count]) {
        self.selectedIndex = index;
        [self.containerView reloadData];
        
        if (self.itemWidthBlock) {
            CGFloat itemWidth    = self.itemWidthBlock(index);
            CGFloat contentWidth = [self totalContentWidth];
            CGFloat offset       = [self totalContentSizeBeforeIndex:index];
            
            if (contentWidth > CGRectGetWidth(self.bounds)) {
                if (self.containerView.contentOffset.x < offset) {
                    CGFloat offsetX = MAX(MIN(offset + itemWidth * 0.5 - CGRectGetWidth(self.bounds) * 0.5, contentWidth - CGRectGetWidth(self.bounds)), 0);
                    [self.containerView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
                } else {
                    CGFloat offsetX = MIN(MAX(offset - itemWidth * 0.5 - CGRectGetWidth(self.bounds) * 0.5, 0), contentWidth - CGRectGetWidth(self.bounds));
                    [self.containerView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
                }
            }
        } else {
            CGFloat offset       = index * _segmentItemWidth;
            CGFloat contentWidth = [self.listData count] * _segmentItemWidth;
            
            if (contentWidth > CGRectGetWidth(self.bounds)) {
                if (self.containerView.contentOffset.x < offset) {
                    CGFloat offsetX = MAX(MIN(offset + _segmentItemWidth * 0.5 - CGRectGetWidth(self.bounds) * 0.5, contentWidth - CGRectGetWidth(self.bounds)), 0);
                    [self.containerView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
                } else {
                    CGFloat offsetX = MIN(MAX(offset - _segmentItemWidth * 0.5 - CGRectGetWidth(self.bounds) * 0.5, 0), contentWidth - CGRectGetWidth(self.bounds));
                    [self.containerView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
                }
            }
        }
        
        if (self.actionBlock) {
            self.actionBlock(index, self.listData[index]);
        }
    }
}

#pragma mark - UICollectionViewDataSource
//定义展示的Section的个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//定义展示的UICollectionViewCell的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.listData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    CMScrollSegmentViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    [cell sizeToFit];
    
    if (indexPath.row < [self.listData count]) {
        NSString *title = self.listData[indexPath.row];
        UIColor *txtColor = _textColor;
        
        if (_selectedIndex == indexPath.row) {
            txtColor = _selectTextColor;
            self.selectedSegmentLayer.frame = [self frameForSelectionIndicator];
            [cell.cellBtn.titleLabel setFont:self.selectFont];
            if (self.selectIndicatorImage)
            {
                cell.indicatorImageView.image = self.selectIndicatorImage;
//                self.selectedSegmentLayer.backgroundColor = [UIColor clearColor].CGColor;
            }
        }
        else
        {
            [cell.cellBtn.titleLabel setFont:self.font];
            if (self.indicatorImage)
            {
                cell.indicatorImageView.image = self.indicatorImage;
//                self.selectedSegmentLayer.backgroundColor = [UIColor clearColor].CGColor;
            }
        }
        
        CGFloat itemWidth = self.itemWidthBlock ? self.itemWidthBlock(indexPath.row) : _segmentItemWidth;
        [cell.cellBtn setFrame:CGRectMake(0, 0, itemWidth, CGRectGetHeight(cell.frame))];
        [cell.cellBtn setTitle:title forState:UIControlStateNormal];
        [cell.cellBtn setTitleColor:txtColor forState:UIControlStateNormal];
        [cell.cellBtn setTitleColor:[UIColor colorWithWhite:.6 alpha:1.0] forState:UIControlStateHighlighted];
        
        BOOL isHidden = self.showSeporator && indexPath.row < [self.listData count] -1 ? NO : YES;
        [cell.sepView setHidden:isHidden];
        cell.sepView.backgroundColor = self.seporatorColor;
        
        if(self.badgeDataArray.count > 0 && self.badgeDataArray.count > indexPath.row){
        
            CGFloat badgeWidth = self.badgeWidth ? self.badgeWidth : 10;
            [cell.badgeLabel setFrame:CGRectMake(CGRectGetWidth(cell.bounds) - badgeWidth, 2, badgeWidth + 10, badgeWidth)];
            [cell.badgeLabel setFont:[UIFont systemFontOfSize:badgeWidth]];
        
            cell.badgeLabel.cornerRadius = badgeWidth / 2.;
            cell.badgeLabel.clipsToBounds = YES;
            cell.badgeLabel.backgroundColor = self.badgeBackColor ? self.badgeBackColor : UIColorFromRGB(0xe2233e);
            cell.badgeLabel.textColor = self.badgeTextColor ? self.badgeTextColor : PAS_COLOR_WHITE;
            cell.badgeLabel.text = self.badgeDataArray[indexPath.row];
            cell.badgeLabel.hidden = [cell.badgeLabel.text isEqualToString:@""] ? YES : NO;
        }
    }
    
    if (self.loadCellBlock)
    {
        self.loadCellBlock(indexPath.row, cell);
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height    = collectionView.frame.size.height;
    CGFloat itemWidth = self.itemWidthBlock ? self.itemWidthBlock(indexPath.row) : _segmentItemWidth;
    return CGSizeMake(itemWidth, height);
}

//定义每个UICollectionView 的 margin
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(_yOffset, 0, _yOffset, 0);
}

#pragma mark -UICollectionViewDelegate
// UICollectionView被选中时调用的方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.listData.count)
        [self changeSelectIndex:indexPath.row];
    //    CustomSegmentViewCell * oldCell = (CustomSegmentViewCell *)[collectionView cellForItemAtIndexPath:self.tmpIndexPath];
    //    if (oldCell)
    //    {
    //        [oldCell.cellBtn setTitleColor:_textColor forState:UIControlStateNormal];
    //    }
    //
    //    CustomSegmentViewCell * cell = (CustomSegmentViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //    [cell.cellBtn setTitleColor:_selectTextColor forState:UIControlStateNormal];
    //
    //    self.tmpIndexPath = indexPath;
    //    self.selectedIndex = indexPath.row;
    //    cell.backgroundColor = [UIColor whiteColor];
}

// 返回这个UICollectionView是否可以被选择
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

@end
