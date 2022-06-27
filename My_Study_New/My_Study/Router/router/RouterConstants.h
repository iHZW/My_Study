//
//  RouterConstants.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#ifndef RouterConstants_h
#define RouterConstants_h

//后续路由增加功能，可增加对应Type
typedef NS_ENUM(NSUInteger,RouterType) {
    RouterTypeNavigate = 0, //页面跳转 push
    RouterTypeNavigatePresent, //Present
    RouterTypeNavigateTab, //切换tab
    RouterTypeAction , //行为路由
};

#endif /* RouterConstants_h */
