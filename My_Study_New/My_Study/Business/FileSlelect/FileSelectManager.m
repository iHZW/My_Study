//
//  FileSelectManager.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "FileSelectManager.h"
#import "LogUtil.h"
#import "LoadingUtil.h"
#import "ZWUserInfoBridgeModule.h"
#import "ZWNavigationController.h"
#import "UIApplication+Ext.h"

@interface FileSelectManager ()<UIDocumentPickerDelegate>

@property (nonatomic ,copy, readwrite) NSString *fileRootPath;

@end

@implementation FileSelectManager
DEFINE_SINGLETON_T_FOR_CLASS(FileSelectManager)


- (instancetype)init
{
    if (self = [super init]) {
        [self initLocalRootPath];
    }
    return self;
}

- (void)initLocalRootPath
{
    NSString *temPath = NSTemporaryDirectory();
    NSString *appName = [ZWUserInfoBridgeModule appName];
    NSString *rootPath = [NSString stringWithFormat:@"%@/data/%@_selectFile", temPath , appName];
    [[NSFileManager defaultManager] createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:nil error:nil];
    self.fileRootPath = rootPath;
}



/**
 *  打开文件选择控制器
 */
- (void)openFileSelectVc
{
    /* 文件选择器中不做文件筛选,选中文件之后上传的时候在做文件筛选 */
    NSArray *documentTypes = @[@"public.data"];
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
    documentPicker.delegate = self;
    
//    ZWNavigationController * na = [[ZWNavigationController alloc]initWithRootViewController:documentPicker];
    documentPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    documentPicker.hideNavigationBar = YES;
    [[UIApplication displayViewController] presentViewController:documentPicker animated:YES completion:nil];
}

/**
 *  检测支持上传的文件类型
 *
 *  @param fileName    文件名
 *
 *  @return 是否允需上传
 */
- (BOOL)checkUpLoadFile:(NSString *)fileName{
    NSArray *arr = [fileName componentsSeparatedByString:@"."];
    NSString *fileType = arr.lastObject;
    fileType = [fileType lowercaseString];
    if ([fileType isEqualToString:@"png"]
        || [fileType isEqualToString:@"jpg"]
        || [fileType isEqualToString:@"jpeg"]
        || [fileType isEqualToString:@"gif"]
        || [fileType isEqualToString:@"bmp"]
        || [fileType isEqualToString:@"txt"]
        || [fileType isEqualToString:@"doc"]
        || [fileType isEqualToString:@"docx"]
        || [fileType isEqualToString:@"xls"]
        || [fileType isEqualToString:@"xlsx"]
        || [fileType isEqualToString:@"ppt"]
        || [fileType isEqualToString:@"pptx"]
        || [fileType isEqualToString:@"pdf"]
        || [fileType isEqualToString:@"mp3"]
        || [fileType isEqualToString:@"mp4"]
        || [fileType isEqualToString:@"zip"]
        || [fileType isEqualToString:@"rar"])
    {
        return YES;
    }
    return NO;
}

/**
 *  极端文件大小 需要小于100MB
 *
 *  @param fileData    文件
 *  @param  fileName    名称
 *
 */
- (BOOL)calculateFileSize:(NSData *)fileData fileName:(NSString *)fileName
{
    BOOL isCanUpLoad = YES;
    float maxSize = 100*1024*1024;
    if (fileData.length > maxSize) {
        isCanUpLoad = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            BlockSafeRun([FileSelectManager sharedFileSelectManager].selectFileComplete, @[]);
            [Toast show:@"上传文件最大支持100M！"];
            [LoadingUtil hide];
        });
    }
    
    /* 支持的类型 */
    BOOL isSupport = [self checkUpLoadFile: fileName];
    if (!isSupport) {
        isCanUpLoad = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            BlockSafeRun([FileSelectManager sharedFileSelectManager].selectFileComplete, @[]);
            [Toast show:@"暂不支持该文件格式！"];
            [LoadingUtil hide];
        });
    }
    return isCanUpLoad;
}


