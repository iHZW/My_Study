//
//  TrimAddressHeadView.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/6.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "TrimAddressHeadView.h"
#import "MapHeader.h"

@interface TrimAddressHeadView()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@end

@implementation TrimAddressHeadView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self loadSubViews];
    }
    return self;
}

- (void)loadSubViews
{
    
    [self addSubview:self.mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)updateTrimWithPois:(NSArray<POIAnnotation *> *)poiAnnotations {
//     /* 将结果以annotation的形式加载到地图上. */
     [self.mapView addAnnotations:poiAnnotations];

     /* 如果只有一个结果，设置其为中心点. */
     if (poiAnnotations.count == 1){
         [self.mapView setCenterCoordinate:[poiAnnotations[0] coordinate]];
     }
     /* 如果有多个结果, 设置地图使所有的annotation都可见. */
     else {
         [self.mapView showAnnotations:poiAnnotations animated:NO];
     }
}

#pragma mark - lazyLoad
- (MAMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MAMapView alloc] init];
        _mapView.delegate = self;
    }
    return _mapView;
}

#pragma mark - MAMapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[POIAnnotation class]])
    {
        static NSString *poiIdentifier = @"poiIdentifier";
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:poiIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:poiIdentifier];
            poiAnnotationView.image = [UIImage imageNamed:@"icon_map_location"];
            //设置中心点偏移，使得标注底部中间点成为经纬度对应点
            poiAnnotationView.centerOffset = CGPointMake(0, -18);
        }
//        poiAnnotationView.canShowCallout = YES;
        return poiAnnotationView;
    }

    return nil;
}

@end
