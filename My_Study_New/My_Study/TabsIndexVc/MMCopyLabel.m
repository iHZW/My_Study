//
//  MMCopyLabel.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/12/29.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "MMCopyLabel.h"

@implementation MMCopyLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self pressAction];
    }
    return self;
}


- (void)pressAction {
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPress.minimumPressDuration = 1;
    [self addGestureRecognizer:longPress];
}

// 使label能够成为响应事件
- (BOOL)canBecomeFirstResponder {
     return YES;
 }

// 控制响应的方法
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(customCopy:)
//        ||
//        action == @selector(copy:) ||
//        action == @selector(restet:) ||
//        action == @selector(paste:) ||
//        action == @selector(imageCopy:)
        ) {
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}

- (void)customCopy:(id)sender {
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  pasteboard.string = self.text;
}

/*系统提供的有一些公用的方法,只需要实现出来,对应的menuItem就会加上去 */
//-(void)copy:(id)sender
//{
//    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//    pasteboard.string = self.text;
//}
//-(void)paste:(id)sender
//{
//    NSLog(@"粘贴");
//}
//
//-(void)select:(id)sender
//{
//
//}
//-(void)selectAll:(id)sender
//{
//
//}
//-(void)restet:(UIMenuItem *)item
//{
//    NSLog(@"剪切");
//}

    
- (void)imageCopy:(id)sender {
    UIImage *image = [UIImage imageNamed:@"file_audio_icon"];
    [[UIPasteboard generalPasteboard] setImage:image];
}

- (void)longPressAction:(UIGestureRecognizer *)recognizer {
    [self becomeFirstResponder];
    UIMenuItem *customCopyItem = [[UIMenuItem alloc] initWithTitle:@"copy" action:@selector(customCopy:)];
//    UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"copy" action:@selector(copy:)];
//    UIMenuItem *cutItem = [[UIMenuItem alloc] initWithTitle:@"剪切" action:@selector(restet:)];
//    UIMenuItem *pasteItem = [[UIMenuItem alloc] initWithTitle:@"粘贴" action:@selector(paste:)];
//    UIMenuItem *imageCopyItem = [[UIMenuItem alloc] initWithTitle:@"imageCopy" action:@selector(imageCopy:)];

    [[UIMenuController sharedMenuController] setMenuItems:@[customCopyItem]]; //[NSArray arrayWithObjects:copyItem, imageItem, nil]];
    [[UIMenuController sharedMenuController] setTargetRect:CGRectMake(0, 0, 100, 20) inView:self];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
}

@end
