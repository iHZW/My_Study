//
//  LocationAuthority.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/6.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "LocationAuthority.h"
#import "MapHeader.h"
#import "UIApplication+Ext.h"

@implementation LocationAuthority

+ (BOOL)determineWhetherTheAPPOpensTheLocation {
    if ([CLLocationManager locationServicesEnabled] &&
        ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
         [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined ||
         [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)){
         return YES;
    }else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
       return NO;
    }else {
        return NO;
    }
}

+ (void)showActionView {
    [self _showActionView:YES];
}

+ (void)showActionViewWithNoPop{
    [self _showActionView:NO];
}


+ (void)_showActionView:(BOOL)cancelPop {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"当前应用位置权限未开启，是否前往开启？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        if (cancelPop){
            [[UIApplication displayViewController].navigationController popViewControllerAnimated:YES];
        }
    }];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"前往开启" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
         
    [alertController addAction:cancelAction];
    [alertController addAction:action];
    
    [[UIApplication displayViewController] presentViewController:alertController animated:YES completion:nil];
}


@end
