//
//  ZWAlbumCropViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/7/11.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ZWAlbumCropViewController.h"
#import "PHAssetModel.h"
#import "ZWAlbumManager.h"
#import "ZWButton.h"
#import "ZWCropButtonView.h"
#import "UIImage+GIF.h"
#import "ZWImageUtil.h"

#define kScaneWidth 300


@interface ZWAlbumCropViewController ()<UIScrollViewDelegate>

@property (nonatomic ,strong) UIScrollView * scrVc;

@property (nonatomic ,strong) UIImageView * imageVc;

@property (nonatomic ,assign) CGFloat originX;

@property (nonatomic ,assign) CGFloat originY;

@end

@implementation ZWAlbumCropViewController

- (void)loadUIData
{
    [super loadUIData];
    
    [self loadSubViews];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)loadSubViews
{
    _scrVc = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _scrVc.backgroundColor = [UIColor blackColor];
    _scrVc.delegate = self;
    _scrVc.showsHorizontalScrollIndicator = NO;
    _scrVc.showsVerticalScrollIndicator = NO;
    _scrVc.scrollsToTop = NO;
    if (@available(iOS 11.0, *)) {
        _scrVc.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [_scrVc setMinimumZoomScale:1];
    [_scrVc setMaximumZoomScale:5];
    [self.view addSubview:_scrVc];
    
    _imageVc = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    _imageVc.backgroundColor = [UIColor blackColor];
    _imageVc.center = _scrVc.center;
    _imageVc.userInteractionEnabled = YES;
    _imageVc.contentMode = UIViewContentModeScaleAspectFit;
    [_scrVc addSubview:_imageVc];
    
    self.originX = (self.view.frame.size.width - kScaneWidth) / 2;
    self.originY = (self.view.frame.size.height - kScaneWidth * [ZWAlbumManager manager].cropRatio) / 2;

    [self userInterface];
    
    ZWCropButtonView * button = [[ZWCropButtonView alloc]initWithFrame:CGRectMake(0, kMainScreenHeight -  SafeAreaBottomAreaHeight - 45, kMainScreenWidth, 45 + SafeAreaBottomAreaHeight)];
    __weak ZWAlbumCropViewController * weakSelf = self;
    [button setButtonHander:^(NSInteger idx) {
        if (idx == 0) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            [weakSelf cropImage];
        }
    }];
    [self.view addSubview:button];
    
    [self update:self.data];
}

- (void)userInterface {
    CGRect cropframe = CGRectMake(self.originX, self.originY, kScaneWidth, kScaneWidth * [ZWAlbumManager manager].cropRatio);
    
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-1, -1, self.view.frame.size.width + 2, self.view.frame.size.height + 2) cornerRadius:0];
    UIBezierPath * cropPath = [UIBezierPath bezierPathWithRect:cropframe];
    [path appendPath:cropPath];
    
    CAShapeLayer * layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [UIColor colorWithRed:.0 green:.0 blue:.0 alpha:0.5].CGColor;
    layer.lineWidth = 1.0f;
    layer.strokeColor = [UIColor whiteColor].CGColor;
    //填充规则
    layer.fillRule = kCAFillRuleEvenOdd;
    layer.path = path.CGPath;
    [self.view.layer addSublayer:layer];
}

