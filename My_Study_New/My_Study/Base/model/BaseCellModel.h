//
//  BaseCellModel.h
//  MainSubControllerDemo
//
//  Created by HZW on 2019/5/22.
//  Copyright © 2019 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseCellModel : NSObject
@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) Class clazz;
@property(nonatomic, copy) NSString *flutterPageName;
// 是否跳转到flutter页面
@property(nonatomic, assign) BOOL isFlutterPage;

+ (instancetype)modelWithTitle:(NSString *)title clazz:(Class)clazz;
+ (instancetype)modelWithTitle:(NSString *)title flutterPageName:(NSString *)pageName;
@end

