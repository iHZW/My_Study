//
//  HtmlImgAttachment.h
//  My_Study
//
//  Created by hzw on 2022/11/16.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HtmlImgAttachment : NSTextAttachment

@property (nonatomic, assign) CGPoint imgOrigin;

@property (nonatomic, assign) CGSize imgSize;

@end

NS_ASSUME_NONNULL_END
