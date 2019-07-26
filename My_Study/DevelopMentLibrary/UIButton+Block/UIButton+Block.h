//
//  UIButton+Block.h
//  TZYJ_IPhone
//
//  Created by Howard on 15/7/8.
//
//

#import <UIKit/UIKit.h>

#import <objc/runtime.h>


typedef void (^ActionBlock)();

@interface UIButton(Block)

@property (readonly) NSMutableDictionary *event;

- (void)handleControlEvent:(UIControlEvents)controlEvent withBlock:(ActionBlock)action;

@end
