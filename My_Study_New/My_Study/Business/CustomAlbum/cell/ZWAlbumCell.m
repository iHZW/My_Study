//
//  ZWAlbumCell.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/12.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWAlbumCell.h"

@interface ZWAlbumCell ()

@property (nonatomic ,strong) UIImageView * logo;

@property (nonatomic ,strong) UILabel * albumTitle;

@property (nonatomic ,strong) UILabel * photoCount;

@property (nonatomic ,strong) UIImageView * arrowImage;

@end

@implementation ZWAlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self initViews];
    }
    return self;
}

- (void)initViews{
    self.logo = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.height, self.contentView.frame.size.height)];
    self.logo.contentMode = UIViewContentModeScaleAspectFill;
    self.logo.clipsToBounds = YES;
    [self.contentView addSubview:self.logo];
    
    self.albumTitle = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.logo.frame) + 10, 0, 200, self.contentView.frame.size.height)];
    self.albumTitle.font = PASFont(16);
    [self.contentView addSubview:self.albumTitle];
    
    self.arrowImage = [[UIImageView alloc]init];
    self.arrowImage.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.arrowImage];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.logo.frame = CGRectMake(16, (self.contentView.frame.size.height - 40) / 2, 40, 40);
    
    CGSize titleSize = [self.albumTitle sizeThatFits:CGSizeMake(MAXFLOAT, self.contentView.frame.size.height)];
    self.albumTitle.frame = CGRectMake(CGRectGetMaxX(self.logo.frame) + 8, (self.contentView.frame.size.height - 22.5) / 2, titleSize.width, 22.5);
    
    self.arrowImage.frame = CGRectMake(self.contentView.frame.size.width - 16 - 20, (self.contentView.frame.size.height - 20) / 2, 20, 20);
}

- (void)update:(PHAssetCollection *)collection{
    NSArray <PHAssetModel *> * photos = [[ZWAlbumManager manager] photoList:collection];
    NSString * titleText;
    if (photos.count > 0) {
        PHAsset * set = photos.lastObject.asset;
        @pas_weakify_self
        [[ZWAlbumManager manager] thumbnail:set complete:^(UIImage * _Nonnull result) {
            @pas_strongify_self
            self.logo.image = result;
        }];
        titleText = [NSString stringWithFormat:@"%@（%@）",collection.localizedTitle, @(photos.count)];
    }else{
        self.logo.image = [UIImage imageNamed:@""];
        titleText = [NSString stringWithFormat:@"%@（0）",collection.localizedTitle];
    }
    self.albumTitle.text = titleText;
}

- (void)selectStatus{
    self.arrowImage.image = [UIImage imageNamed:@"Icon_camera_select"];
}

- (void)unSelectStatus{
    self.arrowImage.image = [UIImage imageNamed:@""];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


@end
