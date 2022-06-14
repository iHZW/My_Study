//
//  UIButton+PASEnlargeEdge.h
//  PASecuritiesApp
//
//  Created by 沈治(EX-SHENZHI001) on 2019/3/21.
//  Copyright © 2019年 PAS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (PASEnlargeEdge)

- (void)setEnlargeEdge:(CGFloat) size;
- (void)setEnlargeEdgeWithTop:(CGFloat) top right:(CGFloat) right bottom:(CGFloat) bottom left:(CGFloat) left;

@end
