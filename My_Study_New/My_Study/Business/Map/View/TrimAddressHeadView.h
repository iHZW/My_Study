//
//  TrimAddressHeadView.h
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/6.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWBaseView.h"
#import "POIAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

@interface TrimAddressHeadView : ZWBaseView

- (void)updateTrimWithPois:(NSArray<POIAnnotation *> *)poiAnnotations ;

@end

NS_ASSUME_NONNULL_END
