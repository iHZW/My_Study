//
//  BaseTableViewController.h
//  MainSubControllerDemo
//
//  Created by HZW on 2019/5/22.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseCellModel.h"

@interface BaseTableViewController : BaseViewController <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property(nonatomic, assign) UITableViewStyle tableViewStyle;
@end

