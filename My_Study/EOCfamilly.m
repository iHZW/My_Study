//
//  EOCfamilly.m
//  My_Study
//
//  Created by HZW on 2019/5/22.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "EOCfamilly.h"

@interface EOCfamilly ()

//@property (nonatomic, strong) NSMutableArray *famillyArray;
//
//@property (nonatomic, copy) NSString *name;

@end

@implementation EOCfamilly

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (NSMutableArray *)famillyArray
{
    if (!_famillyArray) {
        _famillyArray = [NSMutableArray array];
    }
    return _famillyArray;
}

///**< 默认自动通知观察者, */
//+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
//{
//    /**< 添加判断 监听到name变化,手动来实现监听通知 */
//    if ([key isEqualToString:@"name"]) {
//        return NO;
//    }
//    return YES;
//}

@end