- (void)updateLayout{
    if (!_imageVc.image) {
        return;
    }
    CGFloat imgWid = _imageVc.image.size.width;
    CGFloat imgHei = _imageVc.image.size.height;

    CGFloat hwRatio = imgHei / imgWid;
    CGFloat whRatio = imgWid / imgHei;

    if (imgWid > imgHei) {
        CGFloat width = kScaneWidth * [ZWAlbumManager manager].cropRatio * whRatio;
        CGFloat height = kScaneWidth * [ZWAlbumManager manager].cropRatio;
        if (width >= kScaneWidth && height >= kScaneWidth * [ZWAlbumManager manager].cropRatio) {
//            _imageVc.frame = CGRectMake(self.originX,self.originY, width, height);
        }else{
            CGFloat widScale = kScaneWidth / width;
            CGFloat heiScale = kScaneWidth * [ZWAlbumManager manager].cropRatio / height;
            CGFloat scale = widScale > height ? widScale : heiScale;
            height = height * scale;
            width = width * scale;
        }
        _imageVc.frame = CGRectMake(self.originX,self.originY, width, height);
        _scrVc.contentSize = CGSizeMake(width + self.originX * 2 + 0.5, height + self.originY * 2 + 0.5);
        _scrVc.contentOffset = CGPointMake((_scrVc.contentSize.width - self.view.frame.size.width) / 2, (_scrVc.contentSize.height - self.view.frame.size.height) / 2);
    }else{
        CGFloat width = kScaneWidth;
        CGFloat height = kScaneWidth * hwRatio;
        if (width >= kScaneWidth && height >= kScaneWidth * [ZWAlbumManager manager].cropRatio) {
//            _imageVc.frame = CGRectMake(self.originX,self.originY, width, height);
        }else{
            CGFloat widScale = kScaneWidth / width;
            CGFloat heiScale = kScaneWidth * [ZWAlbumManager manager].cropRatio / height;
            CGFloat scale = widScale > height ? widScale : heiScale;
            height = height * scale;
            width = width * scale;
        }
        _imageVc.frame = CGRectMake(self.originX,self.originY, width, height);
        _scrVc.contentSize = CGSizeMake(width + self.originX * 2 + 0.5, height + self.originY * 2 + 0.5);
        _scrVc.contentOffset = CGPointMake((_scrVc.contentSize.width - self.view.frame.size.width) / 2, (_scrVc.contentSize.height - self.view.frame.size.height) / 2);
    }
}

- (void)compressImage:(UIImage *)image{
    __weak ZWAlbumCropViewController * weakSelf = self;
    [ZWImageUtil compressedImage:image maxSize:1000 complete:^(UIImage * _Nonnull img, NSData * _Nullable data) {
        weakSelf.imageVc.image = img;
        [weakSelf updateLayout];
    }];
}

- (void)cropImage{
    CGFloat ratio = _imageVc.image.size.width * self.scrVc.zoomScale / _imageVc.frame.size.width;
    
    CGFloat width = kScaneWidth / self.scrVc.zoomScale * ratio;
    CGFloat height = kScaneWidth * [ZWAlbumManager manager].cropRatio / self.scrVc.zoomScale * ratio;
    CGFloat originX = _scrVc.contentOffset.x / self.scrVc.zoomScale * ratio;
    CGFloat originY = _scrVc.contentOffset.y / self.scrVc.zoomScale * ratio;
    
    CGImageRef imageRef =CGImageCreateWithImageInRect([_imageVc.image CGImage],CGRectMake(originX, originY, width, height));
    UIImage * image = [[UIImage alloc]initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    PHAssetModel * model = [[PHAssetModel alloc]init];
    model.asset = self.data.asset;
    model.cropImage = image;
    model.originalImage = self.data.originalImage;
    
    __weak ZWAlbumCropViewController * weakSelf = self;
    [ZWImageUtil configPathWithModel:@[model] complete:^(NSArray<PHAssetModel *> * _Nonnull arr) {
        BlockSafeRun([ZWAlbumManager manager].selectImageComplete,arr,YES);
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)update:(PHAssetModel *)data{
    PHAsset * asset = data.asset;
    if (!asset) {
        [self compressImage:data.originalImage];
    }else{
        if (asset.mediaType == PHAssetMediaTypeImage) {
            NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
            NSString *orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
            if ([orgFilename hasSuffix:@".gif"]) {
                __weak ZWAlbumCropViewController * weakSelf = self;
                [[ZWAlbumManager manager] originalGraphData:asset complete:^(NSData * _Nullable result) {
                    weakSelf.imageVc.image = [UIImage sd_imageWithGIFData:result];
                    [weakSelf updateLayout];
                }];
            }else{
                __weak ZWAlbumCropViewController * weakSelf = self;
                [[ZWAlbumManager manager] thumbnailPre:asset complete:^(UIImage * _Nonnull result) {
                    weakSelf.imageVc.image = result;
                    [weakSelf updateLayout];
                }];
            }
        }
    }
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageVc;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    scrollView.contentSize = CGSizeMake(_imageVc.frame.size.width + 2 * self.originX, _imageVc.frame.size.height + 2 * self.originY);
}


@end
