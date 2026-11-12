//
//  Environment.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/5.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "Environment.h"
#import "StoreUtil.h"
#import "NSArray+Func.h"
#import "ZWEndpointConfiguration.h"

@interface Environment ()

@property (nonatomic,assign, readwrite) EnvironmentType currentEnvironmentType;

@property (nonatomic, strong) NSArray *envConfigs;

@end

@implementation Environment
DEFINE_SINGLETON_T_FOR_CLASS(Environment)

- (instancetype)init
{
    self = [super init];
    if (self){
        [self loadData];
    }
    return self;
}

- (BOOL)canChangeEnvironment {
#if defined(DEBUG) || defined(DOKIT)
    return [[[NSBundle.mainBundle infoDictionary][@"NetworkConfiguration"] objectForKey:@"AllowEnvironmentSwitch"] boolValue];
#else
    return NO;
#endif
}

- (void)loadData {
    NSDictionary *configuration = [NSBundle.mainBundle infoDictionary][@"NetworkConfiguration"];
    EnvironmentType selected = [ZWEndpointConfiguration environmentForName:configuration[@"DefaultEnvironment"]];
    // 配置异常时锁定生产环境，但缺失地址仍会明确失败，不猜测服务器。
    if (selected == EnvironmentTypeNotFound) selected = EnvironmentTypeOnline;
    if (self.canChangeEnvironment) {
        EnvironmentType saved = [self.class queryEnvType];
        NSString *name = [ZWEndpointConfiguration nameForEnvironment:saved];
        NSString *url = configuration[@"BaseURLs"][name];
        if (name.length && [ZWEndpointConfiguration validatedBaseURL:url allowHTTP:saved != EnvironmentTypeOnline error:NULL]) selected = saved;
    }
    self.currentEnvironmentType = selected;
}

- (BOOL)updateEnvironment:(EnvironmentType)toEnv error:(NSError **)error {
    NSString *name = [ZWEndpointConfiguration nameForEnvironment:toEnv];
    if (!self.canChangeEnvironment || !name.length) {
        if (error) *error = [NSError errorWithDomain:ZWEndpointErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"当前构建不允许切换环境"}];
        return NO;
    }
    NSString *url = [NSBundle.mainBundle infoDictionary][@"NetworkConfiguration"][@"BaseURLs"][name];
    if (![ZWEndpointConfiguration validatedBaseURL:url allowHTTP:toEnv != EnvironmentTypeOnline error:error]) return NO;
    [self.class saveEnv:toEnv];
    return YES;
}

- (EnvConfigObject *)loadEvnConfigObject {
    for (EnvConfigObject *config in self.envConfigs) {
        if (config.envType == self.currentEnvironmentType) return config;
    }
    return nil;
}

#pragma mark - lazyLoad
- (NSArray *)envConfigs
{
    if (!_envConfigs){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EnvConfig" ofType:@"plist"];
        NSArray *configs = [[NSArray alloc] initWithContentsOfFile:path];
        if ([configs isKindOfClass:NSArray.class]){
            _envConfigs = [JSONUtil parseObjectArrays:configs targetClass:EnvConfigObject.class];
        }
    }
    return _envConfigs;
}


#pragma mark - Save & Query
+ (NSString *)storeEnvKey{
    return @"com.zw.crm.environmenttype";
}

+ (void)saveEnv:(EnvironmentType)type{
    NSString *value = [NSString stringWithFormat:@"%lu",(unsigned long)type];
    [StoreUtil setString:value forKey:[self storeEnvKey] isPermanent:NO];
}

+ (EnvironmentType)queryEnvType{
    NSString *value = [StoreUtil stringForKey:[self storeEnvKey] isPermanent:NO];
    if (value.length == 0){
        return EnvironmentTypeNotFound;
    }
    NSScanner *scanner = [NSScanner scannerWithString:value];
    NSInteger type = 0;
    if (![scanner scanInteger:&type] || !scanner.isAtEnd || type < 0 || type > EnvironmentTypeOnline) return EnvironmentTypeNotFound;
    return (EnvironmentType)type;
}

- (void)saveSubEnv:(SubEnvInfo *)subEnv{
    NSString *json = [JSONUtil modelToJSONString:subEnv];
    [StoreUtil setString:json forKey:[self.class subEnvKey] isPermanent:NO];
}

- (SubEnvInfo *)fetchSubEnv{
    NSString *json = [StoreUtil stringForKey:[self.class subEnvKey] isPermanent:NO];
    SubEnvInfo *obj = [JSONUtil parseObject:json targetClass:SubEnvInfo.class];
    return obj;
}

+ (NSString *)subEnvKey{
    return @"Http-SubEnvLabel-Key-xxx";
}

- (NSString *)imOffLineKey{
    return @"com.zw.crm.im.offline";
}

- (BOOL)isIMForceOffline{
    NSString *value = [StoreUtil stringForKey:[self imOffLineKey] isPermanent:NO];
    if (value.length == 0){
        return NO;
    }
    return [value boolValue];
}

- (void)saveIMForceOffline:(BOOL)offline{
    NSString *value = [NSString stringWithFormat:@"%d",offline];
    [StoreUtil setString:value forKey:[self imOffLineKey] isPermanent:NO];
}

@end



@implementation SubEnvInfo

+ (instancetype)init:(NSString *)value on:(BOOL)on
{
    SubEnvInfo *subEnv = [[SubEnvInfo alloc] init];
    subEnv.value = value;
    subEnv.on = on;
    return subEnv;
}
@end
