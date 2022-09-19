//
//  NSObject+KeyedArchiver.m
//  DzhProjectiPhone
//
//  Created by wolfstan on 15-1-5.
//  Copyright (c) 2015年 gw. All rights reserved.
//

#import "NSObject+KeyedArchiver.h"
#import "CommonFileFunc.h"

#define archiverFileDirectory  [CommonFileFunc getDocumentFilePath:@"KeyedArchiver"]

@implementation NSObject (KeyedArchiver)

- (BOOL)archiverObjectWithKey:(NSString *)key
{
    return [self archiverObjectWithKey:key directory:archiverFileDirectory];
}

- (BOOL)archiverObjectWithKey:(NSString *)key directory:(NSString *)directory
{
    if(![self conformsToProtocol:@protocol(NSCoding)])
    {
        return NO;
    }

    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:self];
    return [CommonFileFunc saveDataToDirector:directory fileName:key data:archiveData];
}

+ (id)unarchiverObjectWithKey:(NSString *)key
{
   return  [[self class]unarchiverObjectWithKey:key directory:archiverFileDirectory];
}

+ (id)unarchiverObjectWithKey:(NSString *)key directory:(NSString *)directory
{
    BOOL isDir = false;
    BOOL isExistArchiverDirectiory = [[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDir];
    if (isDir && isExistArchiverDirectiory)
    {
        id data = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSString stringWithFormat:@"%@/%@",directory,key]];
        return data;
    }
    
    return nil;
}

+ (BOOL)removeArchiverFileWithKey:(NSString *)key
{
    NSString *path = [NSString stringWithFormat:@"%@/%@",archiverFileDirectory,key];
    BOOL isExist   = [CommonFileFunc removeFilePath:path];
   return isExist;
}

+ (NSUInteger)fileSizeOfArchiverFileWithKey:(NSString *)key
{
    NSString *path = [NSString stringWithFormat:@"%@/%@",archiverFileDirectory,key];
    return (NSUInteger)[CommonFileFunc fileSizeForPath:path];
}

+ (NSDate *)fileCreationDateOfArchiverFileWithKey:(NSString *)key
{
    NSString *path = [NSString stringWithFormat:@"%@/%@",archiverFileDirectory,key];
    return [CommonFileFunc fileDateWithFilePathAndType:path dateType:FileDate_Creation];
}

+ (NSString *)fileOwnerOfArchiverFileWithKey:(NSString *)key
{
    NSString *path = [NSString stringWithFormat:@"%@/%@",archiverFileDirectory,key];
    return [CommonFileFunc fileAttributeWithFilePathAndType:path attributeType:NSFileOwnerAccountName];
}

+ (NSDate *)fileModificationDateOfArchiverFileWithKey:(NSString *)key
{
    NSString *path = [NSString stringWithFormat:@"%@/%@",archiverFileDirectory,key];
    return [CommonFileFunc fileDateWithFilePathAndType:path dateType:FileDate_Modification];
}
@end
