//
//  FileIconNameUtil.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "FileIconNameUtil.h"

@implementation FileIconNameUtil

/**
 *  根据url链接 转换为本地显示的文件图片名称
 *
 *  @param url   文件链接
 */
+ (NSString *)transFileIconUrl:(NSString *)url
{
    return [[self class] transFileIconName:[url pathExtension]];
}

/**
 *  根据文件转换为本地显示的文件图片名称
 *
 *  @param iconName    文件名
 */
+ (NSString *)transFileIconName:(NSString *)iconName
{
    NSString *fileIcon = @"file_text_icon";
    
    NSString *lowerIconName = [iconName lowercaseString] ;
    
    if ([lowerIconName isEqualToString:@"ppt"] ||
        [lowerIconName isEqualToString:@"pptx"])
    {
        fileIcon = @"file_ppt_icon";
    }
    else if ([lowerIconName isEqualToString:@"doc"] ||
             [lowerIconName isEqualToString:@"dox"] ||
             [lowerIconName isEqualToString:@"docx"])
    {
        fileIcon = @"file_word_icon";
    }
    else if ([lowerIconName isEqualToString:@"xls"]  ||
             [lowerIconName isEqualToString:@"xlsx"] )
    {
        fileIcon = @"file_excel_icon";
    }
    else if ([lowerIconName isEqualToString:@"pdf"])
    {
        fileIcon = @"file_pdf_icon";
    }
    else if ([lowerIconName isEqualToString:@"key"]) {
        
        fileIcon = @"file_keynote_icon";
    }
    else if ([lowerIconName isEqualToString:@"pages"])
    {
        fileIcon = @"file_pages_icon";
    }
    else if ([lowerIconName isEqualToString:@"numbers"])
    {
        fileIcon = @"file_numbers_icon";
    }
    else if ([lowerIconName isEqualToString:@"jpg"] ||
             [lowerIconName isEqualToString:@"jpeg"] ||
             [lowerIconName isEqualToString:@"png"] ||
             [lowerIconName isEqualToString:@"apng"] ||
             [lowerIconName isEqualToString:@"bmp"] ||
             [lowerIconName isEqualToString:@"tiff"] ||
             [lowerIconName isEqualToString:@"gif"] ||
             [lowerIconName isEqualToString:@"tga"])
    {
        fileIcon = @"file_pic_icon";
    }
    else if ([lowerIconName isEqualToString:@"mp4"] ||
             [lowerIconName isEqualToString:@"avi"] ||
             [lowerIconName isEqualToString:@"wma"] ||
             [lowerIconName isEqualToString:@"mov"])
    {
        fileIcon = @"file_video_icon";
    }
    else if ([lowerIconName isEqualToString:@"mp3"])
    {
        fileIcon = @"file_audio_icon";
    }
    else if ([lowerIconName isEqualToString:@"rar"] ||
             [lowerIconName isEqualToString:@"zip"] ||
             [lowerIconName isEqualToString:@"7z"])
    {
        fileIcon = @"file_zip_icon";
    }
    return fileIcon;
}

@end
