//
//  ZWTableViewAdapter.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/29.
//  Copyright © 2022 HZW. All rights reserved.
//

#ifndef ZWTableViewAdapter_h
#define ZWTableViewAdapter_h

@protocol ZWTableViewAdapter <NSObject>

@property (nonatomic, assign) BOOL reloadTableView;

@optional
//每个cell点击的回调
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSInteger)row;

@required
//init方法
- (id)initWithData:(NSDictionary *)data;
//cell的总数
- (NSInteger)numberOfRows;
//每个cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndex:(NSInteger)row;
//返回需要展示的cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndex:(NSInteger)row;

@end


#endif /* ZWTableViewAdapter_h */
