//
//  HtmlImgAttachment.m
//  My_Study
//
//  Created by hzw on 2022/11/16.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "HtmlImgAttachment.h"

@implementation HtmlImgAttachment

- (instancetype)init {
    self = [super init];
    if (self) {
        self.imgOrigin = CGPointZero;
    }
    return self;
}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex {
    return CGRectMake(self.imgOrigin.x, self.imgOrigin.y, _imgSize.width, _imgSize.height);
}

@end
