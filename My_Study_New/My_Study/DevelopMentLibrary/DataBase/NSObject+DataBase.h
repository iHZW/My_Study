//
//  NSObject+DataBase.h
//  StarterApp
//
//  Created by js on 2019/7/12.
//  Copyright © 2019 js. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataBase.h"
NS_ASSUME_NONNULL_BEGIN

@interface NSObject (DataBase)
@property (nonatomic, readonly, weak,class) DataBase *dataBase;
@end

NS_ASSUME_NONNULL_END
