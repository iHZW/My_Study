//
//  URLUtil.h
//  CRM
//
//  Created by js on 2021/12/10.
//  Copyright © 2021 CRM. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface URLUtil : NSObject
+(nullable NSURL *)formateToGetURL:(NSString *)urlString;

+ (NSURL *)createGETURLFromString:(NSString *)urlString params:(NSDictionary *)params;
@end

NS_ASSUME_NONNULL_END
