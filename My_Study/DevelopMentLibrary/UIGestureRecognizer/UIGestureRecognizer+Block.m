

//
//  UIGestureRecognizer+Block.m
//  PASecuritiesApp
//
//  Created by Howard on 16/8/1.
//  Copyright © 2016年 PAS. All rights reserved.
//

#import "UIGestureRecognizer+Block.h"
#import <objc/runtime.h>

static const char *RecognizerLevelKey = "recognizerLevel";
static const char *ActionBlockKey     = "actionBlock";


@implementation UIGestureRecognizer (Block)

- (instancetype)initWithActionBlock:(GestureRecognizerBlock)block
{
    self          = [self initWithTarget:self action:@selector(doRecognizerAction:)];
    self.delegate = (id)self;
    [self setActionBlock:block];
    return self;
}

- (void)addActionBlock:(GestureRecognizerBlock)block
{
    [self setActionBlock:block];
    [self addTarget:self action:@selector(doRecognizerAction:)];
}

- (void)setRecognizerLevel:(GestureRecognizerLevel)recognizerLevel
{
    objc_setAssociatedObject(self, RecognizerLevelKey, @(recognizerLevel), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (GestureRecognizerLevel)recognizerLevel
{
    return  [objc_getAssociatedObject(self, RecognizerLevelKey) integerValue];
}

- (void)setActionBlock:(GestureRecognizerBlock)block
{
    objc_setAssociatedObject(self, ActionBlockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (GestureRecognizerBlock)actionBlock
{
    return  objc_getAssociatedObject(self, ActionBlockKey);
}

- (void)doRecognizerAction:(UIGestureRecognizer *)recognizer
{
    __block UIGestureRecognizer *tmpRecognizer = recognizer;
    
    if (self.actionBlock)
    {
        self.actionBlock(tmpRecognizer);
    }
}

#pragma mark UIGestureRecognizer DelegateMethod
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIControl class]])
    {
        return NO;
    }
    for (UIGestureRecognizer *recognizer in touch.gestureRecognizers)
    {
        if (self.recognizerLevel<recognizer.recognizerLevel && recognizer.recognizerLevel!=GestureRecognizerLevelDefault)
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
