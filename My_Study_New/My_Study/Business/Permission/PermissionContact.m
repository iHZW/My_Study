//
//  PermissionContact.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/7.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "PermissionContact.h"
#import <Contacts/Contacts.h>

@implementation PermissionContact

- (BOOL)isAuthorized{
    return [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized;
}

- (BOOL)isDenied{
    CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    return authStatus == CNAuthorizationStatusDenied || authStatus == CNAuthorizationStatusRestricted;
}

- (void)request:(void (^)(void))block{
    if ([self isAuthorized] || [self isDenied]){
        BlockSafeRun(block);
    } else {
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                BlockSafeRun(block);
            });
        }];
    }
}

@end
