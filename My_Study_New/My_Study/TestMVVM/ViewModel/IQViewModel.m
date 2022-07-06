//
//  IQViewModel.m
//  My_Study
//
//  Created by HZW on 2019/5/27.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "IQViewModel.h"
#import <objc/message.h>

@interface IQViewModel ()

@property (nonatomic, copy, readwrite) NSString *userName;

@property (nonatomic, copy, readwrite) NSString *userPwd;

@end

@implementation IQViewModel


+ (IQViewModel *)demoViewWithName:(NSString *)userName
                          withPwd:(NSString *)userPwd
{
    IQViewModel *viewModel = [[IQViewModel alloc] init];
    viewModel.userName = userName;
    viewModel.userPwd = userPwd;
    return viewModel;
}

- (void)updateViewModelWithName:(NSString *)userName
                        withPwd:(NSString *)userPwd
{
    _userName = userName;
    _userPwd = userPwd;
}

- (void)test
{
    NSLog(@"%s", __func__);
}

//- (void)play
//{
//    NSLog(@"%s", __func__);
//}

- (void)print
{
    NSLog(@"name is %@", @(self.age));
}

+ (BOOL)resolveClassMethod:(SEL)sel
{
    return YES;
}


/** 动态方法解析 */
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    if (sel == @selector(test)) {
        Method method = class_getInstanceMethod(self, @selector(other));
        char const *types = method_getTypeEncoding(method);
        class_addMethod(self, @selector(test), method_getImplementation(method), types);
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

//+(BOOL)resolveClassMethod:(SEL)sel
//{
//    return YES;
//}
//
//- (void)forwardInvocation:(NSInvocation *)anInvocation
//{
//    
//}
//
//- (id)forwardingTargetForSelector:(SEL)aSelector
//{
//    return [super forwardingTargetForSelector:aSelector];
//}



- (void)other
{
    NSLog(@"动态方法解析 %s",__func__);
}

void change_method (id self , SEL _cmd) {
    NSLog(@"防止crash");
}


/** 消息转发  */
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return [super forwardingTargetForSelector:aSelector];
}


/* 方法签名 封装方法调用, 包含方法调用者,方法名,方法参数
 *pragma <#name#> - <#describe#>
 *pragma <#name#> - <#describe#>
 *pragma <#name#> - <#describe#>
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return nil;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    
}


- (void)doesNotRecognizeSelector:(SEL)aSelector
{
//    Method method = class_getInstanceMethod([IQViewModel class], @selector(other));
//    char const *types = method_getTypeEncoding(method);
//    class_addMethod([IQViewModel class], aSelector, method_getImplementation(method), types);
    NSLog(@"doesNotRecognizeSelector = %@", NSStringFromSelector(aSelector));
}


@end
