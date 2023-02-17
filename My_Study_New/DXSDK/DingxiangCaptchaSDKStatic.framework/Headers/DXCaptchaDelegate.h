//
//  DXCaptchaDelegate.h
//  DingxiangCaptchaSDK
//
//  Created by xelz on 2017/9/25.
//  Copyright © 2017年  All rights reserved.
//
#define DXCAPTCHA_SDK_VERSION "1.7.0"

#import <Foundation/Foundation.h>

typedef enum {
    DXCaptchaEventNone,
    
    // 渲染事件，验证码开始渲染时触发
    DXCaptchaEventBeforeRender,
    DXCaptchaEventRender,
    DXCaptchaEventAfterRender,
    
    // 验证码准备就绪，可以接受用户输入时触发
    DXCaptchaEventBeforeReady,
    DXCaptchaEventReady,
    DXCaptchaEventAfterReady,
    
    // 加载失败时触发
    DXCaptchaEventBeforeLoadFail,
    DXCaptchaEventLoadFail,
    DXCaptchaEventAfterLoadFail,
    
    // 用户开始拖动滑块
    DXCaptchaEventBeforeDragStart,
    DXCaptchaEventDragStart,
    DXCaptchaEventAfterDragStart,
    
    // 用户拖动滑块过程中多次触发
    DXCaptchaEventBeforeDragging,
    DXCaptchaEventDragging,
    DXCaptchaEventAfterDragging,
    
    // 用户释放滑块，结束拖动
    DXCaptchaEventBeforeDragEnd,
    DXCaptchaEventDragEnd,
    DXCaptchaEventAfterDragEnd,
    
    // 向校验接口提交数据进行校验
    DXCaptchaEventBeforeVerify,
    DXCaptchaEventVerify,
    DXCaptchaEventAfterVerify,
    
    // 校验接口已返回数据
    DXCaptchaEventBeforeVerifyDone,
    DXCaptchaEventVerifyDone,
    DXCaptchaEventAfterVerifyDone,
    
    // 校验接口已返回数据，且结果为成功
    DXCaptchaEventBeforeVerifySuccess,
    DXCaptchaEventVerifySuccess,
    DXCaptchaEventAfterVerifySuccess,
    
    // 校验接口已返回数据，且结果为失败
    DXCaptchaEventBeforeVerifyFail,
    DXCaptchaEventVerifyFail,
    DXCaptchaEventAfterVerifyFail,
    
    // 无感验证通过
    DXCaptchaEventBeforePassByServer,
    DXCaptchaEventPassByServer,
    DXCaptchaEventAfterPassByServer,
    
    // 验证通过，无论是滑动验证通过还是无感验证通过均会触发
    DXCaptchaEventSuccess,
    
    // 验证失败
    DXCaptchaEventFail,
    
    //点击logo
    DXCaptchaEventTapLogo,

    //加载太多次
    DXCaptchaEventLoadTooMuch
} DXCaptchaEventType;

@class DXCaptchaView;

@protocol DXCaptchaDelegate <NSObject>

@required
- (void) captchaView:(DXCaptchaView *)view didReceiveEvent:(DXCaptchaEventType)eventType arg:(NSDictionary *)dict;

@end
