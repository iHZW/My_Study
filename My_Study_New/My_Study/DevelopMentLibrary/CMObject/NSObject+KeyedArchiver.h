//
//  NSObject+KeyedArchiver.h
//  DzhProjectiPhone
//
//  Created by wolfstan on 15-1-5.
//  Copyright (c) 2015年 gw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (KeyedArchiver)

- (BOOL)archiverObjectWithKey:(NSString *)key;

- (BOOL)archiverObjectWithKey:(NSString *)key directory:(NSString *)directory;

+ (id)unarchiverObjectWithKey:(NSString *)key;

+ (id)unarchiverObjectWithKey:(NSString *)key directory:(NSString *)directory;

+ (BOOL)removeArchiverFileWithKey:(NSString *)key;

+ (NSUInteger)fileSizeOfArchiverFileWithKey:(NSString *)key;

+ (NSDate *)fileCreationDateOfArchiverFileWithKey:(NSString *)key;

+ (NSString *)fileOwnerOfArchiverFileWithKey:(NSString *)key;

+ (NSDate *)fileModificationDateOfArchiverFileWithKey:(NSString *)key;

@end
