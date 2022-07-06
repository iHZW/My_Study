//
//  Toast.h
//  StarterApp
//
//  Created by js on 2019/6/24.
//  Copyright © 2019 js. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,ToastPosition) {
    ToastPositionTop = 0,
    ToastPositionMiddle,
    ToastPositionBottom
};

@class Toast;
typedef void(^ToastBlock)(Toast *);

@interface Toast: UIView

@property (nonatomic, assign,readonly) BOOL isCanceled;

+ (Toast *)show:(NSString *)msg;
+ (Toast *)show:(NSString *)msg adjustY:(CGFloat)adjustY inView:(UIView *_Nullable)superView;

+ (Toast *)showBlueToast:(nullable UIImage *)icon msg:(nullable NSString *)msg;

+ (Toast *)show:(NSString *)msg
numberOfLines:(NSInteger)numberOfLines
    duration:(NSTimeInterval)duration
    position:(ToastPosition)position
     adjustY:(CGFloat)adjustY
    willShow:(nullable ToastBlock)finishBlock
      finish:(nullable ToastBlock)finishBlock;

+ (Toast *)show:(NSString *)msg
numberOfLines:(NSInteger)numberOfLines
    duration:(NSTimeInterval)duration
    position:(ToastPosition)position
     adjustY:(CGFloat)adjustY
      inView:(nullable UIView *)parentView
    willShow:(nullable ToastBlock)showBlock
      finish:(nullable ToastBlock)finishBlock;

+ (Toast *)show:(nullable UIImage *)icon
            msg:(NSString *)msg
  numberOfLines:(NSInteger)numberOfLines
       duration:(NSTimeInterval)duration
       position:(ToastPosition)position
        adjustY:(CGFloat)adjustY
         inView:(nullable UIView *)parentView
       willShow:(nullable ToastBlock)showBlock
         finish:(nullable ToastBlock)finishBlock;

/**
 * 手动关闭 Toast (除非确定场景，需要关闭。否则不要调用)
 */
- (void)cancel;
@end

NS_ASSUME_NONNULL_END
