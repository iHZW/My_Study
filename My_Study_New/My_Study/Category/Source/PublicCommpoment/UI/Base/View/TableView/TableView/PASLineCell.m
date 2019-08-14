//
//  PASLineCell.m
//  TestC
//
//  Created by vince on 16/2/16.
//  Copyright © 2016年 vince. All rights reserved.
//

#import "PASLineCell.h"
#import "Masonry.h"


@implementation PASLineCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self loadLineView];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadLineView];
    }
    return self;
}

- (void)loadLineView
{
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.lineView];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@0);
        make.right.mas_equalTo(@0);
        make.bottom.mas_equalTo(@0);
        make.height.mas_equalTo(@0.5);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end


@implementation PASLeftCell

-(void)loadLineView
{
    self.leftBottomView = [[UIView alloc] init];
    self.leftBottomView.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:self.leftBottomView];
    
    float xpoint = 10;
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.font = [UIFont systemFontOfSize:18];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.contentMode = UIViewContentModeCenter;
    [self.leftBottomView addSubview:self.nameLabel];
    
    self.codeLabel = [[UILabel alloc] init];
    self.codeLabel.backgroundColor = [UIColor clearColor];
    self.codeLabel.font = [UIFont systemFontOfSize:12];
    self.codeLabel.textColor = [UIColor whiteColor];
    self.codeLabel.contentMode = UIViewContentModeCenter;
    [self.leftBottomView addSubview:self.codeLabel];
    
    //todo: test
    self.nameLabel.text = @"中海集运";
    self.codeLabel.text = @"912031";
    
    [self.leftBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@0);
        make.bottom.mas_equalTo(@0);
        make.left.mas_equalTo(@0);
        make.width.mas_equalTo(@100);
    }];
    
    __weak typeof(&*self) wself = self;
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@5);
        make.left.mas_equalTo([NSNumber numberWithFloat:xpoint]);
        make.right.mas_equalTo(@-5);
        make.height.equalTo(wself.leftBottomView).multipliedBy(0.55);
    }];
    
    [self.codeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(@-4);
        make.left.mas_equalTo([NSNumber numberWithFloat:xpoint]);
        make.right.mas_equalTo(@-5);
        make.height.equalTo(wself.leftBottomView).multipliedBy(0.3);
        
    }];
    
    [super loadLineView];
}

- (void)setLeftWidth:(CGFloat)leftWidth
{
    [self.leftBottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([NSNumber numberWithFloat:leftWidth]);
    }];
}

- (void)loadContentWithData:(NSDictionary *)dataDict
{
    if ([dataDict isKindOfClass:[NSDictionary class]]) {
        self.nameLabel.text = [dataDict objectForKey:@"title"];
        self.codeLabel.text = [dataDict objectForKey:@"code"];
    }

}
@end
