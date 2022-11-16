//
//  HtmlBuilder.m
//  My_Study
//
//  Created by hzw on 2022/11/16.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "HtmlBuilder.h"

@interface HtmlBuilder ()

@property (nonatomic, strong) NSMutableString *mutString;

@end

@implementation HtmlBuilder

+ (instancetype)instance {
    HtmlBuilder *_instance = [[HtmlBuilder alloc] init];
    return _instance;
}

- (instancetype)start {
    self.mutString = [NSMutableString string];
    return self;
}
/**
 *  添加 <${tag}
 */
- (instancetype)beginTag:(NSString *)tag {
    [self.mutString appendString:@"<"];
    [self.mutString appendString:tag];
    return self;
}

/**
 *  添加 </${tag}>
 */
- (instancetype)endTag:(NSString *)tag {
    [self.mutString appendString:@"</"];
    [self.mutString appendString:tag];
    [self.mutString appendString:@">"];
    return self;
}

/**
 *  添加 key=value
 */
- (instancetype)attachProperty:(NSString *)value forKey:(NSString *)key {
    [self.mutString appendString:[NSString stringWithFormat:@" %@=%@", key, value]];
    return self;
}

/**
 *  添加 >text
 */
- (instancetype)setInnerText:(NSString *)text {
    [self.mutString appendString:@">"];
    [self.mutString appendString:text];
    return self;
}

- (instancetype)appendText:(NSString *)text {
    [self.mutString appendString:text];
    return self;
}

/**
 *生成html 字符串
 */
- (NSString *)build {
    return self.mutString;
}

@end
