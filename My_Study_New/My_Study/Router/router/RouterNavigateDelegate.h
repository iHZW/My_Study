//
//  RouterNavigateDelegate.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#ifndef RouterNavigateDelegate_h
#define RouterNavigateDelegate_h

@protocol RouterNavigateDelegate <NSObject>
/** push  */
- (void)navigateTo:(RouterParam *)param;
/** present  */
- (void)presentTo:(RouterParam *)param;
/** tab切换  */
- (void)tabTo:(RouterParam *)param;
/** 行为路由  */
- (void)doAction:(RouterParam *)param;
@end


#endif /* RouterNavigateDelegate_h */
