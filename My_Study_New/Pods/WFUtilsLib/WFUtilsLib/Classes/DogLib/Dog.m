//
//  Dog.m
//  My_Study
//
//  Created by HZW on 2020/4/4.
//  Copyright © 2020 HZW. All rights reserved.
//

#import "Dog.h"

@implementation Dog

- (void)sendMessage:(NSString *)msg
{
    NSLog(@"dog_msg = %@", msg);
}

- (void)sendMessageName:(NSString *)msg age:(NSInteger)age
{
    NSLog(@"dog_msg = %@ age= %@", msg, @(age));
}

+ (void)sendClassMessage:(NSString *)msg
{
    NSLog(@"class_dog_msg = %@", msg);
}



@end
