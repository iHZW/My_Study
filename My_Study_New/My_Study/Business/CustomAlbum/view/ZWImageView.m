//
//  ZWImageView.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWImageView.h"
#import "PHAssetModel.h"
#import "UIImage+GIF.h"
#import "ZWImageUtil.h"
#import "UIImageView+WebCache.h"


#define kScreenWidth self.frame.size.width
#define kScreenHeight self.frame.size.height

@interface ZWImageView ()<UIScrollViewDelegate>

@property (nonatomic ,strong) UIScrollView * scrVc;

@property (nonatomic ,strong) UIImageView * imageVc;

@property (nonatomic ,strong) UIActivityIndicatorView * indicatorView;

@property (nonatomic ,assign) CGRect locateZoomReact;

@end

@implementation ZWImageView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initViews];
    }
    return self;
}

- (void)initViews{
    _scrVc = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,kScreenWidth, kScreenHeight)];
    _scrVc.delegate = self;
    _scrVc.showsHorizontalScrollIndicator = NO;
    _scrVc.showsVerticalScrollIndicator = NO;
    _scrVc.scrollsToTop = NO;
    
    [_scrVc setMinimumZoomScale:1];
    [_scrVc setMaximumZoomScale:self.maxZoomScale ? self.maxZoomScale : 3];
    
    _imageVc = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _imageVc.backgroundColor = [UIColor blackColor];
    _imageVc.center = _scrVc.center;
    _imageVc.userInteractionEnabled = YES;
    _imageVc.contentMode = UIViewContentModeScaleAspectFit;
    
    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [_imageVc addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoomImageView:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [_imageVc addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    UILongPressGestureRecognizer * longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(LongTapAction:)];
    longTap.minimumPressDuration = 1.0f;
    [_imageVc addGestureRecognizer:longTap];
    
    [_scrVc addSubview:_imageVc];
    
    [self addSubview:_scrVc];
    
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _indicatorView.hidesWhenStopped = YES;
    _indicatorView.frame = CGRectMake(kScreenWidth / 2 - 15, kScreenHeight / 2 - 15, 30, 30);
    [self addSubview:_indicatorView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _scrVc.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    _imageVc.frame = CGRectMake(0, 0, kScreenWidth, [self getImageHeight] > kScreenHeight ? [self getImageHeight] : kScreenHeight);
    _scrVc.contentSize = self.imageVc.frame.size;
}

- (void)singleTapAction{
    if (self.tapAction) {
        self.tapAction();
    }
}

- (void)LongTapAction:(UILongPressGestureRecognizer *)longPress{
    if (longPress.state != UIGestureRecognizerStateBegan) return;
    if (self.longTapAction) {
        self.longTapAction(self.imageVc.image);
    }
}

- (void)zoomImageView:(UITapGestureRecognizer *)tap{
    CGFloat scale = self.scrVc.zoomScale == 1 ? 2 : 1;
    CGRect zoomRect = [self zoomRectForScale:scale withCenter:[tap locationInView:tap.view]];
    self.locateZoomReact = zoomRect;
    [self.scrVc zoomToRect:zoomRect animated:YES];
}

#pragma mark - other

- (void)resetScale{
    [_scrVc setZoomScale:1];
}

- (BOOL)isUrl:(NSString *)str{
    if ([str hasPrefix:@"http://"] || [str hasPrefix:@"https://"]) {
        return YES;
    }
    return NO;
}

- (CGFloat)getImageHeight{
    CGFloat ratio = _imageVc.image.size.height / _imageVc.image.size.width;
    CGFloat height = self.frame.size.width * ratio;
    return height;
}

- (void)loadUrlAndPath:(NSString *)str{
    if ([self isUrl:str]) {
        [self.indicatorView startAnimating];
        
        __weak ZWImageView * weakSelf = self;
        [self.imageVc sd_setImageWithURL:[NSURL URLWithString:str] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [weakSelf.indicatorView stopAnimating];
        }];
    }else{
        if ([str hasPrefix:@"file://"]) {
            str = [str substringFromIndex:7];
        }
        self.imageVc.image = [UIImage imageWithContentsOfFile:str];
    }
}

- (void)updateModel:(PHAssetModel *)data{
    PHAsset * asset = data.asset;
    if (!asset) {
        self.imageVc.image = data.originalImage;
        [self layoutSubviews];
    }else{
        [self update:asset];
    }
}

- (void)update:(PHAsset *)asset{
    if (asset.mediaType == PHAssetMediaTypeImage) {
        NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
        NSString *orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
        if ([orgFilename hasSuffix:@".gif"]) {
            __weak ZWImageView * weakSelf = self;
            [[ZWAlbumManager manager] originalGraphData:asset complete:^(NSData * _Nullable result) {
                weakSelf.imageVc.image = [UIImage sd_imageWithGIFData:result];
                [weakSelf layoutSubviews];
            }];
        }else{
            __weak ZWImageView * weakSelf = self;
            [[ZWAlbumManager manager] thumbnailPre:asset complete:^(UIImage * _Nonnull result) {
                weakSelf.imageVc.image = result;
                [weakSelf layoutSubviews];
            }];
        }
    }else if (asset.mediaType == PHAssetMediaTypeVideo){
        // 视频播放
        __weak ZWImageView * weakSelf = self;
         [[ZWAlbumManager manager] thumbnailPre:asset complete:^(UIImage * _Nonnull result) {
             weakSelf.imageVc.image = result;
             [weakSelf layoutSubviews];
         }];
    }
}

#pragma mark =======================缩放逻辑===============================

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center{
    CGRect zoomRect;
    zoomRect.size.height = kScreenHeight / scale;
    zoomRect.size.width  = kScreenWidth  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageVc;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGFloat contentWidth = kScreenWidth * scrollView.zoomScale;
    CGFloat imageContentHeight = [self getImageHeight] * scrollView.zoomScale;
    
    if (scrollView.zoomScale >= 1) {
        [UIView animateWithDuration:0.1f animations:^{
            self.imageVc.frame = CGRectMake(0, 0, contentWidth, imageContentHeight > kScreenHeight ? imageContentHeight : kScreenHeight);
            self.scrVc.contentSize = self.imageVc.frame.size;
        }];
    }else{
        if (self.imageVc.frame.size.height > kScreenHeight) {
            self.imageVc.center = CGPointMake(self.scrVc.center.x, self.scrVc.contentSize.height / 2);
        }else{
            self.imageVc.center = self.scrVc.center;
        }
    }
}


@end
