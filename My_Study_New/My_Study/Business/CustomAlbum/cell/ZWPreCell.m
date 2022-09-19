//
//  ZWPreCell.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWPreCell.h"
#import "PHAssetModel.h"

@implementation ZWPreCell


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initViews];
    }
    return self;
}

- (void)initViews{
    _imageView = [[ZWImageView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    [self.contentView addSubview:_imageView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _imageView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
}

- (void)update:(PHAssetModel *)model{
    [_imageView update:model.asset];
}

- (void)updateItem:(UploadItem *)item{
    if (item.url) {
        [_imageView loadUrlAndPath:item.url];
    }else{
        [_imageView loadUrlAndPath:item.localPath];
    }
}

@end