#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    BOOL canAccessingResource = [url startAccessingSecurityScopedResource];
    if(canAccessingResource) {
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;
        __weak FileSelectManager * weakSelf = self;
        [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
            [LoadingUtil show];
            NSData *fileData = [NSData dataWithContentsOfURL:newURL];
            NSString *fileName = [[url path] lastPathComponent];
            
            BOOL isCanUpLoad = [weakSelf calculateFileSize:fileData fileName: fileName];
            if (!isCanUpLoad) {
                return;
            }
//            NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//            NSString *documentPath = [arr lastObject];
//            NSString *desFileName = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"data/file/%@", fileName]];
//            [fileData writeToFile:desFileName atomically:YES];

            /** 走图片上传 成功之后回调  */
            NSString *filePath = [[FileSelectManager sharedFileSelectManager].fileRootPath stringByAppendingPathComponent:fileName];
            [fileData writeToFile:filePath atomically:YES];
//            [weakSelf uploadFileWithFilePath:filePath fileName:fileName];
            
            {
                /** 暂时只做显示逻辑  */
                PHAssetModel *model = [PHAssetModel new];
//                model.fileUrl = url;
                model.isFile = YES;
                model.originalPath = filePath;
                model.realFileName = fileName;
                model.fileName = fileName;
                model.fileSize = fileData.length;
               
                NSMutableArray *fileMutArr = [NSMutableArray array];
                [fileMutArr addObject:model];
                BlockSafeRun([FileSelectManager sharedFileSelectManager].selectFileComplete, fileMutArr);
                [LoadingUtil hide];
            }
            
            [[UIApplication displayViewController] dismissViewControllerAnimated:YES completion:NULL];
        }];
        if (error) {
            // error handing
        }
    } else {
        // startAccessingSecurityScopedResource fail
    }
    [url stopAccessingSecurityScopedResource];
}


/**
 *  上传文件
 *
 *  @param  filePath   文件路径
 *  @param  fileName    文件名称
 *
 */
- (void)uploadFileWithFilePath:(NSString *)filePath fileName:(NSString *)fileName
{
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [WMMediaCenterUpload uploadFileWithFilePath:filePath fileRequireType:MCFileRequireTypeCommon progressBlock:^(float progress) {
//            NSLog(@"progress = %@", @(progress));
//        } success:^(NSString * _Nonnull url, id  _Nonnull response) {
//            if (url && url.length > 0) {
//                PHAssetModel *model = [PHAssetModel new];
//                model.fileUrl = url;
//                model.isFile = YES;
//                model.realFileName = fileName;
//                NSMutableArray *fileMutArr = [NSMutableArray array];
//                if ([response isKindOfClass:[NSDictionary class]]) {
//                    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:response];
//                    model.fileSize = [dict[@"fileSize"] doubleValue];
//                    model.fileName = __String_Not_Nil(fileName);//dict[@"name"];
//                    model.originalPath = filePath;
//                }
//                [fileMutArr addObject:model];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    BlockSafeRun([FileSelectManager sharedFileSelectManager].selectFileComplete, fileMutArr);
//                    [ProgressHUD hideHUDProgress:[UIApplication displayWindow]];
//                });
//
//                NSFileManager *fileManager = [NSFileManager defaultManager];
//                NSString *filePath = [[FileSelectManager sharedInstance].fileRootPath stringByAppendingPathComponent:fileName];
//                BOOL isExist = [fileManager fileExistsAtPath:filePath];
//                if (filePath && filePath.length > 0 && isExist) {
//                    /* 上传成功删除本地文件 */
//                    [fileManager removeItemAtPath:filePath error:nil];
//                    BOOL isE = [fileManager fileExistsAtPath:filePath];
//                    NSLog(@"isE = === %@", @(isE));
//                }
//            }
//        } failure:^(NSString * _Nonnull message) {
//            [Log error:message tag:SIP_RECORD_TASK_MEDIA_CENTER_FAIL extraTags:@[]];
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                BlockSafeRun([FileSelectManager sharedFileSelectManager].selectFileComplete, @[]);
//                [Toast show:message];
//                [ProgressHUD hideHUDProgress:[UIApplication displayWindow]];
//            });
//        }];
//    });

}



@end
