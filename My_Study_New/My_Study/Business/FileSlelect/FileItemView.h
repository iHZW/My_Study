//
//  FileItemView.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWBaseView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CloseActionBlock) (void);

@interface FileItemView : ZWBaseView

@property (nonatomic, copy) NSString *iconName;

@property (nonatomic, copy) NSString *titleName;

@property (nonatomic, copy) NSString *size;

@property (nonatomic, copy) NSString *closeIconName;

@property (nonatomic, copy) CloseActionBlock closeActionBlock;

@end

NS_ASSUME_NONNULL_END
