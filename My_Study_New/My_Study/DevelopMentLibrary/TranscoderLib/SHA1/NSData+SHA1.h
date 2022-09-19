//
//  NSData+SHA1.h
//  TZYJ_IPhone
//
//  Created by Howard on 15/9/8.
//
//

#import <Foundation/Foundation.h>


@interface NSData (SHA1)

unsigned char *SHA1Encoding(const void *data, NSUInteger len, unsigned char *md);


@end
