//
//  CommonFileFunc.m
//  --
//
//  Created by Howard Dong on 13-1-15.
//  Copyright (c) 2013年 -- All rights reserved.
//

#import "CommonFileFunc.h"

#define KNetWorkCacheFile @"netData"

@implementation CommonFileFunc

#pragma mark- 取bundle内容

+ (NSDictionary*)escapeDictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"<",@"&lt;",
            @">",@"&gt;",
            @"&",@"&amp;",
            @"\'",@"&apos;",
            @"\"",@"&quot;",
            @" ",@"&nbsp;",nil];
}

+ (NSString *)getBundlePathWithFilePath:(NSString *)filePath
{
    NSString *appPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    appPath = [appPath stringByDeletingLastPathComponent];
    return [appPath stringByAppendingPathComponent:filePath];
}

+ (NSString*)urlEncode:(NSString *)sSrc
{
    NSString * retString;
    Byte * buf = NULL;
    
    if([sSrc length] == 0)
        return @"";
    
    const char * origSrc = [sSrc UTF8String];
    const int origLen = (int)strlen(origSrc);
    if(origLen == 0)
        return @"";
    //
    retString = @"";
    
    char * inbuf = malloc(origLen+1);
    if(inbuf == NULL)
        return @"";
    
    memset(inbuf,0,origLen+1);
    strcpy(inbuf, origSrc);
    
    int assumLength = origLen;
    
    //char speciaChar[] = {'$','-','_','.','!','*','\'','(',')',',',';','/','?',':','@','=',0};//'+',&是需要转的
    
    for(int i=0; i<origLen; ++i)
    {
        Byte c = inbuf[i];
        if( !(/*strchr(speciaChar,c) || */(c>='A'&&c<='Z') || (c>='a'&&c<='z') || (c>='0'&&c<='9')) )//忽略空格
        {
            assumLength+=2;
        }
    }
    
    buf = (Byte*)malloc(assumLength + 1);
    memset(buf, 0, assumLength + 1);
    
    int iDest = 0;
    for(int i=0; i<origLen; ++i,++iDest)
    {
        Byte c = inbuf[i];
        if(0x20 == c)
        {
            buf[iDest] = '+';
        }
        else if(/*strchr(speciaChar,c) ||*/ (c>='A'&&c<='Z') || (c>='a'&&c<='z') || (c>='0'&&c<='9'))
        {
            buf[iDest] = c;
        }
        //下面这句else多余
        else{
            sprintf((char*)&buf[iDest],"%%%02X",c);
            iDest +=2;
        }
    }
    
    if(iDest>assumLength)
    {
        goto fin;
    }
    //
    retString = [[NSString alloc]initWithCString:(char*)buf encoding:NSUTF8StringEncoding];
    
fin:
    if(inbuf)
        free(inbuf);
    
    if(buf)
        free(buf);
    
    return retString;
}

+ (NSData *)getFileDataWithPath:(NSString *)filePath
{
    NSData *data = nil;
    
    if ([filePath length] > 0)
    {
        data = [NSData dataWithContentsOfFile:filePath];
    }
    
    return data;
}

+ (NSData *)getDataFromUrl:(NSString *)aUrl
{
    //NSString *fileName, *fileExt, *filePath;
    NSString *filePath;
    if ([aUrl hasPrefix:@"file://"] == YES) {
        aUrl = [aUrl substringFromIndex: 7];
    }
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    
    filePath = [CommonFileFunc getFilePathWithFilePath:aUrl dirType:NSDocumentDirectory];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])//更新文件不在document里，去打包app路径读取默认配置文件
    {
        filePath = [NSString stringWithFormat: @"%@/%@", bundlePath, aUrl];
    }
    
    return [NSData dataWithContentsOfFile: filePath];
}

+ (NSData *)encryptDataFromUrl:(NSString*)aUrl{
    NSData * data = [self getDataFromUrl:aUrl];
    if(data == nil)
        return nil;
    
    return data;
}

+ (NSString*)encryptStringFromFileUrl:(NSString*)aUrl{
    NSData * data = [self encryptDataFromUrl:aUrl];
    if(data == nil)
    {
        return nil;
    }
    
    NSUInteger length = [data length];
    char * mem = (char*)malloc(length+1);
    if(mem == NULL)
    {
        return nil;
    }
    
    memcpy(mem,[data bytes],length);
    mem[length] = '\0';
    
    NSString * retString = [NSString stringWithCString:mem encoding:NSUTF8StringEncoding];
    free(mem);
    return retString;
}


#pragma mark- 获取沙盒内容

+ (NSString *)getFilePath:(NSString *)file
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSMutableString * filepath = [NSMutableString stringWithCapacity:10];
    [filepath appendString:documentsDirectory];
    [filepath appendString:@"/"];
    [filepath appendString:file];
    
    return filepath;
}

+ (NSString *)getFilePathWithFilePath:(NSString *)fileName
                              dirType:(NSSearchPathDirectory)dirType
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(dirType, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

+ (NSString *)getDocumentFilePath:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filepath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];
    return filepath;
}

+ (NSString *)getFilePathInDirector:(NSString *)directorPath fileName:(NSString *)fileName
{
    NSString *filePath = nil;
    NSFileManager *myFile = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL isExist = [myFile fileExistsAtPath:directorPath isDirectory:&isDir];
    BOOL bRet = YES;
    
    if (!isExist)
    {
        bRet = [myFile createDirectoryAtPath:directorPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (bRet)
        {
            filePath = [NSString stringWithFormat:@"%@/%@", directorPath, fileName];
        }
    }
    else
    {
        filePath = [NSString stringWithFormat:@"%@/%@", directorPath, fileName];
    }
    
    return filePath;
}

+ (NSString *)getLibraryCachesFilePath:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    NSString *filepath  = [NSString stringWithFormat:@"%@/%@", cachesDir, fileName];	
    return filepath;
}

