//
//  FileItemCell.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "FileItemCell.h"
#import "FileItemView.h"
#import "NSString+NumberFormat.h"
#import "FileIconNameUtil.h"

@interface FileItemCell ()

@property (nonatomic, strong) FileItemView *itemView;

@end

@implementation FileItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self loadSubViews];
    }
    return self;
}

- (void)loadSubViews
{
    [self.contentView addSubview:self.itemView];
    
    [self.itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(5, 10, 5, 10));
    }];
    
    
}

- (void)setIndex:(NSInteger)index
{
    _index = index;
}


- (void)configItemModel:(PHAssetModel *)itemModel
{
    self.itemView.iconName = [FileIconNameUtil transFileIconUrl:itemModel.fileName];
    self.itemView.titleName = itemModel.fileName;
    self.itemView.size = [NSString formatSize:itemModel.fileSize];
}


#pragma mark - lazyLoad
- (FileItemView *)itemView
{
    if (!_itemView) {
        _itemView = [[FileItemView alloc] initWithFrame:CGRectZero];
        _itemView.cornerRadius = 8;
        _itemView.zh_backgroundColorPicker = ThemePickerColorKey(ZWColorKey_p8);
        @pas_weakify_self
        _itemView.closeActionBlock = ^{
            @pas_strongify_self
            BlockSafeRun(self.closeActoinBlock, self.index);
        };
    }
    return _itemView;
}

@end
