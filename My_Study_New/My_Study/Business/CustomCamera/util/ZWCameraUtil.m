//
//  ZWCameraUtil.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWCameraUtil.h"
#import "ZWCameraManager.h"
#import "NSFileManager+Ext.h"

@implementation ZWCameraUtil

+ (AVAssetExportSession *)changeMp4:(NSURL *)url complete:(void(^)(NSURL * resultUrl))complete
{
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    /**
    AVAssetExportPresetMediumQuality 表示视频的转换质量，
    */
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
         
        //转换完成保存的文件路径
        NSString *fileName = [[NSFileManager defaultManager] generateRandomVideoName];
        NSString *resultPath = [[ZWCameraManager sharedZWCameraManager].rootDir stringByAppendingPathComponent:fileName];
        
        exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
         
        //要转换的格式，这里使用 MP4
        exportSession.outputFileType = AVFileTypeMPEG4;
         
        //转换的数据是否对网络使用优化
        exportSession.shouldOptimizeForNetworkUse = YES;
         
        //异步处理开始转换
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void){
              //转换状态监控
            switch (exportSession.status) {
                case AVAssetExportSessionStatusUnknown:
                    NSLog(@"AVAssetExportSessionStatusUnknown");
                    break;
                case AVAssetExportSessionStatusWaiting:
                    NSLog(@"AVAssetExportSessionStatusWaiting");
                    break;
                case AVAssetExportSessionStatusExporting:
                    NSLog(@"AVAssetExportSessionStatusExporting");
                    break;
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"AVAssetExportSessionStatusFailed");
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"AVAssetExportSessionStatusCancelled");
                    break;
                case AVAssetExportSessionStatusCompleted:{
                    //转换完成
                    NSLog(@"AVAssetExportSessionStatusCompleted");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        BlockSafeRun(complete,exportSession.outputURL);
                    });
                    break;
                  }
            }
        }];
        return exportSession;
     }
    return nil;
}

@end
