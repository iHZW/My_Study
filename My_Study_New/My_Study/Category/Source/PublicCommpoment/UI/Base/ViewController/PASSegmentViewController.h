//
//  PASSegmentViewController.h
//  PASecuritiesApp
//
//  Created by Weirdln on 16/7/18.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "PASBaseViewController.h"
#import "CMSegmentViewController.h"

@interface PASSegmentViewController : PASBaseViewController

@property (nonatomic, strong) CMSegmentViewController *segmentCtrl;

/**
 *  提前设置SegmentControl的类型
 */
@property (nonatomic) SegmentControlType segmentType;

@end
