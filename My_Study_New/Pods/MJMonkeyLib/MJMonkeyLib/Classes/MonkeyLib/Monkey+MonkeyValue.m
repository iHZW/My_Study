//
//  Monkey+MonkeyValue.m
//  MJMonkeyLib
//
//  Created by HZW on 2020/4/5.
//

#import "Monkey+MonkeyValue.h"
#import <objc/runtime.h>

static const char tempValueKey;

@implementation Monkey (MonkeyValue)

- (void)configWithName:(NSString *)name
{
    objc_setAssociatedObject(self, _cmd, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
    NSString *value = objc_getAssociatedObject(self, _cmd);
    NSLog(@"value = %@", value);
}

@end
