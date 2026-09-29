//
//  WBHookBlock.h
//  WBHookBlockDemo

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WBHookBlockPosition) {
    WBHookBlockPositionBefore = 0,
    WBHookBlockPositionAfter,
    WBHookBlockPositionReplace,
};

@interface WBHookBlock : NSObject

+ (void)runBlock:(id)block;

+ (void)runBlock_Invocation:(id)block;

+ (void)easy_hookBlock:(id)originBlock alter:(id)alterBlock;

+ (void)hookBlock:(id)originBlock alter:(id)alterBlock position:(WBHookBlockPosition)position;


@end

NS_ASSUME_NONNULL_END
