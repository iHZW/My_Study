//
//  BaseTableViewController.h
//  MainSubControllerDemo
//
//  Created by HZW on 2019/5/22.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "ZWBaseViewController.h"
#import "BaseCellModel.h"

@interface BaseTableViewController : ZWBaseViewController <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property(nonatomic, assign) UITableViewStyle tableViewStyle;
@end

