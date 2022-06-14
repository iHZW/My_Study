//
//  IQViewModel+Eat.m
//  My_Study
//
//  Created by HZW on 2021/8/11.
//  Copyright © 2021 HZW. All rights reserved.
//

#import "IQViewModel+Eat.h"

static const char kWFNameKey;

@implementation IQViewModel (Eat)


- (void)eat:(NSString *)someting
{
    NSLog(@"eat: %@", someting);
}

+ (void)play
{
    NSLog(@"IQViewModel play");
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    
//    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.wf_name forKey:@"wf_name"];
//    [coder encodeObject:[NSNumber numberWithInt:self.wf_count] forKey:@"wf_count"];
    [coder encodeInt:self.wf_count forKey:@"wf_count"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self) {
        self.wf_name = [coder decodeObjectForKey:@"wf_name"];
        self.wf_count = [coder decodeIntForKey:@"wf_count"];
    }
    return self;
}

#pragma mark - NSCopying
- (IQViewModel *)copyWithZone:(nullable NSZone *)zone {
    IQViewModel *viewModel = [[self class] allocWithZone:zone];
    viewModel.wf_name = [self.wf_name copyWithZone:zone];
    return viewModel;
}


- (int)wf_count
{
    return [objc_getAssociatedObject(self, _cmd) intValue];
}

- (void)setWf_count:(int)wf_count
{
    objc_setAssociatedObject(self, @selector(wf_count), @(wf_count), OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)wf_name
{
    return objc_getAssociatedObject(self, &kWFNameKey);
}

- (void)setWf_name:(NSString *)wf_name
{
    objc_setAssociatedObject(self, &kWFNameKey, wf_name, OBJC_ASSOCIATION_COPY);
}


//- (instancetype)copyWithZone:(NSZone *)zone {
//    AFHTTPSessionManager *HTTPClient = [[[self class] allocWithZone:zone] initWithBaseURL:self.baseURL sessionConfiguration:self.session.configuration];
//
//    HTTPClient.requestSerializer = [self.requestSerializer copyWithZone:zone];
//    HTTPClient.responseSerializer = [self.responseSerializer copyWithZone:zone];
//    HTTPClient.securityPolicy = [self.securityPolicy copyWithZone:zone];
//    return HTTPClient;
//}

@end
