//
//  UITextField+Additions.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/9/9.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "UITextField+Additions.h"

@implementation UITextField (Additions)

-(NSRange)selectedRange{
    NSInteger location = [self offsetFromPosition:self.beginningOfDocument toPosition:self.selectedTextRange.start];
    NSInteger length = [self offsetFromPosition:self.selectedTextRange.start toPosition:self.selectedTextRange.end];
    return NSMakeRange(location, length);
}

-(void)setSelectedRange:(NSRange)selectedRange{
    UITextPosition *startPosition = [self positionFromPosition:self.beginningOfDocument offset:selectedRange.location];
    UITextPosition *endPosition = [self positionFromPosition:self.beginningOfDocument offset:selectedRange.location + selectedRange.length];
    UITextRange *selectedTextRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    [self setSelectedTextRange:selectedTextRange];
}
/**
 *  禁止三指撤回操作,  解决 部分机型三指操作crash的问题
 */
- (UIEditingInteractionConfiguration)editingInteractionConfiguration {
    return UIEditingInteractionConfigurationNone;
}

@end
