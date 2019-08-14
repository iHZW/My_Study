//
//  CommonFileFunc.h
//  --
//
//  Created by Howard Dong on 13-1-15.
//  Copyright (c) 2013年 -- All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, FileDateType)
{
    FileDate_Creation,
    FileDate_Modification,
};

@interface CommonFileFunc : NSObject

/**
 *  根据传入的相对路径，返回基于安装目录的绝对路径
 *
 */
+ (NSString *)getBundlePathWithFilePath:(NSString *)filePath;

/**
 *  //字母数字，以及特殊字符“$-_.+!*'(),”和用作保留目的的字符“;/?:@=&”可不进行编码,但经过网页测试，‘＋’，‘&‘两字符是应该转的
 *
 */
+ (NSString*)urlEncode:(NSString* )sSrc;

/**
 *  获取指定文件路径的二进制数据
 *
 *  @param filePath 文件路径
 */
+ (NSData *)getFileDataWithPath:(NSString *)filePath;

/**
 *  从沙盒或者bundle得到配置文件
 *
 */
+ (NSData *)getDataFromUrl:(NSString *)aUrl;

/**
 *  根据配置文件是否对getDataFromUrl获取的文件进行解密
 *
 */
+ (NSData *)encryptDataFromUrl:(NSString*)aUrl;

/**
 *  根据配置文件是否对getDataFromUrl获取的文件进行解密
 *
 */
+ (NSString*)encryptStringFromFileUrl:(NSString*)aUrl;

/**
 *   获取Document目录指定文件全路径
 */
+ (NSString *)getFilePath:(NSString *)file;

/**
 *  根据传入的相对路径，返回基于全局的关键目录的绝对路径
 *
 */
+ (NSString *)getFilePathWithFilePath:(NSString *)fileName
                              dirType:(NSSearchPathDirectory)dirType;

/**
 *  获取在Document目录下指定文件的全路径
 *
 *  @param fileName 指定文件名
 *
 *  @return 返回指定文件名的Document下的全路径
 */
+ (NSString *)getDocumentFilePath:(NSString *)fileName;

/**
 *  获取某个folder路径下的某个文件全路径，如果folder目录不存在则创建此目录
 *
 *  @param directorPath 目录路径
 *  @param fileName     文件名
 *
 *  @return 返回文件的全路径
 */
+ (NSString *)getFilePathInDirector:(NSString *)directorPath fileName:(NSString *)fileName;

/**
 *  获取在LibraryCaches目录下指定文件名的全路径
 *
 *  @param fileName 指定文件名
 *
 *  @return 返回指定文件名的LibraryCaches下的全路径
 */
+ (NSString *)getLibraryCachesFilePath:(NSString *)fileName;

/**
 *  检测指定路径文件夹是否存在
 *
 *  @param filepath 指定目录路径
 *
 *  @return BOOL(YES-存在， NO-不存在)
 */
+ (BOOL)checkDir:(NSString *)filepath;

/**
 *  删除指定路径的文件
 *
 *  @param filepath 文件路径
 *
 *  @return BOOL(删除文件状态YES-成功， NO-失败)
 */
+ (BOOL)removeFilePath:(NSString *)filepath;

/**
 *  获取某个目录下所有文件占用的空间大小
 *
 *  @param path 指定目录路径
 *
 *  @return unsigned long long(返回文件夹中文件大小, 单位byte)
 */
+ (unsigned long long)fileSizeForDir:(NSString*)path;

/**
 *  获取指定路径文件的大小
 *
 *  @param path 指定文件路径
 *
 *  @return unsigned long long(返回文件大小, 单位byte)
 */
+ (unsigned long long)fileSizeForPath:(NSString *)path;

/**
 *  目录创建
 *
 *  @param directorPath 目录路径
 *
 *  @return 返回目录创建是否成功
 */
+ (BOOL)createDirector:(NSString *)directorPath;

/**
 *  将指定文件数据保存到指定目录
 *
 *  @param directorPath 目录路径
 *  @param fileName     文件名称
 *  @param data         数据文件
 *
 *  @return BOOL (文件保存是否成功)
 */
+ (BOOL)saveDataToDirector:(NSString *)directorPath fileName:(NSString *)fileName data:(NSData *)data;

/**
 *  删除指定路径的目录
 *
 *  @param directorPath 目录路径
 *
 *  @return BOOL (删除文件目录是否成功)
 */
+ (BOOL)removeDirectory:(NSString *)directorPath;

/**
 *  文件是否存在
 *
 *  @param path 路径
 *
 *  @return 是否存在
 */
+ (BOOL)fileExistsAtPath:(NSString *)path;

/**
 *  网络缓存存放位置
 *
 *  @param fileName 文件名
 *
 *  @return 存放绝对路径
 */
+ (NSString *)getNetWorkingDataCaches:(NSString *)fileName;

#pragma mark - 文件属性数据
/**
 *  获取指定路径文件以及文件属性类型的数据
 *
 *  @param filePath      指定文件路径
 *  @param attributeType 文件属性类型
 *
 *  @return 队形属性对象
 */
+ (id)fileAttributeWithFilePathAndType:(NSString *)filePath attributeType:(NSString *)attributeType;

/**
 *  获取指定路径文件以及文件日期类型的日期
 *
 *  @param filePath 指定文件路径
 *  @param dateType 日期类型
 *
 *  @return 日期
 */
+ (NSDate *)fileDateWithFilePathAndType:(NSString *)filePath dateType:(FileDateType)dateType;

/**
 *  清理本地网络缓存
 */
+ (void)clearLocalNetWorkingCachesData;

/**
 *  清理本地网络缓存的某个文件
 */
+ (void)clearLocalNetWorkingCachesFile:(NSString *)fileName;

@end
