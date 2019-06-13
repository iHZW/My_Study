//
//  ZWTextDrawing.m
//  My_Study
//
//  Created by HZW on 2019/6/4.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "ZWTextDrawing.h"
#import "NSString+Adaptor.h"

@protocol DZHTextItem ;

@implementation ZWTextDrawing

- (void)dealloc
{
#if !__has_feature(objc_arc)
    [_textFont release];
    [_textColor release];
    [_textColor release];
    
    [super dealloc];
#endif
}

- (void)drawRect:(CGRect)rect withContext:(CGContextRef)context
{
    CGContextSaveGState(context);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    
    [self.text adaptorDrawInRect:rect withFont:self.textFont fontColor:self.textColor lineBreakMode:NSLineBreakByWordWrapping alignment:self.alignment];
    
    CGContextRestoreGState(context);
}


@end



@implementation ZWTextsDrawing

- (void)drawRect:(CGRect)rect withContext:(CGContextRef)context
{
    NSArray *datas = [self dataForDrawingInRect:rect];
    if ([datas count] > 0) {
        CGContextSaveGState(context);
        
        for (id<DZHTextItem> entity in datas) {
            [entity.text adaptorDrawCenterInRect:rect withFont:entity.textFont fontColor:entity.textColor alignment:entity.alignment];
        }
        
        CGContextRestoreGState(context);
    }
}



@end
