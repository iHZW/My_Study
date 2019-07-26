//
//  UIGestureRecognizer+Block.h
//  PASecuritiesApp
//
//  Created by Howard on 16/8/1.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^GestureRecognizerBlock) (id obj);

/**
 *  <#Description#>
 */
typedef NS_ENUM(NSInteger, GestureRecognizerLevel) {
    /**
     *  <#Description#>
     */
    GestureRecognizerLevelDefault = 0,
    /**
     *  <#Description#>
     */
    GestureRecognizerLevelLow     = 1,
    /**
     *  <#Description#>
     */
    GestureRecognizerLevelMiddle  = 2,
    /**
     *  <#Description#>
     */
    GestureRecognizerLevelHigh    = 3,
};

@interface UIGestureRecognizer (Block)

@property (nonatomic, copy) GestureRecognizerBlock actionBlock;

@property (nonatomic) GestureRecognizerLevel recognizerLevel;

- (instancetype)initWithActionBlock:(GestureRecognizerBlock)block;

- (void)addActionBlock:(GestureRecognizerBlock)block;

- (void)setRecognizerLevel:(GestureRecognizerLevel)recognizerLevel;

- (GestureRecognizerLevel)recognizerLevel;

@end