+ (BOOL)checkDir:(NSString *)filepath
{
	NSFileManager * fm = [NSFileManager defaultManager];
	if (![fm fileExistsAtPath:filepath]) {
		NSError * err = nil;
		if (![fm createDirectoryAtPath:filepath withIntermediateDirectories:YES attributes:nil error:&err])
			return NO;
	}
	return YES;
}

+ (BOOL)removeFilePath:(NSString *)filepath
{
	NSError * err = nil;
	return [[NSFileManager defaultManager] removeItemAtPath:filepath error:&err];
}

+ (unsigned long long)fileSizeForDir:(NSString*)path
{
    unsigned long long size = 0;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSArray* array = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for(int i = 0; i<[array count]; i++)
    {
        NSString *fullPath = [path stringByAppendingPathComponent:[array objectAtIndex:i]];
        
        BOOL isDir;
        if ( !([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) )
        {
            NSDictionary *fileAttributeDic = [fileManager attributesOfItemAtPath:fullPath error:nil];
            size += fileAttributeDic.fileSize;
        }
        else
        {
            size += [self fileSizeForDir:fullPath];
        }
    }
    
#if ! __has_feature(objc_arc)
    [fileManager release];
#endif
    
    return size;
}

+ (unsigned long long)fileSizeForPath:(NSString *)path
{
    unsigned long long fileSizeBytes = 0;
    const char *filePath = [path UTF8String];
    FILE *file = fopen(filePath,"r");
    
    if (file > 0)
    {
        fseek(file, 0, SEEK_END);
        fileSizeBytes = ftell(file);
        fseek(file, 0, SEEK_SET);
        fclose(file);
    }
    return fileSizeBytes;
}

//+ (unsigned long long)fileSizeForPath:(NSString *)path
//{
//    unsigned long long fileSize = 0;
//    NSFileManager * filemanager = [[NSFileManager alloc] init];
//    
//    BOOL isDirectory;
//    
//    if([filemanager fileExistsAtPath:path isDirectory:&isDirectory])
//    {   
//        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
//        NSNumber *theFileSize = [attributes objectForKey:NSFileSize];
//        fileSize = [theFileSize unsignedLongLongValue];
//    }
//    
//    return fileSize;
//}

/**
 *  目录创建
 *
 *  @param directorPath 目录路径
 *
 *  @return 返回目录创建是否成功
 */
+ (BOOL)createDirector:(NSString *)directorPath
{
    NSFileManager *myFile = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL isExist    = [myFile fileExistsAtPath:directorPath isDirectory:&isDir];
    BOOL bRet       = isExist ? YES : NO;
    
    if (!isExist)
    {
        bRet = [myFile createDirectoryAtPath:directorPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return bRet;
}

/**
 *  将指定文件数据保存到指定目录
 *
 *  @param directorPath 目录路径
 *  @param fileName     文件名称
 *  @param data         数据文件
 *
 *  @return BOOL (文件保存是否成功)
 */
+ (BOOL)saveDataToDirector:(NSString *)directorPath fileName:(NSString *)fileName data:(NSData *)data
{
    BOOL retSaveStatus = NO;
    BOOL bRet = [CommonFileFunc createDirector:directorPath];

    if (bRet && data)
    {
        NSString *savePath = [NSString stringWithFormat:@"%@/%@", directorPath, fileName];
        retSaveStatus = [data writeToFile:savePath atomically:YES];
    }

    return retSaveStatus;
}

+ (BOOL)removeDirectory:(NSString *)directorPath
{
    NSFileManager *myFile = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL bRet = NO;

    BOOL isExist = [myFile fileExistsAtPath:directorPath isDirectory:&isDir];

    if (isExist)
    {
        bRet = [myFile removeItemAtPath:directorPath error:nil];
    }

    return bRet;
}

+ (BOOL)fileExistsAtPath:(NSString *)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (NSString *)getNetWorkingDataCaches:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES);
    NSString *cachesDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:KNetWorkCacheFile];
    [CommonFileFunc createDirector:cachesDir];
    
    NSString *filepath  = [NSString stringWithFormat:@"%@/%@", cachesDir, fileName];
    return filepath;
}

+ (void)clearLocalNetWorkingCachesData
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES);
    NSString *cachesDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:KNetWorkCacheFile];
    if ([CommonFileFunc fileExistsAtPath:cachesDir]) {
        [CommonFileFunc removeDirectory:cachesDir];
    }
}

+ (void)clearLocalNetWorkingCachesFile:(NSString *)fileName
{
    NSString *path = [[self class] getNetWorkingDataCaches:fileName];
    if ([CommonFileFunc fileExistsAtPath:path]) {
        [CommonFileFunc removeDirectory:path];
    }
}

#pragma mark - 文件属性数据
+ (id)fileAttributeWithFilePathAndType:(NSString *)filePath attributeType:(NSString *)attributeType
{
    NSFileManager *fileManager   = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:nil];
    
    if (fileAttributes != nil && [attributeType length] > 0) {
        return [fileAttributes objectForKey:attributeType];
    }
    else {
//        NSLog(@"Path (%@) is invalid.", filePath);
    }
    return nil;
}

+ (NSDate *)fileDateWithFilePathAndType:(NSString *)filePath dateType:(FileDateType)dateType
{
    NSString *dateTypeKey = dateType == FileDate_Creation ? NSFileCreationDate : NSFileModificationDate;
    return [CommonFileFunc fileAttributeWithFilePathAndType:filePath attributeType:dateTypeKey];
}

@end
