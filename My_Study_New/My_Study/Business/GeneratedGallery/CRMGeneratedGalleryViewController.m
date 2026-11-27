#import "CRMGeneratedGalleryViewController.h"
@import ImageIO;

static UIColor *GalleryColor(NSUInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 255) / 255.0
                           green:((hex >> 8) & 255) / 255.0
                            blue:(hex & 255) / 255.0 alpha:1.0];
}

@interface CRMGeneratedAlbum : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray<CRMGeneratedAlbum *> *albums;
@property (nonatomic, copy) NSArray<NSURL *> *images;
@property (nonatomic, strong) NSURL *cover;
@property (nonatomic) NSUInteger imageCount;
- (instancetype)initWithFolder:(NSURL *)folder;
@end

@implementation CRMGeneratedAlbum

- (instancetype)initWithFolder:(NSURL *)folder {
    if (!(self = [super init])) return nil;

    _title = folder.lastPathComponent;
    NSArray *keys = @[NSURLIsDirectoryKey];
    NSArray<NSURL *> *entries = [[NSFileManager.defaultManager contentsOfDirectoryAtURL:folder
                                                            includingPropertiesForKeys:keys
                                                                               options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                 error:nil]
        sortedArrayUsingComparator:^NSComparisonResult(NSURL *first, NSURL *second) {
            return [first.lastPathComponent localizedStandardCompare:second.lastPathComponent];
        }];

    NSMutableArray<CRMGeneratedAlbum *> *albums = [NSMutableArray array];
    NSMutableArray<NSURL *> *images = [NSMutableArray array];
    NSSet *extensions = [NSSet setWithArray:@[@"jpg", @"jpeg", @"png"]];
    for (NSURL *entry in entries) {
        NSNumber *isDirectory = nil;
        [entry getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        if (isDirectory.boolValue) {
            CRMGeneratedAlbum *album = [[CRMGeneratedAlbum alloc] initWithFolder:entry];
            if (album.imageCount == 0) continue;
            [albums addObject:album];
            _imageCount += album.imageCount;
        } else if ([extensions containsObject:entry.pathExtension.lowercaseString]) {
            [images addObject:entry];
            _imageCount++;
        }
    }
    _albums = [albums copy];
    _images = [images copy];
    _cover = _images.firstObject ?: _albums.firstObject.cover;
    return self;
}

@end

static UIImage *GalleryThumbnail(NSURL *url) {
    static NSCache<NSURL *, UIImage *> *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
        cache.totalCostLimit = 24 * 1024 * 1024;
    });
    UIImage *cached = [cache objectForKey:url];
    if (cached) return cached;

    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (!source) return nil;
    NSDictionary *options = @{
        (__bridge NSString *)kCGImageSourceThumbnailMaxPixelSize: @480,
        (__bridge NSString *)kCGImageSourceCreateThumbnailFromImageAlways: @YES,
        (__bridge NSString *)kCGImageSourceCreateThumbnailWithTransform: @YES
    };
    CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef)options);
    CFRelease(source);
    if (!thumbnail) return nil;
    UIImage *image = [UIImage imageWithCGImage:thumbnail];
    size_t cost = CGImageGetBytesPerRow(thumbnail) * CGImageGetHeight(thumbnail);
    CGImageRelease(thumbnail);
    [cache setObject:image forKey:url cost:cost];
    return image;
}

@interface CRMGeneratedGalleryCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, strong) UILabel *caption;
@property (nonatomic, strong) NSLayoutConstraint *captionHeight;
@end

@implementation CRMGeneratedGalleryCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) return nil;

    self.contentView.backgroundColor = UIColor.whiteColor;
    self.contentView.layer.cornerRadius = 16;
    self.contentView.clipsToBounds = YES;
    self.isAccessibilityElement = YES;
    self.accessibilityTraits = UIAccessibilityTraitButton;

    _thumbnail = [[UIImageView alloc] init];
    _thumbnail.backgroundColor = GalleryColor(0xE8F3EF);
    _thumbnail.clipsToBounds = YES;
    _thumbnail.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_thumbnail];

    _caption = [[UILabel alloc] init];
    _caption.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    _caption.textColor = GalleryColor(0x294B46);
    _caption.numberOfLines = 2;
    _caption.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_caption];
    _captionHeight = [_caption.heightAnchor constraintEqualToConstant:0];

    [NSLayoutConstraint activateConstraints:@[
        [_thumbnail.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [_thumbnail.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [_thumbnail.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [_thumbnail.bottomAnchor constraintEqualToAnchor:_caption.topAnchor],
        [_caption.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:10],
        [_caption.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-10],
        [_caption.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
        _captionHeight,
    ]];
    return self;
}

@end

@interface CRMGeneratedImagePage : UIViewController <UIScrollViewDelegate>
@property (nonatomic) NSUInteger index;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation CRMGeneratedImagePage

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = GalleryColor(0x182725);

    UIImage *image = [UIImage imageWithContentsOfFile:self.imageURL.path];
    if (!image) {
        UILabel *message = [[UILabel alloc] initWithFrame:self.view.bounds];
        message.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        message.text = @"无法打开这张图片";
        message.textColor = UIColor.whiteColor;
        message.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:message];
        return;
    }

    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scroll.minimumZoomScale = 1;
    scroll.maximumZoomScale = 4;
    scroll.delegate = self;
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.showsVerticalScrollIndicator = NO;
    scroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.view addSubview:scroll];

    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.isAccessibilityElement = YES;
    self.imageView.accessibilityTraits = UIAccessibilityTraitImage;
    self.imageView.accessibilityLabel = [NSString stringWithFormat:@"第 %lu 张图片", (unsigned long)self.index + 1];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:self.imageView];
    [NSLayoutConstraint activateConstraints:@[
        [self.imageView.leadingAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.leadingAnchor],
        [self.imageView.trailingAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.trailingAnchor],
        [self.imageView.topAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.topAnchor],
        [self.imageView.bottomAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.bottomAnchor],
        [self.imageView.widthAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.widthAnchor],
        [self.imageView.heightAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.heightAnchor],
    ]];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end

