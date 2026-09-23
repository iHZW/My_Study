//
//  CRMViewController.m
//  My_Study
//
//  第四个 Tab 的发现内容页。
//

#import "CRMViewController.h"
#import "CRMFeedDetailViewController.h"
#import <QuartzCore/QuartzCore.h>

static UIColor *CRMColor(NSUInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 0xff) / 255.0
                           green:((hex >> 8) & 0xff) / 255.0
                            blue:(hex & 0xff) / 255.0 alpha:1];
}

@interface CRMFeedItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *likes;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic, strong) UIColor *endColor;
@property (nonatomic, assign) CGFloat imageRatio;
@property (nonatomic, assign) BOOL video;
- (NSDictionary *)detailInfo;
@end

@implementation CRMFeedItem

- (NSDictionary *)detailInfo {
    return @{
        @"title": self.title ?: @"",
        @"author": self.author ?: @"",
        @"likes": self.likes ?: @"",
        @"tag": self.tag ?: @"",
        @"startColor": self.startColor ?: CRMColor(0x79D5FF),
        @"endColor": self.endColor ?: CRMColor(0xFFC857),
        @"video": @(self.video)
    };
}
@end

@class CRMFeedLayout;
@protocol CRMFeedLayoutDelegate <NSObject>
- (CGFloat)feedLayout:(CRMFeedLayout *)layout heightForItemAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)itemWidth;
@end

@interface CRMFeedLayout : UICollectionViewLayout
@property (nonatomic, weak) id<CRMFeedLayoutDelegate> delegate;
@property (nonatomic, strong) NSArray<UICollectionViewLayoutAttributes *> *attributes;
@property (nonatomic, assign) CGSize layoutContentSize;
@end

@implementation CRMFeedLayout

- (void)prepareLayout {
    [super prepareLayout];
    CGFloat width = CGRectGetWidth(self.collectionView.bounds);
    CGFloat inset = 10, spacing = 10;
    CGFloat itemWidth = floor((width - 2 * inset - spacing) / 2);
    CGFloat columnBottoms[2] = {inset, inset};
    NSMutableArray *attributes = [NSMutableArray array];
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger index = 0; index < count; index++) {
        NSInteger column = columnBottoms[0] <= columnBottoms[1] ? 0 : 1;
        NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
        CGFloat height = [self.delegate feedLayout:self heightForItemAtIndexPath:path itemWidth:itemWidth];
        UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
        attribute.frame = CGRectMake(inset + column * (itemWidth + spacing), columnBottoms[column], itemWidth, height);
        [attributes addObject:attribute];
        columnBottoms[column] += height + spacing;
    }
    self.attributes = attributes;
    self.layoutContentSize = CGSizeMake(width, MAX(columnBottoms[0], columnBottoms[1]) + inset);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *visible = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *attribute in self.attributes) {
        if (CGRectIntersectsRect(rect, attribute.frame)) [visible addObject:attribute];
    }
    return visible;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.item < self.attributes.count ? self.attributes[indexPath.item] : nil;
}

- (CGSize)collectionViewContentSize { return self.layoutContentSize; }
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return CGRectGetWidth(newBounds) != CGRectGetWidth(self.collectionView.bounds);
}
@end

@interface CRMFeedCell : UICollectionViewCell
@property (nonatomic, strong) UIView *cover;
@property (nonatomic, strong) CAGradientLayer *gradient;
@property (nonatomic, strong) UILabel *coverSymbol;
@property (nonatomic, strong) UILabel *tagLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, assign) CGFloat imageRatio;
- (void)configureWithItem:(CRMFeedItem *)item;
@end

