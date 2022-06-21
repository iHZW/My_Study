//
//  UIButton+Block.m
//  TZYJ_IPhone
//
//  Created by Howard on 15/7/8.
//
//

#import "UIButton+Block.h"
#import <objc/runtime.h>

static char overviewKey;

@implementation UIButton(Block)
@dynamic event;

- (void)handleControlEvent:(UIControlEvents)event withBlock:(ActionBlock)block {
    objc_setAssociatedObject(self, &overviewKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(callActionBlock:) forControlEvents:event];
}


- (void)callActionBlock:(id)sender {
    ActionBlock block = (ActionBlock)objc_getAssociatedObject(self, &overviewKey);
    if (block) {
        block();
    }
}

@end