@interface CRMGeneratedImageViewer : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (nonatomic, copy) NSArray<NSURL *> *images;
@property (nonatomic) NSUInteger initialIndex;
@end

@implementation CRMGeneratedImageViewer

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    [self setViewControllers:@[[self pageAtIndex:self.initialIndex]]
                   direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self updateTitle];
}

- (CRMGeneratedImagePage *)pageAtIndex:(NSUInteger)index {
    CRMGeneratedImagePage *page = [[CRMGeneratedImagePage alloc] init];
    page.index = index;
    page.imageURL = self.images[index];
    return page;
}

- (void)updateTitle {
    CRMGeneratedImagePage *page = (CRMGeneratedImagePage *)self.viewControllers.firstObject;
    self.navigationItem.title = [NSString stringWithFormat:@"%lu / %lu",
                                 (unsigned long)page.index + 1, (unsigned long)self.images.count];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(CRMGeneratedImagePage *)page {
    return page.index > 0 ? [self pageAtIndex:page.index - 1] : nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(CRMGeneratedImagePage *)page {
    return page.index + 1 < self.images.count ? [self pageAtIndex:page.index + 1] : nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) [self updateTitle];
}

@end

@interface CRMGeneratedGalleryViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) CRMGeneratedAlbum *album;
@property (nonatomic, strong) UICollectionView *collection;
@end

@implementation CRMGeneratedGalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!self.album) {
        NSURL *folder = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"GeneratedGallery" isDirectory:YES];
        self.album = [[CRMGeneratedAlbum alloc] initWithFolder:folder];
        self.title = @"图片作品集";
    }
    self.view.backgroundColor = GalleryColor(0xF4F7F5);
    if (self.album.imageCount == 0) {
        UILabel *empty = [[UILabel alloc] initWithFrame:self.view.bounds];
        empty.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        empty.text = @"暂无图片";
        empty.textColor = GalleryColor(0x607C76);
        empty.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:empty];
        return;
    }

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(16, 18, 10, 18);
    layout.minimumInteritemSpacing = 12;
    layout.minimumLineSpacing = 12;
    self.collection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collection.backgroundColor = self.view.backgroundColor;
    self.collection.alwaysBounceVertical = YES;
    self.collection.dataSource = self;
    self.collection.delegate = self;
    self.collection.translatesAutoresizingMaskIntoConstraints = NO;
    [self.collection registerClass:CRMGeneratedGalleryCell.class forCellWithReuseIdentifier:@"Gallery"];
    [self.view addSubview:self.collection];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.collection.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [self.collection.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor],
        [self.collection.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor],
        [self.collection.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor],
    ]];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView { return 2; }

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return section == 0 ? self.album.albums.count : self.album.images.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout
   sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat availableWidth = MAX(1, CGRectGetWidth(collectionView.bounds) - 36);
    NSInteger columns = availableWidth >= 620 ? 4 : 2;
    CGFloat width = MAX(1, floor((availableWidth - (columns - 1) * 12) / columns));
    return CGSizeMake(width, indexPath.section == 0 ? width + 50 : ceil(width * 1.3));
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CRMGeneratedGalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Gallery" forIndexPath:indexPath];
    BOOL isAlbum = indexPath.section == 0;
    if (isAlbum) {
        CRMGeneratedAlbum *album = self.album.albums[indexPath.item];
        cell.thumbnail.image = GalleryThumbnail(album.cover);
        cell.caption.text = album.title;
        cell.accessibilityLabel = [NSString stringWithFormat:@"%@，%lu 张图片", album.title, (unsigned long)album.imageCount];
    } else {
        NSURL *image = self.album.images[indexPath.item];
        cell.thumbnail.image = GalleryThumbnail(image);
        cell.caption.text = nil;
        cell.accessibilityLabel = [NSString stringWithFormat:@"第 %ld 张图片", (long)indexPath.item + 1];
    }
    cell.thumbnail.contentMode = isAlbum ? UIViewContentModeScaleAspectFill : UIViewContentModeScaleAspectFit;
    cell.captionHeight.constant = isAlbum ? 50 : 0;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        CRMGeneratedGalleryViewController *controller = [[CRMGeneratedGalleryViewController alloc] init];
        controller.album = self.album.albums[indexPath.item];
        controller.title = controller.album.title;
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    CRMGeneratedImageViewer *viewer = [[CRMGeneratedImageViewer alloc]
        initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    viewer.images = self.album.images;
    viewer.initialIndex = indexPath.item;
    [self.navigationController pushViewController:viewer animated:YES];
}

@end