@implementation CRMFeedCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    self.contentView.backgroundColor = UIColor.whiteColor;
    self.contentView.layer.cornerRadius = 13;
    self.contentView.layer.masksToBounds = YES;
    self.cover = [[UIView alloc] init];
    self.cover.clipsToBounds = YES;
    [self.contentView addSubview:self.cover];
    self.gradient = [CAGradientLayer layer];
    self.gradient.startPoint = CGPointMake(0, 0);
    self.gradient.endPoint = CGPointMake(1, 1);
    [self.cover.layer addSublayer:self.gradient];
    self.coverSymbol = [[UILabel alloc] init];
    self.coverSymbol.font = [UIFont systemFontOfSize:45 weight:UIFontWeightLight];
    self.coverSymbol.textColor = [UIColor colorWithWhite:1 alpha:0.85];
    self.coverSymbol.textAlignment = NSTextAlignmentCenter;
    [self.cover addSubview:self.coverSymbol];
    self.tagLabel = [[UILabel alloc] init];
    self.tagLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightSemibold];
    self.tagLabel.textColor = UIColor.whiteColor;
    self.tagLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.20];
    self.tagLabel.textAlignment = NSTextAlignmentCenter;
    self.tagLabel.layer.cornerRadius = 9;
    self.tagLabel.layer.masksToBounds = YES;
    [self.cover addSubview:self.tagLabel];
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    self.titleLabel.textColor = CRMColor(0x303A3A);
    [self.contentView addSubview:self.titleLabel];
    self.authorLabel = [[UILabel alloc] init];
    self.authorLabel.font = [UIFont systemFontOfSize:11];
    self.authorLabel.textColor = CRMColor(0x999999);
    [self.contentView addSubview:self.authorLabel];
    self.likesLabel = [[UILabel alloc] init];
    self.likesLabel.font = [UIFont systemFontOfSize:11];
    self.likesLabel.textColor = CRMColor(0x999999);
    self.likesLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.likesLabel];
    return self;
}

- (void)configureWithItem:(CRMFeedItem *)item {
    self.imageRatio = item.imageRatio;
    self.gradient.colors = @[(__bridge id)item.startColor.CGColor, (__bridge id)item.endColor.CGColor];
    self.coverSymbol.text = item.video ? @"▷" : @"✦";
    self.tagLabel.text = [NSString stringWithFormat:@" %@ ", item.tag];
    self.titleLabel.text = item.title;
    self.authorLabel.text = item.author;
    self.likesLabel.text = [NSString stringWithFormat:@"♡ %@", item.likes];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.contentView.bounds);
    CGFloat coverHeight = floor(width * MAX(0.72, self.imageRatio));
    self.cover.frame = CGRectMake(0, 0, width, coverHeight);
    self.gradient.frame = self.cover.bounds;
    self.coverSymbol.frame = self.cover.bounds;
    self.tagLabel.frame = CGRectMake(8, 8, MIN(width - 16, 65), 19);
    self.titleLabel.frame = CGRectMake(8, coverHeight + 7, width - 16, 39);
    self.authorLabel.frame = CGRectMake(8, CGRectGetHeight(self.contentView.bounds) - 25, width * 0.56, 17);
    self.likesLabel.frame = CGRectMake(width * 0.55, CGRectGetMinY(self.authorLabel.frame), width * 0.40, 17);
}
@end

@interface CRMViewController () <UICollectionViewDataSource, UICollectionViewDelegate, CRMFeedLayoutDelegate>
@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIScrollView *mainTabScrollView;
@property (nonatomic, strong) UIScrollView *subTabScrollView;
@property (nonatomic, strong) UIView *mainIndicatorView;
@property (nonatomic, strong) UIView *subIndicatorView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<UIButton *> *mainTabButtons;
@property (nonatomic, strong) NSArray<UIButton *> *subTabButtons;
@property (nonatomic, strong) NSArray<CRMFeedItem *> *feedItems;
@property (nonatomic, assign) NSInteger selectedMainIndex;
@property (nonatomic, assign) NSInteger selectedSubIndex;
@end

@implementation CRMViewController

+ (NSDictionary *)ss_constantParams {
    return @{@"hideNavigationBar": @(YES)};
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = CRMColor(0xF6F6F6);
    self.selectedMainIndex = 1;
    self.selectedSubIndex = 0;
    [self setupViews];
    [self buildFeedData];
    [self updateTabsAnimated:NO];
}

