//
//  TabbarConfig.m
//  CRM
//
//  Created by js on 2021/11/2.
//  Copyright © 2021 CRM. All rights reserved.
//

#import "TabbarConfig.h"
#import "JSONUtil.h"
#import "RouterPageModel.h"

@implementation TabbarConfig

- (id)copyWithZone:(nullable NSZone *)zone{
    id object = [JSONUtil modelToJSONObject:self];
    id copyObject = [JSONUtil parseObject:object targetClass:[TabbarConfig class]];
    return copyObject;
}

+ (NSDictionary *)mj_objectClassInArray{
    return @{
        @"displayList" : @"CustomTabbarObject",
        @"hiddenList" : @"CustomTabbarObject"
    };
}

+ (NSString *)tabbarStoreKey{
//    return [NSString stringWithFormat:@"TAB_LIST_CONFIG_V2_%lld_%lld",Session.userSession.pid,Session.userSession.userWid];
    /** 可以根据不同的用户缓存 不同的tabbar数据  */
    long long pid = ZWCurrentUserInfo.pid;
    long long userWid = ZWCurrentUserInfo.userWid;
    return [NSString stringWithFormat:@"TAB_LIST_CONFIG_V2_%lld_%lld",pid,userWid];
}

+ (void)saveTabListConfig:(TabbarConfig *)config{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:[JSONUtil modelToJSONString:config] forKey:[self tabbarStoreKey]];
}

+ (TabbarConfig *)loadTabListConfig{
    /** 判断是否是游客模式  */
    if (ZWCurrentUserInfo.isVisitor){
        return [self defaultVisitorTabbarConfig];
    }
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *str = [user objectForKey:[self tabbarStoreKey]];
    if (str.length > 0){
        TabbarConfig *tabConfig = [JSONUtil parseObject:[JSONUtil jsonObject:str] targetClass:TabbarConfig.class];
        if (tabConfig.displayList.count > 0){
            return tabConfig;
        }
    }
    return [self defaultTabbarConfig];
}

+ (TabbarConfig *)defaultTabbarConfig{
    /** 判断是否是游客模式  */
    if (ZWCurrentUserInfo.isVisitor){
        return [self defaultVisitorTabbarConfig];
    }
    
    NSDictionary * defaultConfig = @{
        @"tabType":@(1),
        @"bizType":@"tab",
        @"displayList":@[
            @{
                @"code":@(1001),
                @"title":@"首页",
                @"iconUrl":@"Icon_Home_UnSelect",
                @"selectedIconUrl":@"Icon_Home_Select",
                @"route":ZWTabIndexHome,
                @"fontColor":@"#D5D5E1",
                @"selectedFontColor":@"#4F7AFD",
                @"editingIconUrl":@"Icon_Home_UnSelect"
            },
            @{
                @"code":@(1002),
                @"iconUrl":@"Icon_Find_UnSelect",
                @"selectedIconUrl":@"Icon_Find_Select",
                @"title":@"寻找",
                @"route":ZWTabIndexFind,
                @"fontColor":@"#D5D5E1",
                @"selectedFontColor":@"#4F7AFD",
                @"editingIconUrl":@"Icon_Find_UnSelect"
            },@{
                @"code":@(1003),
                @"iconUrl":@"Icon_Application_UnSelect",
                @"selectedIconUrl":@"Icon_Application_Select",
                @"title":@"应用",
                @"route":ZWTabIndexApplication,
                @"fontColor":@"#D5D5E1",
                @"selectedFontColor":@"#4F7AFD",
                @"editingIconUrl":@"Icon_Application_UnSelect"
            },
            @{
                @"code":@(1004),
                @"title":@"我的",
                @"iconUrl":@"Icon_Personal_UnSelect",
                @"selectedIconUrl":@"Icon_Personal_Select",
                @"route":ZWTabIndexPersonal,
                @"fontColor":@"#D5D5E1",
                @"selectedFontColor":@"#4F7AFD",
                @"editingIconUrl":@"Icon_Personal_UnSelect"
            }
        ]
    };
    TabbarConfig *tabConfig = [JSONUtil parseObject:defaultConfig targetClass:TabbarConfig.class];
    return tabConfig;
}

// 游客模式 底部tab 配置
+ (TabbarConfig *)defaultVisitorTabbarConfig{
    NSDictionary * defaultConfig = @{
        @"tabType":@(1),
        @"bizType":@"tab",
        @"displayList":@[
            @{
                @"code":@(1001),
                @"title":@"首页",
                @"iconUrl":@"Icon_Home_UnSelect",
                @"selectedIconUrl":@"Icon_Home_Select",
                @"route":ZWTabIndexHome,
                @"fontColor":@"#D5D5E1",
                @"selectedFontColor":@"#4F7AFD",
                @"editingIconUrl":@"Icon_Home_UnSelect"
            },
            @{
                @"code":@(1002),
                @"iconUrl":@"Icon_Find_UnSelect",
                @"selectedIconUrl":@"Icon_Find_Select",
                @"title":@"寻找",
                @"route":ZWTabIndexFind,
                @"fontColor":@"#D5D5E1",
                @"selectedFontColor":@"#4F7AFD",
                @"editingIconUrl":@"Icon_Find_UnSelect"
            },@{
                @"code":@(1003),
                @"iconUrl":@"Icon_Application_UnSelect",
                @"selectedIconUrl":@"Icon_Application_Select",
                @"title":@"应用",
                @"route":ZWTabIndexApplication,
                @"fontColor":@"#D5D5E1",
                @"selectedFontColor":@"#4F7AFD",
                @"editingIconUrl":@"Icon_Application_UnSelect"
            },
            @{
                @"code":@(1004),
                @"title":@"我的",
                @"iconUrl":@"Icon_Personal_UnSelect",
                @"selectedIconUrl":@"Icon_Personal_Select",
                @"route":ZWTabIndexPersonal,
                @"fontColor":@"#D5D5E1",
                @"selectedFontColor":@"#4F7AFD",
                @"editingIconUrl":@"Icon_Personal_UnSelect"
            }
        ]
    };
    TabbarConfig *tabConfig = [JSONUtil parseObject:defaultConfig targetClass:TabbarConfig.class];
    return tabConfig;
}

@end
