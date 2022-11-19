//
//  FindViewController.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FindViewController : ZWBaseViewController

@end


@interface VideoModel : NSObject
/** 名称  */
@property (nonatomic, copy) NSString *name;
/** video url 链接  */
@property (nonatomic, copy) NSString *videoUrl;

+ (VideoModel *)createViewModel:(NSString *)name videoUrl:(NSString *)videoUrl;

@end

NS_ASSUME_NONNULL_END
