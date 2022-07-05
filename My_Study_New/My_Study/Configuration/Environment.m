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

- (void)loadData
{
    EnvConfigObject *config = [self loadEvnConfigObjectByBundleID];
    if (config.canManualChange){
        EnvironmentType envType = [[self class] queryEnvType];;
        if (envType == EnvironmentTypeNotFound){
            self.currentEnvironmentType = config.envType;
        } else {
            self.currentEnvironmentType = envType;
        }
        
    } else {
        self.currentEnvironmentType = config.envType;
    }
}


- (void)updateEnvironment:(EnvironmentType)toEnv
{
    self.currentEnvironmentType = toEnv;
    [[self class] saveEnv:toEnv];
}


- (EnvConfigObject *)loadEvnConfigObjectByBundleID
{
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    EnvConfigObject *config = [self.envConfigs filter:^BOOL(EnvConfigObject  *item) {
        return [item.bundleID isEqualToString:bundleID];
    }].firstObject;
    return config;
}


- (EnvConfigObject *)loadEvnConfigObject{
    EnvConfigObject *config = [self.envConfigs filter:^BOOL(EnvConfigObject  *item) {
        return item.envType == self.currentEnvironmentType;
    }].firstObject;
    return config;
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
    return _envConfigs;;
}


#pragma mark - Save & Query
+ (NSString *)storeEnvKey{
    return @"com.weimob.crm.environmenttype";
}

+ (void)saveEnv:(EnvironmentType)type{
    NSString *value = [NSString stringWithFormat:@"%lu",(unsigned long)type];
    [StoreUtil setString:value forKey:[self storeEnvKey] isPermanent:NO];
}

+ (EnvironmentType)queryEnvType{
    NSString *value = [StoreUtil stringForKey:[self storeEnvKey] isPermanent:NO];
    if (value.length == 0){
        //测试包，默认QA 方便测试
        return EnvironmentTypeQA;
    }
    return [value integerValue];
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
    return @"com.weimob.crm.im.offline";
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
