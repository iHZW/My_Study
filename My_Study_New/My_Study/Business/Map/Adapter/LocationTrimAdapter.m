//
//  LocationTrimAdapter.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/6.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "LocationTrimAdapter.h"
#import "TrimAddressHeadView.h"
#import "TrimAddressCell.h"
#import "UIColor+Ext.h"

#pragma mark - CustomCell
@interface CustomCell : UITableViewCell

@property (nonatomic ,assign) BOOL isSelected;

@property (nonatomic ,strong) UILabel * label;

@property (nonatomic ,strong) UIView * lineVc;

@property (nonatomic, strong) UIImageView * selectIcon;

@end

@implementation CustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initViews];
    }
    return self;
}

- (void)initViews
{
    _label = [[UILabel alloc]init];
    _label.font = PASFont(15);
    _label.text = @"不显示位置";
    _label.textColor = [UIColor colorFromHexCode:@"#4F7AFD"];
    [self.contentView addSubview:_label];
    
    _lineVc = [[UIView alloc] init];
    _lineVc.backgroundColor = [UIColor colorFromHexCode:@"#F2F2F6"];
    [self.contentView addSubview:_lineVc];
    
    _selectIcon = [[UIImageView alloc]init];
    _selectIcon.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_selectIcon];
    
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(16);
        make.right.equalTo(self.contentView.mas_right).offset(-40);
        make.top.equalTo(self.contentView.mas_top).offset(16);
    }];
    
    [self.selectIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-22);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.equalTo(@ 18);
        make.height.equalTo(@ 18);
    }];
    
    [self.lineVc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(16);
        make.right.equalTo(self.contentView.mas_right).offset(-16);
        make.top.equalTo(self.label.mas_bottom).offset(16);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.equalTo(@ 0.5);
    }];
}


- (void)update:(POIAnnotation *)model{
    NSString *rightImageName = self.isSelected ? @"icon_radio_checked": @"";
    _selectIcon.image = [UIImage imageNamed:rightImageName];
}

@end


#pragma mark - LocationTrimAdapter
@interface LocationTrimAdapter ()

@property (nonatomic, strong) TrimAddressHeadView *headView;

@property (nonatomic, assign) NSInteger selectedIndex; //单选选中的行

@end


@implementation LocationTrimAdapter

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.poisList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    POIAnnotation *model = [self.poisList objectAtIndex:indexPath.row];
    if (model.tag == 13579) {
        CustomCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell"];
        if (!cell) {
            cell = [[CustomCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.isSelected = NO;// 点击既确认，不需要选中状态了
        [cell update:model];
        return cell;
    }
    static NSString *trimAddressCellIdentifier = @"TrimAddressCell";
    TrimAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:trimAddressCellIdentifier];
    if (!cell) {
        cell = [[TrimAddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:trimAddressCellIdentifier];
    }

    cell.isSelected = NO;// 点击既确认，不需要选中状态了
    BOOL isLastRow = indexPath.row == self.poisList.count - 1;
    [cell updateTrimWithModel:model isLastRow:isLastRow];
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!_headView) {
        _headView = [[TrimAddressHeadView alloc] initWithFrame:
                     CGRectMake(0, 0, kMainScreenWidth, kMainScreenWidth*283/375)];
    }
    [_headView updateTrimWithPois:self.poisList];
    return _headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kMainScreenWidth*283/375;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    POIAnnotation *model = [self.poisList objectAtIndex:indexPath.row];
    self.selectedModel = model;
    
    if ([self.delegate respondsToSelector:@selector(locationTableViewDidSelect)]) {
        [self.delegate locationTableViewDidSelect];
    }
}


@end
