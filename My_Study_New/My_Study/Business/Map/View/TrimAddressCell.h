//
//  TrimAddressCell.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/6.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "PASIndicatorTableViewCell.h"
#import "POIAnnotation.h"


NS_ASSUME_NONNULL_BEGIN

@interface TrimAddressCell : UITableViewCell //: PASIndicatorTableViewCell

@property (nonatomic, assign) BOOL isSelected; //是否被选中

- (void)updateTrimWithModel:(POIAnnotation *)model isLastRow:(NSInteger)isLastRow;

@end

NS_ASSUME_NONNULL_END
