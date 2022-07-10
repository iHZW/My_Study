//
//  LocationTrimAdapter.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/6.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "CMObject.h"
#import "POIAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LocationTrimAdapterDidSelectProtocol <NSObject>

- (void)locationTableViewDidSelect;

@end

@interface LocationTrimAdapter : CMObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIViewController *ownerController;

@property (nonatomic, strong) NSArray<POIAnnotation *> *poisList; //地址数组
@property (nonatomic, assign) POIAnnotation *selectedModel; //单选选中的行

@property (nonatomic, weak) id<LocationTrimAdapterDidSelectProtocol> delegate;

@end

NS_ASSUME_NONNULL_END
