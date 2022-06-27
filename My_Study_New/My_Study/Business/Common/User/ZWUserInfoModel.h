//
//  ZWUserInfoModel.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/21.
//  Copyright © 2022 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZWUserInfoModel : NSObject<NSSecureCoding>

/** 登陆成功的公司id */
@property (nonatomic, assign) long long pid;
/** 登陆用户id */
@property (nonatomic, assign) long long userWid;

@property (nonatomic, copy) NSString *tradeType;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *branchNo;
@property (nonatomic, copy) NSString *clientID;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *realName;
@property (nonatomic, assign) NSInteger loginstatus;
@property (nonatomic, copy) NSString *userCode;
@property (nonatomic, copy) NSString *sessionNo;
@property (nonatomic, copy) NSString *userParam1;
@property (nonatomic, copy) NSString *userParam2;
@property (nonatomic, copy) NSString *userParam3;
@property (nonatomic, copy) NSString *idNo;
@property (nonatomic, copy) NSString *idType;
@property (nonatomic, copy) NSString *inputContent;
@property (nonatomic, copy) NSString *accountType;//存放的是交易类型名字
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, copy) NSString *loginToken;


@property (nonatomic, copy) NSString *add_mobileNo;
@property (nonatomic, copy) NSString *add_loginType;//1，2用户名；3，4手机号；5资金号 7身份证
@property (nonatomic, copy) NSString *add_userId;
@property (nonatomic, copy) NSString *add_accountNo;//资金账号
@property (nonatomic, copy) NSString *add_creditNo;//用户绑定的两融账号
@property (nonatomic, copy) NSString *add_userState;//是否激活
@property (nonatomic, copy) NSString *add_hasSetPwd;//是否设置密码
@property (nonatomic, copy) NSString *add_loginToken;//新体系下的登录token缓存 两融也缓存在这
@property (nonatomic, copy) NSString *vipClassType;//5.10用户会员等级
@property (nonatomic, copy) NSString *riskType; //风险等级
@property (nonatomic, copy) NSString *growthValue;//成长值

@property (nonatomic, strong) NSMutableArray *accountMutArray;

// 是否是游客
- (BOOL)isVisitor;

@end

NS_ASSUME_NONNULL_END