- (void)setupViews {
    self.topBar = [[UIView alloc] init];
    self.topBar.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.topBar];
    self.mainTabScrollView = [[UIScrollView alloc] init];
    self.mainTabScrollView.showsHorizontalScrollIndicator = NO;
    [self.topBar addSubview:self.mainTabScrollView];
    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeSystem];
    messageButton.tag = 100;
    messageButton.titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightLight];
    [messageButton setTitle:@"○" forState:UIControlStateNormal];
    [messageButton setTitleColor:CRMColor(0x333333) forState:UIControlStateNormal];
    [self.topBar addSubview:messageButton];
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    searchButton.tag = 101;
    searchButton.titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightLight];
    [searchButton setTitle:@"⌕" forState:UIControlStateNormal];
    [searchButton setTitleColor:CRMColor(0x333333) forState:UIControlStateNormal];
    [self.topBar addSubview:searchButton];
    NSArray *mainTitles = @[@"关注", @"发现", @"世界杯", @"宁波"];
    NSMutableArray *mainButtons = [NSMutableArray array];
    for (NSInteger index = 0; index < mainTitles.count; index++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tag = index;
        button.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
        [button setTitle:mainTitles[index] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(mainTabAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainTabScrollView addSubview:button];
        [mainButtons addObject:button];
    }
    self.mainTabButtons = mainButtons;
    self.mainIndicatorView = [[UIView alloc] init];
    self.mainIndicatorView.backgroundColor = CRMColor(0xFF3850);
    self.mainIndicatorView.layer.cornerRadius = 2;
    [self.mainTabScrollView addSubview:self.mainIndicatorView];

    self.subTabScrollView = [[UIScrollView alloc] init];
    self.subTabScrollView.backgroundColor = UIColor.whiteColor;
    self.subTabScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.subTabScrollView];
    NSArray *subTitles = @[@"推荐", @"RED", @"直播", @"短剧", @"美食", @"穿搭", @"壁纸", @"旅行", @"科技"];
    NSMutableArray *subButtons = [NSMutableArray array];
    for (NSInteger index = 0; index < subTitles.count; index++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tag = index;
        button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        [button setTitle:subTitles[index] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(subTabAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.subTabScrollView addSubview:button];
        [subButtons addObject:button];
    }
    self.subTabButtons = subButtons;
    self.subIndicatorView = [[UIView alloc] init];
    self.subIndicatorView.backgroundColor = CRMColor(0xFF3850);
    self.subIndicatorView.layer.cornerRadius = 1.5;
    [self.subTabScrollView addSubview:self.subIndicatorView];

    CRMFeedLayout *layout = [[CRMFeedLayout alloc] init];
    layout.delegate = self;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = CRMColor(0xF6F6F6);
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[CRMFeedCell class] forCellWithReuseIdentifier:@"CRMFeedCell"];
    [self.view addSubview:self.collectionView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat topInset = self.view.safeAreaInsets.top;
    self.topBar.frame = CGRectMake(0, topInset, width, 56);
    [self.topBar viewWithTag:100].frame = CGRectMake(14, 6, 44, 44);
    [self.topBar viewWithTag:101].frame = CGRectMake(width - 58, 6, 44, 44);
    self.mainTabScrollView.frame = CGRectMake(66, 0, width - 124, 56);
    CGFloat x = 4;
    for (UIButton *button in self.mainTabButtons) {
        CGFloat buttonWidth = MAX(68, [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font}].width + 24);
        button.frame = CGRectMake(x, 0, buttonWidth, 52);
        x += buttonWidth + 4;
    }
    self.mainTabScrollView.contentSize = CGSizeMake(MAX(width - 124, x), 56);
    self.subTabScrollView.frame = CGRectMake(0, CGRectGetMaxY(self.topBar.frame), width, 44);
    x = 12;
    for (UIButton *button in self.subTabButtons) {
        CGFloat buttonWidth = MAX(56, [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font}].width + 22);
        button.frame = CGRectMake(x, 0, buttonWidth, 41);
        x += buttonWidth + 2;
    }
    self.subTabScrollView.contentSize = CGSizeMake(x + 12, 44);
    self.collectionView.frame = CGRectMake(0, CGRectGetMaxY(self.subTabScrollView.frame), width, CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.subTabScrollView.frame));
    [self updateIndicatorsAnimated:NO];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)mainTabAction:(UIButton *)sender {
    if (self.selectedMainIndex == sender.tag) return;
    self.selectedMainIndex = sender.tag;
    self.selectedSubIndex = 0;
    [self updateTabsAnimated:YES];
    [self buildFeedData];
}

- (void)subTabAction:(UIButton *)sender {
    if (self.selectedSubIndex == sender.tag) return;
    self.selectedSubIndex = sender.tag;
    [self updateTabsAnimated:YES];
    [self buildFeedData];
}

- (void)updateTabsAnimated:(BOOL)animated {
    [self.mainTabButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger index, BOOL *stop) {
        BOOL selected = index == self.selectedMainIndex;
        button.titleLabel.font = [UIFont systemFontOfSize:selected ? 20 : 18 weight:selected ? UIFontWeightBold : UIFontWeightMedium];
        [button setTitleColor:selected ? CRMColor(0x292929) : CRMColor(0x999999) forState:UIControlStateNormal];
    }];
    [self.subTabButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger index, BOOL *stop) {
        BOOL selected = index == self.selectedSubIndex;
        [button setTitleColor:selected ? CRMColor(0x292929) : CRMColor(0x999999) forState:UIControlStateNormal];
    }];
    [self updateIndicatorsAnimated:animated];
}

- (void)updateIndicatorsAnimated:(BOOL)animated {
    UIButton *main = self.mainTabButtons[self.selectedMainIndex];
    UIButton *sub = self.subTabButtons[self.selectedSubIndex];
    void (^changes)(void) = ^{
        self.mainIndicatorView.frame = CGRectMake(CGRectGetMidX(main.frame) - 15, 52, 30, 4);
        self.subIndicatorView.frame = CGRectMake(CGRectGetMidX(sub.frame) - 14, 41, 28, 3);
    };
    if (animated) [UIView animateWithDuration:0.22 animations:changes];
    else changes();
    [self.mainTabScrollView scrollRectToVisible:CGRectInset(main.frame, -20, 0) animated:animated];
    [self.subTabScrollView scrollRectToVisible:CGRectInset(sub.frame, -20, 0) animated:animated];
}

- (void)buildFeedData {
    NSArray<NSString *> *titles = @[
        @"把平凡的日子过成喜欢的样子", @"周末去看一场落日吧", @"这份治愈系清单请收好",
        @"城市角落里的温柔瞬间", @"今日分享：让生活慢一点", @"镜头里的四季与风景",
        @"好吃又好看的家常料理", @"收藏这份周末出行灵感", @"简单布置也能拥有好心情",
        @"今天也要记得认真生活", @"那些值得反复回看的片段", @"一起发现生活的小惊喜"
    ];
    NSArray<NSString *> *authors = @[@"暖阳日记", @"阿宁的相册", @"小满", @"晚风", @"周末计划", @"生活记录员"];
    NSArray<NSNumber *> *colors = @[@0xF6AA9A, @0x8DC9C0, @0xF3CA83, @0xA9B7D8, @0xC5ABD0, @0x83C7D9];
    NSArray<NSNumber *> *ratios = @[@1.12, @0.82, @1.26, @0.96, @1.05, @0.76];
    NSArray<NSString *> *categories = @[@"推荐", @"RED", @"直播", @"短剧", @"美食", @"穿搭", @"壁纸", @"旅行", @"科技"];
    NSMutableArray *items = [NSMutableArray array];
    for (NSInteger index = 0; index < 18; index++) {
        NSInteger source = (index + self.selectedMainIndex * 2 + self.selectedSubIndex) % titles.count;
        CRMFeedItem *item = [[CRMFeedItem alloc] init];
        item.title = titles[source];
        item.author = authors[(index + self.selectedSubIndex) % authors.count];
        item.likes = [NSString stringWithFormat:@"%ld", (long)(128 + index * 37 + self.selectedMainIndex * 21)];
        item.tag = categories[self.selectedSubIndex];
        item.startColor = CRMColor(colors[index % colors.count].unsignedIntegerValue);
        item.endColor = CRMColor(colors[(index + 2) % colors.count].unsignedIntegerValue);
        item.imageRatio = ratios[index % ratios.count].doubleValue;
        item.video = self.selectedSubIndex == 2 || index % 4 == 0;
        [items addObject:item];
    }
    self.feedItems = items;
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointZero animated:NO];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { return self.feedItems.count; }

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CRMFeedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CRMFeedCell" forIndexPath:indexPath];
    [cell configureWithItem:self.feedItems[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CRMFeedDetailViewController *detail = [[CRMFeedDetailViewController alloc] initWithFeedInfo:[self.feedItems[indexPath.item] detailInfo]];
    [self.navigationController pushViewController:detail animated:YES];
}

- (CGFloat)feedLayout:(CRMFeedLayout *)layout heightForItemAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)itemWidth {
    CRMFeedItem *item = self.feedItems[indexPath.item];
    return floor(itemWidth * MAX(0.72, item.imageRatio)) + 76;
}

@end
