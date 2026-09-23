//
//  CRMGameCenterViewController.m
//  My_Study
//
//  休闲小游戏集合。
//

#import "CRMGameCenterViewController.h"

static UIColor *GameColor(NSUInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 0xff) / 255.0
                           green:((hex >> 8) & 0xff) / 255.0
                            blue:(hex & 0xff) / 255.0 alpha:1];
}

static UILabel *GameLabel(NSString *text, CGFloat size, UIFontWeight weight, UIColor *color) {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:size weight:weight];
    label.textColor = color;
    label.numberOfLines = 0;
    return label;
}

static UIButton *GameButton(NSString *title, UIColor *background, UIColor *foreground) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:foreground forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    button.backgroundColor = background;
    button.layer.cornerRadius = 14;
    button.contentEdgeInsets = UIEdgeInsetsMake(11, 14, 11, 14);
    return button;
}

static void GameShowMessage(UIViewController *controller, NSString *title, NSString *message) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
    [controller presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 游戏页面公共布局

@interface CRMGameController : ZWBaseViewController

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIView *boardView;
@property (nonatomic, strong) UIStackView *actions;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSLayoutConstraint *boardWidthConstraint;
@property (nonatomic, assign) CGFloat maximumBoardWidth;

- (void)setupTitle:(NSString *)title subtitle:(NSString *)subtitle board:(UIView *)board aspect:(CGFloat)aspect maximumWidth:(CGFloat)maximumWidth;
- (UIButton *)addAction:(NSString *)title selector:(SEL)selector;

@end

#pragma mark - 数独

@interface CRMSudokuBoard : UIView
@property (nonatomic, strong) NSArray<UIView *> *majorLines;
- (void)bringLinesToFront;
@end

@implementation CRMSudokuBoard

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSMutableArray<UIView *> *lines = [NSMutableArray arrayWithCapacity:8];
        for (NSInteger index = 0; index < 8; index++) {
            UIView *line = [[UIView alloc] init];
            line.backgroundColor = GameColor(0x9EB9AE);
            line.userInteractionEnabled = NO;
            [self addSubview:line];
            [lines addObject:line];
        }
        self.majorLines = lines;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat side = CGRectGetWidth(self.bounds);
    for (NSInteger index = 0; index < 4; index++) {
        CGFloat position = MIN(side - 2, index * side / 3);
        self.majorLines[index].frame = CGRectMake(position, 0, 2, side);
        self.majorLines[index + 4].frame = CGRectMake(0, position, side, 2);
    }
}

- (void)bringLinesToFront {
    for (UIView *line in self.majorLines) [self bringSubviewToFront:line];
}
@end

@interface CRMSudokuController : CRMGameController
@property (nonatomic, strong) NSMutableArray<NSNumber *> *values;
@property (nonatomic, strong) NSArray<NSNumber *> *solution;
@property (nonatomic, strong) NSArray<NSNumber *> *fixed;
@property (nonatomic, strong) NSMutableArray<UIButton *> *cells;
@property (nonatomic, assign) NSInteger selectedCell;
@end

@implementation CRMSudokuController

- (void)viewDidLoad {
    [super viewDidLoad];
    CRMSudokuBoard *board = [[CRMSudokuBoard alloc] init];
    board.backgroundColor = GameColor(0xFFFFFF);
    [self setupTitle:@"数独" subtitle:@"每行、每列和每宫都填入 1 到 9" board:board aspect:1 maximumWidth:380];
    self.cells = [NSMutableArray arrayWithCapacity:81];
    UIStackView *grid = [[UIStackView alloc] init];
    grid.axis = UILayoutConstraintAxisVertical;
    grid.distribution = UIStackViewDistributionFillEqually;
    grid.translatesAutoresizingMaskIntoConstraints = NO;
    [board addSubview:grid];
    [NSLayoutConstraint activateConstraints:@[
        [grid.topAnchor constraintEqualToAnchor:board.topAnchor],
        [grid.leadingAnchor constraintEqualToAnchor:board.leadingAnchor],
        [grid.trailingAnchor constraintEqualToAnchor:board.trailingAnchor],
        [grid.bottomAnchor constraintEqualToAnchor:board.bottomAnchor]
    ]];
    for (NSInteger row = 0; row < 9; row++) {
        UIStackView *rowView = [[UIStackView alloc] init];
        rowView.axis = UILayoutConstraintAxisHorizontal;
        rowView.distribution = UIStackViewDistributionFillEqually;
        [grid addArrangedSubview:rowView];
        for (NSInteger column = 0; column < 9; column++) {
            NSInteger index = row * 9 + column;
            UIButton *cell = [UIButton buttonWithType:UIButtonTypeSystem];
            cell.tag = index;
            cell.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
            cell.layer.borderWidth = 0.35;
            cell.layer.borderColor = GameColor(0xD5E0DB).CGColor;
            [cell addTarget:self action:@selector(selectCell:) forControlEvents:UIControlEventTouchUpInside];
            [rowView addArrangedSubview:cell];
            [self.cells addObject:cell];
        }
    }
    [board bringLinesToFront];

    UIStackView *pad = [[UIStackView alloc] init];
    pad.axis = UILayoutConstraintAxisHorizontal;
    pad.distribution = UIStackViewDistributionFillEqually;
    pad.spacing = 3;
    [self.actions addArrangedSubview:pad];
    [pad.widthAnchor constraintEqualToAnchor:self.actions.widthAnchor].active = YES;
    for (NSInteger number = 1; number <= 9; number++) {
        UIButton *button = GameButton([NSString stringWithFormat:@"%ld", (long)number], GameColor(0xE5EEEA), GameColor(0x355B54));
        button.tag = number;
        button.contentEdgeInsets = UIEdgeInsetsZero;
        [button.heightAnchor constraintEqualToConstant:40].active = YES;
        [button addTarget:self action:@selector(inputNumber:) forControlEvents:UIControlEventTouchUpInside];
        [pad addArrangedSubview:button];
    }
    UIButton *erase = [self addAction:@"擦除选中格" selector:@selector(eraseSelected)];
    erase.backgroundColor = GameColor(0xF0EAE1);
    [self addAction:@"换一题" selector:@selector(restart)];
    self.actions.axis = UILayoutConstraintAxisVertical;
    [self restart];
}

- (void)restart {
    NSString *puzzle = @"530070000600195000098000060800060003400803001700020006060000280000419005000080079";
    NSString *answer = @"534678912672195348198342567859761423426853791713924856961537284287419635345286179";
    NSInteger shift = arc4random_uniform(9);
    NSMutableArray *givens = [NSMutableArray arrayWithCapacity:81];
    NSMutableArray *solution = [NSMutableArray arrayWithCapacity:81];
    for (NSInteger index = 0; index < 81; index++) {
        NSInteger clue = [puzzle characterAtIndex:index] - '0';
        NSInteger solved = [answer characterAtIndex:index] - '0';
        [givens addObject:@(clue ? (clue + shift - 1) % 9 + 1 : 0)];
        [solution addObject:@((solved + shift - 1) % 9 + 1)];
    }
    self.fixed = [givens copy];
    self.values = [givens mutableCopy];
    self.solution = [solution copy];
    self.selectedCell = -1;
    [self refresh];
}

- (void)selectCell:(UIButton *)sender {
    self.selectedCell = sender.tag;
    [self refresh];
}

- (void)inputNumber:(UIButton *)sender {
    if (self.selectedCell < 0 || self.fixed[self.selectedCell].integerValue) return;
    self.values[self.selectedCell] = @(sender.tag);
    [self refresh];
    if ([self.values isEqualToArray:self.solution]) GameShowMessage(self, @"数独完成", @"所有数字都填对了！");
}

- (void)eraseSelected {
    if (self.selectedCell < 0 || self.fixed[self.selectedCell].integerValue) return;
    self.values[self.selectedCell] = @0;
    [self refresh];
}

- (BOOL)hasConflictAt:(NSInteger)index {
    NSInteger value = self.values[index].integerValue;
    if (!value) return NO;
    NSInteger row = index / 9, column = index % 9;
    for (NSInteger i = 0; i < 81; i++) {
        if (i == index || self.values[i].integerValue != value) continue;
        if (i / 9 == row || i % 9 == column || (i / 27 == row / 3 && i % 9 / 3 == column / 3)) return YES;
    }
    return NO;
}

- (void)refresh {
    NSInteger filled = 0, conflicts = 0;
    for (NSInteger index = 0; index < 81; index++) {
        NSInteger value = self.values[index].integerValue;
        if (value) filled++;
        BOOL conflict = [self hasConflictAt:index];
        if (conflict) conflicts++;
        UIButton *cell = self.cells[index];
        [cell setTitle:value ? [NSString stringWithFormat:@"%ld", (long)value] : @"" forState:UIControlStateNormal];
        [cell setTitleColor:conflict ? GameColor(0xC76258) : (self.fixed[index].integerValue ? GameColor(0x263A3B) : GameColor(0x487A70)) forState:UIControlStateNormal];
        cell.backgroundColor = index == self.selectedCell ? GameColor(0xCDE5D9) : ((index / 9 / 3 + index % 9 / 3) % 2 ? GameColor(0xF4F8F5) : UIColor.whiteColor);
    }
    self.statusLabel.text = conflicts ? [NSString stringWithFormat:@"已填 %ld/81 · 有冲突的数字", (long)filled] : [NSString stringWithFormat:@"已填 %ld/81 · 点选空格后输入", (long)filled];
}
@end

#pragma mark - 俄罗斯方块

static const NSInteger CRMShapes[7][4][2] = {
    {{0,1},{1,1},{2,1},{3,1}}, {{1,0},{2,0},{1,1},{2,1}},
    {{1,0},{0,1},{1,1},{2,1}}, {{1,0},{2,0},{0,1},{1,1}},
    {{0,0},{1,0},{1,1},{2,1}}, {{0,0},{0,1},{1,1},{2,1}},
    {{2,0},{0,1},{1,1},{2,1}}
};

static NSUInteger CRMShapeColors[7] = {0x71B8BD, 0xEBC67C, 0xAF9ACB, 0x88BD9B, 0xD98F89, 0x8AA5CA, 0xDEA878};

@interface CRMTetrisBoard : UIView
@property (nonatomic, strong) NSArray<NSNumber *> *cells;
@property (nonatomic, assign) NSInteger pieceX;
@property (nonatomic, assign) NSInteger pieceY;
@property (nonatomic, assign) NSInteger pieceType;
@property (nonatomic, assign) NSInteger rotation;
@property (nonatomic, assign) BOOL active;
@end

@implementation CRMTetrisBoard

- (void)drawRect:(CGRect)rect {
    [GameColor(0x263A3B) setFill];
    UIRectFill(rect);
    CGFloat size = MIN(rect.size.width / 10, rect.size.height / 20);
    for (NSInteger row = 0; row < 20; row++) {
        for (NSInteger column = 0; column < 10; column++) {
            NSInteger value = self.cells[row * 10 + column].integerValue;
            CGRect block = CGRectMake(column * size + 1.5, row * size + 1.5, size - 3, size - 3);
            [GameColor(value ? CRMShapeColors[value - 1] : 0x314848) setFill];
            [[UIBezierPath bezierPathWithRoundedRect:block cornerRadius:3] fill];
        }
    }
    if (!self.active) return;
    [GameColor(CRMShapeColors[self.pieceType]) setFill];
    for (NSInteger i = 0; i < 4; i++) {
        NSInteger x = CRMShapes[self.pieceType][i][0], y = CRMShapes[self.pieceType][i][1];
        for (NSInteger turn = 0; turn < self.rotation; turn++) { NSInteger next = 3 - y; y = x; x = next; }
        CGRect block = CGRectMake((self.pieceX + x) * size + 1.5, (self.pieceY + y) * size + 1.5, size - 3, size - 3);
        [[UIBezierPath bezierPathWithRoundedRect:block cornerRadius:3] fill];
    }
}
@end

@interface CRMTetrisController : CRMGameController
@property (nonatomic, strong) NSMutableArray<NSNumber *> *cells;
@property (nonatomic, strong) CRMTetrisBoard *gameBoard;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger pieceX;
@property (nonatomic, assign) NSInteger pieceY;
@property (nonatomic, assign) NSInteger pieceType;
@property (nonatomic, assign) NSInteger rotation;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, assign) NSInteger lines;
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, assign) BOOL gameOver;
@end

@implementation CRMTetrisController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameBoard = [[CRMTetrisBoard alloc] init];
    [self setupTitle:@"俄罗斯方块" subtitle:@"移动、旋转方块，填满一行即可消除" board:self.gameBoard aspect:2 maximumWidth:245];
    self.actions.axis = UILayoutConstraintAxisVertical;
    UIStackView *move = [self actionRow:@[@"◀", @"⟳", @"▶", @"▼"] selectors:@[@"moveLeft", @"rotatePiece", @"moveRight", @"softDrop"]];
    [self.actions addArrangedSubview:move];
    [move.widthAnchor constraintEqualToAnchor:self.actions.widthAnchor].active = YES;
    UIStackView *tools = [self actionRow:@[@"一键落下", @"暂停 / 继续", @"新游戏"] selectors:@[@"hardDrop", @"togglePause", @"restart"]];
    [self.actions addArrangedSubview:tools];
    [tools.widthAnchor constraintEqualToAnchor:self.actions.widthAnchor].active = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseForBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [self restart];
}

- (UIStackView *)actionRow:(NSArray<NSString *> *)titles selectors:(NSArray<NSString *> *)selectors {
    UIStackView *row = [[UIStackView alloc] init];
    row.axis = UILayoutConstraintAxisHorizontal;
    row.distribution = UIStackViewDistributionFillEqually;
    row.spacing = 8;
    for (NSInteger index = 0; index < titles.count; index++) {
        UIButton *button = GameButton(titles[index], GameColor(0xE5EEEA), GameColor(0x355B54));
        button.contentEdgeInsets = UIEdgeInsetsMake(10, 2, 10, 2);
        [button addTarget:self action:NSSelectorFromString(selectors[index]) forControlEvents:UIControlEventTouchUpInside];
        [row addArrangedSubview:button];
    }
    return row;
}

- (void)dealloc {
    [self.timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)pauseForBackground {
    self.paused = YES;
    [self.timer invalidate];
    self.timer = nil;
    [self refresh];
}

- (void)startTimer {
    if (self.timer || self.paused || self.gameOver || !self.isViewLoaded || !self.view.window) return;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.55 target:self selector:@selector(tick) userInfo:nil repeats:YES];
}

- (void)restart {
    [self.timer invalidate];
    self.timer = nil;
    self.cells = [NSMutableArray arrayWithCapacity:200];
    for (NSInteger index = 0; index < 200; index++) [self.cells addObject:@0];
    self.score = 0;
    self.lines = 0;
    self.paused = NO;
    self.gameOver = NO;
    [self spawnPiece];
    [self refresh];
    [self startTimer];
}

- (void)spawnPiece {
    self.pieceType = arc4random_uniform(7);
    self.pieceX = 3;
    self.pieceY = 0;
    self.rotation = 0;
    if (![self canPlaceX:self.pieceX y:self.pieceY rotation:0]) {
        self.gameOver = YES;
        [self.timer invalidate];
        self.timer = nil;
        GameShowMessage(self, @"游戏结束", [NSString stringWithFormat:@"本局得分 %ld，消除了 %ld 行。", (long)self.score, (long)self.lines]);
    }
}

- (BOOL)canPlaceX:(NSInteger)originX y:(NSInteger)originY rotation:(NSInteger)rotation {
    for (NSInteger i = 0; i < 4; i++) {
        NSInteger x = CRMShapes[self.pieceType][i][0], y = CRMShapes[self.pieceType][i][1];
        for (NSInteger turn = 0; turn < rotation; turn++) { NSInteger next = 3 - y; y = x; x = next; }
        x += originX; y += originY;
        if (x < 0 || x >= 10 || y >= 20 || (y >= 0 && self.cells[y * 10 + x].integerValue)) return NO;
    }
    return YES;
}

- (void)moveLeft { if (!self.paused && !self.gameOver && [self canPlaceX:self.pieceX - 1 y:self.pieceY rotation:self.rotation]) { self.pieceX--; [self refresh]; } }
- (void)moveRight { if (!self.paused && !self.gameOver && [self canPlaceX:self.pieceX + 1 y:self.pieceY rotation:self.rotation]) { self.pieceX++; [self refresh]; } }
- (void)softDrop { if (!self.paused && !self.gameOver) [self tick]; }

- (void)rotatePiece {
    if (self.paused || self.gameOver) return;
    if (self.pieceType == 1) return;
    NSInteger next = (self.rotation + 1) % 4;
    for (NSNumber *offset in @[@0, @(-1), @1, @(-2), @2]) {
        if ([self canPlaceX:self.pieceX + offset.integerValue y:self.pieceY rotation:next]) {
            self.pieceX += offset.integerValue;
            self.rotation = next;
            [self refresh];
            return;
        }
    }
}

- (void)hardDrop {
    if (self.paused || self.gameOver) return;
    while ([self canPlaceX:self.pieceX y:self.pieceY + 1 rotation:self.rotation]) { self.pieceY++; self.score += 2; }
    [self lockPiece];
}

- (void)togglePause {
    if (self.gameOver) return;
    self.paused = !self.paused;
    if (self.paused) { [self.timer invalidate]; self.timer = nil; }
    else [self startTimer];
    [self refresh];
}

- (void)tick {
    if (self.paused || self.gameOver) return;
    if ([self canPlaceX:self.pieceX y:self.pieceY + 1 rotation:self.rotation]) self.pieceY++;
    else [self lockPiece];
    [self refresh];
}

- (void)lockPiece {
    for (NSInteger i = 0; i < 4; i++) {
        NSInteger x = CRMShapes[self.pieceType][i][0], y = CRMShapes[self.pieceType][i][1];
        for (NSInteger turn = 0; turn < self.rotation; turn++) { NSInteger next = 3 - y; y = x; x = next; }
        NSInteger row = self.pieceY + y, column = self.pieceX + x;
        if (row >= 0 && row < 20) self.cells[row * 10 + column] = @(self.pieceType + 1);
    }
    NSInteger cleared = 0;
    for (NSInteger row = 19; row >= 0; row--) {
        BOOL full = YES;
        for (NSInteger column = 0; column < 10; column++) if (!self.cells[row * 10 + column].integerValue) full = NO;
        if (!full) continue;
        for (NSInteger current = row; current > 0; current--)
            for (NSInteger column = 0; column < 10; column++) self.cells[current * 10 + column] = self.cells[(current - 1) * 10 + column];
        for (NSInteger column = 0; column < 10; column++) self.cells[column] = @0;
        cleared++;
        row++;
    }
    self.lines += cleared;
    NSInteger rewards[] = {0, 100, 300, 500, 800};
    self.score += rewards[MIN(cleared, 4)];
    [self spawnPiece];
    [self refresh];
}

- (void)refresh {
    self.gameBoard.cells = self.cells;
    self.gameBoard.pieceX = self.pieceX;
    self.gameBoard.pieceY = self.pieceY;
    self.gameBoard.pieceType = self.pieceType;
    self.gameBoard.rotation = self.rotation;
    self.gameBoard.active = !self.gameOver;
    [self.gameBoard setNeedsDisplay];
    self.statusLabel.text = self.gameOver ? @"游戏结束 · 点新游戏再来一局" : (self.paused ? @"已暂停" : [NSString stringWithFormat:@"得分 %ld  ·  消除 %ld 行", (long)self.score, (long)self.lines]);
}
@end

@implementation CRMGameController

+ (NSDictionary *)ss_constantParams {
    return @{@"hideNavigationBar": @(YES)};
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hideNavigationBar = YES;
        self.hideTabbar = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)setupTitle:(NSString *)title subtitle:(NSString *)subtitle board:(UIView *)board aspect:(CGFloat)aspect maximumWidth:(CGFloat)maximumWidth {
    self.view.backgroundColor = GameColor(0xF7F7F2);
    self.maximumBoardWidth = maximumWidth;
    self.boardView = board;
    self.boardView.translatesAutoresizingMaskIntoConstraints = NO;
    self.boardView.layer.cornerRadius = 20;
    self.boardView.layer.masksToBounds = YES;

    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:self.scrollView];
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];

    UIStackView *content = [[UIStackView alloc] init];
    content.axis = UILayoutConstraintAxisVertical;
    content.alignment = UIStackViewAlignmentCenter;
    content.spacing = 16;
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:content];
    [NSLayoutConstraint activateConstraints:@[
        [content.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor constant:16],
        [content.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor constant:18],
        [content.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor constant:-18],
        [content.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor constant:-28],
        [content.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor constant:-36]
    ]];

    UIView *heading = [[UIView alloc] init];
    heading.translatesAutoresizingMaskIntoConstraints = NO;
    [content addArrangedSubview:heading];
    [heading.widthAnchor constraintEqualToAnchor:content.widthAnchor].active = YES;
    [heading.heightAnchor constraintEqualToConstant:72].active = YES;
    UIButton *back = GameButton(@"‹", GameColor(0xE9ECE8), GameColor(0x243B39));
    back.titleLabel.font = [UIFont systemFontOfSize:29 weight:UIFontWeightRegular];
    back.translatesAutoresizingMaskIntoConstraints = NO;
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [heading addSubview:back];
    UILabel *titleLabel = GameLabel(title, 27, UIFontWeightBold, GameColor(0x243B39));
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [heading addSubview:titleLabel];
    [NSLayoutConstraint activateConstraints:@[
        [back.leadingAnchor constraintEqualToAnchor:heading.leadingAnchor],
        [back.topAnchor constraintEqualToAnchor:heading.topAnchor constant:4],
        [back.widthAnchor constraintEqualToConstant:46],
        [back.heightAnchor constraintEqualToConstant:46],
        [titleLabel.leadingAnchor constraintEqualToAnchor:back.trailingAnchor constant:14],
        [titleLabel.centerYAnchor constraintEqualToAnchor:back.centerYAnchor]
    ]];
    UILabel *subtitleLabel = GameLabel(subtitle, 13, UIFontWeightRegular, GameColor(0x798986));
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [heading addSubview:subtitleLabel];
    [NSLayoutConstraint activateConstraints:@[
        [subtitleLabel.leadingAnchor constraintEqualToAnchor:heading.leadingAnchor],
        [subtitleLabel.trailingAnchor constraintEqualToAnchor:heading.trailingAnchor],
        [subtitleLabel.bottomAnchor constraintEqualToAnchor:heading.bottomAnchor]
    ]];

    self.statusLabel = GameLabel(@"", 16, UIFontWeightSemibold, GameColor(0x355B54));
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [content addArrangedSubview:self.statusLabel];
    [content addArrangedSubview:board];
    self.boardWidthConstraint = [board.widthAnchor constraintEqualToConstant:maximumWidth];
    self.boardWidthConstraint.active = YES;
    [board.heightAnchor constraintEqualToAnchor:board.widthAnchor multiplier:aspect].active = YES;

    self.actions = [[UIStackView alloc] init];
    self.actions.axis = UILayoutConstraintAxisHorizontal;
    self.actions.distribution = UIStackViewDistributionFillEqually;
    self.actions.spacing = 9;
    [content addArrangedSubview:self.actions];
    [self.actions.widthAnchor constraintEqualToAnchor:content.widthAnchor].active = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.boardWidthConstraint.constant = MIN(self.maximumBoardWidth, MAX(220, CGRectGetWidth(self.view.bounds) - 36));
}

- (UIButton *)addAction:(NSString *)title selector:(SEL)selector {
    UIButton *button = GameButton(title, GameColor(0xE5EEEA), GameColor(0x355B54));
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.actions addArrangedSubview:button];
    return button;
}

@end

#pragma mark - 五子棋

@interface CRMGomokuBoard : UIView
@property (nonatomic, strong) NSArray<NSNumber *> *cells;
@property (nonatomic, copy) void (^tapCell)(NSInteger row, NSInteger column);
@end

@implementation CRMGomokuBoard

- (void)drawRect:(CGRect)rect {
    [[UIColor colorWithRed:0.91 green:0.79 blue:0.59 alpha:1] setFill];
    UIRectFill(rect);
    CGFloat inset = 18;
    CGFloat step = (MIN(rect.size.width, rect.size.height) - 2 * inset) / 14;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, GameColor(0x9C8664).CGColor);
    CGContextSetLineWidth(context, 0.7);
    for (NSInteger index = 0; index < 15; index++) {
        CGFloat coordinate = inset + step * index;
        CGContextMoveToPoint(context, inset, coordinate);
        CGContextAddLineToPoint(context, inset + 14 * step, coordinate);
        CGContextMoveToPoint(context, coordinate, inset);
        CGContextAddLineToPoint(context, coordinate, inset + 14 * step);
    }
    CGContextStrokePath(context);
    for (NSInteger row = 0; row < 15; row++) {
        for (NSInteger column = 0; column < 15; column++) {
            NSInteger value = self.cells[row * 15 + column].integerValue;
            if (!value) continue;
            CGRect stone = CGRectMake(inset + step * column - step * 0.41, inset + step * row - step * 0.41, step * 0.82, step * 0.82);
            UIColor *stoneColor = value == 1 ? GameColor(0x263A3B) : GameColor(0xFCFAF2);
            [stoneColor setFill];
            [[UIBezierPath bezierPathWithOvalInRect:stone] fill];
            if (value == 2) {
                [GameColor(0xD2CBB8) setStroke];
                [[UIBezierPath bezierPathWithOvalInRect:stone] stroke];
            }
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [touches.anyObject locationInView:self];
    CGFloat step = (MIN(self.bounds.size.width, self.bounds.size.height) - 36) / 14;
    NSInteger column = lround((point.x - 18) / step);
    NSInteger row = lround((point.y - 18) / step);
    if (row >= 0 && row < 15 && column >= 0 && column < 15 && self.tapCell) self.tapCell(row, column);
}
@end

@interface CRMGomokuController : CRMGameController
@property (nonatomic, strong) NSMutableArray<NSNumber *> *cells;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *history;
@property (nonatomic, strong) CRMGomokuBoard *gameBoard;
@property (nonatomic, assign) NSInteger currentPlayer;
@property (nonatomic, assign) BOOL finished;
@end

@implementation CRMGomokuController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameBoard = [[CRMGomokuBoard alloc] init];
    [self setupTitle:@"五子棋" subtitle:@"双人对弈 · 五子连珠获胜" board:self.gameBoard aspect:1 maximumWidth:390];
    __weak typeof(self) weakSelf = self;
    self.gameBoard.tapCell = ^(NSInteger row, NSInteger column) { [weakSelf placeAtRow:row column:column]; };
    [self addAction:@"悔一步" selector:@selector(undoMove)];
    [self addAction:@"重新开始" selector:@selector(restart)];
    [self restart];
}

- (void)restart {
    self.cells = [NSMutableArray arrayWithCapacity:225];
    for (NSInteger index = 0; index < 225; index++) [self.cells addObject:@0];
    self.history = [NSMutableArray array];
    self.currentPlayer = 1;
    self.finished = NO;
    [self refresh];
}

- (void)refresh {
    self.gameBoard.cells = self.cells;
    [self.gameBoard setNeedsDisplay];
    self.statusLabel.text = self.finished ? @"对局结束" : (self.currentPlayer == 1 ? @"● 黑棋先行" : @"○ 轮到白棋");
}

- (void)placeAtRow:(NSInteger)row column:(NSInteger)column {
    NSInteger index = row * 15 + column;
    if (self.finished || self.cells[index].integerValue) return;
    self.cells[index] = @(self.currentPlayer);
    [self.history addObject:@(index)];
    BOOL won = [self countFromRow:row column:column deltaRow:1 deltaColumn:0] >= 5 ||
               [self countFromRow:row column:column deltaRow:0 deltaColumn:1] >= 5 ||
               [self countFromRow:row column:column deltaRow:1 deltaColumn:1] >= 5 ||
               [self countFromRow:row column:column deltaRow:1 deltaColumn:-1] >= 5;
    if (won || self.history.count == 225) {
        self.finished = YES;
        [self refresh];
        GameShowMessage(self, won ? @"对局结束" : @"平局", won ? (self.currentPlayer == 1 ? @"黑棋获胜！" : @"白棋获胜！") : @"棋盘已满，再来一局吧。");
    } else {
        self.currentPlayer = 3 - self.currentPlayer;
        [self refresh];
    }
}

- (NSInteger)countFromRow:(NSInteger)row column:(NSInteger)column deltaRow:(NSInteger)dr deltaColumn:(NSInteger)dc {
    NSInteger count = 1;
    for (NSInteger direction = -1; direction <= 1; direction += 2) {
        NSInteger r = row + dr * direction, c = column + dc * direction;
        while (r >= 0 && r < 15 && c >= 0 && c < 15 && self.cells[r * 15 + c].integerValue == self.currentPlayer) {
            count++;
            r += dr * direction;
            c += dc * direction;
        }
    }
    return count;
}

- (void)undoMove {
    NSNumber *last = self.history.lastObject;
    if (!last) return;
    NSInteger player = self.cells[last.integerValue].integerValue;
    self.cells[last.integerValue] = @0;
    [self.history removeLastObject];
    self.currentPlayer = player;
    self.finished = NO;
    [self refresh];
}
@end

#pragma mark - 数字拼图

@interface CRMPuzzleController : CRMGameController
@property (nonatomic, strong) NSMutableArray<NSNumber *> *tiles;
@property (nonatomic, strong) NSMutableArray<UIButton *> *tileButtons;
@property (nonatomic, assign) NSInteger moves;
@property (nonatomic, assign) BOOL finished;
@end

@implementation CRMPuzzleController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *board = [[UIView alloc] init];
    board.backgroundColor = GameColor(0xDCE7E3);
    [self setupTitle:@"数字拼图" subtitle:@"滑动方块，将数字按顺序排好" board:board aspect:1 maximumWidth:360];
    UIStackView *grid = [[UIStackView alloc] init];
    grid.axis = UILayoutConstraintAxisVertical;
    grid.distribution = UIStackViewDistributionFillEqually;
    grid.spacing = 7;
    grid.translatesAutoresizingMaskIntoConstraints = NO;
    [board addSubview:grid];
    [NSLayoutConstraint activateConstraints:@[
        [grid.topAnchor constraintEqualToAnchor:board.topAnchor constant:7],
        [grid.leadingAnchor constraintEqualToAnchor:board.leadingAnchor constant:7],
        [grid.trailingAnchor constraintEqualToAnchor:board.trailingAnchor constant:-7],
        [grid.bottomAnchor constraintEqualToAnchor:board.bottomAnchor constant:-7]
    ]];
    self.tileButtons = [NSMutableArray array];
    for (NSInteger row = 0; row < 3; row++) {
        UIStackView *rowView = [[UIStackView alloc] init];
        rowView.axis = UILayoutConstraintAxisHorizontal;
        rowView.distribution = UIStackViewDistributionFillEqually;
        rowView.spacing = 7;
        [grid addArrangedSubview:rowView];
        for (NSInteger column = 0; column < 3; column++) {
            NSInteger index = row * 3 + column;
            UIButton *button = GameButton(@"", GameColor(0xFFFFFF), GameColor(0x315D56));
            button.tag = index;
            button.titleLabel.font = [UIFont systemFontOfSize:30 weight:UIFontWeightBold];
            [button addTarget:self action:@selector(tileTapped:) forControlEvents:UIControlEventTouchUpInside];
            [rowView addArrangedSubview:button];
            [self.tileButtons addObject:button];
        }
    }
    [self addAction:@"重新打乱" selector:@selector(restart)];
    [self restart];
}

- (void)restart {
    self.tiles = [@[@1, @2, @3, @4, @5, @6, @7, @8, @0] mutableCopy];
    NSInteger empty = 8, previous = -1;
    // 从完成状态执行合法移动，始终生成可解的拼图。
    for (NSInteger turn = 0; turn < 120; turn++) {
        NSMutableArray<NSNumber *> *neighbors = [NSMutableArray array];
        NSInteger row = empty / 3, column = empty % 3;
        if (row > 0) [neighbors addObject:@(empty - 3)];
        if (row < 2) [neighbors addObject:@(empty + 3)];
        if (column > 0) [neighbors addObject:@(empty - 1)];
        if (column < 2) [neighbors addObject:@(empty + 1)];
        [neighbors removeObject:@(previous)];
        NSInteger next = neighbors[arc4random_uniform((uint32_t)neighbors.count)].integerValue;
        [self.tiles exchangeObjectAtIndex:empty withObjectAtIndex:next];
        previous = empty;
        empty = next;
    }
    BOOL solved = YES;
    for (NSInteger index = 0; index < 8; index++) if (self.tiles[index].integerValue != index + 1) solved = NO;
    if (solved) [self.tiles exchangeObjectAtIndex:8 withObjectAtIndex:7];
    self.moves = 0;
    self.finished = NO;
    [self refresh];
}

- (void)refresh {
    self.statusLabel.text = [NSString stringWithFormat:@"已移动 %ld 步", (long)self.moves];
    for (NSInteger index = 0; index < 9; index++) {
        NSInteger value = self.tiles[index].integerValue;
        UIButton *button = self.tileButtons[index];
        button.enabled = value != 0;
        [button setTitle:value ? [NSString stringWithFormat:@"%ld", (long)value] : @"" forState:UIControlStateNormal];
        button.backgroundColor = value == 0 ? UIColor.clearColor : (value % 2 ? GameColor(0xFFFFFF) : GameColor(0xF5F3E9));
    }
}

- (void)tileTapped:(UIButton *)sender {
    if (self.finished) return;
    NSInteger index = sender.tag;
    NSInteger empty = [self.tiles indexOfObject:@0];
    if (labs(index / 3 - empty / 3) + labs(index % 3 - empty % 3) != 1) return;
    [self.tiles exchangeObjectAtIndex:index withObjectAtIndex:empty];
    self.moves++;
    [self refresh];
    BOOL solved = YES;
    for (NSInteger i = 0; i < 8; i++) if (self.tiles[i].integerValue != i + 1) solved = NO;
    if (solved) {
        self.finished = YES;
        GameShowMessage(self, @"拼图完成", [NSString stringWithFormat:@"太棒了！共用了 %ld 步。", (long)self.moves]);
    }
}
@end

#pragma mark - 游戏集合入口

@interface CRMGameCenterViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation CRMGameCenterViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hideNavigationBar = YES;
        self.hideTabbar = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

+ (NSDictionary *)ss_constantParams {
    return @{@"hideNavigationBar": @(YES)};
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = GameColor(0xF7F7F2);
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:self.scrollView];
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];

    UIStackView *content = [[UIStackView alloc] init];
    content.axis = UILayoutConstraintAxisVertical;
    content.spacing = 18;
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:content];
    [NSLayoutConstraint activateConstraints:@[
        [content.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor constant:20],
        [content.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor constant:20],
        [content.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor constant:-20],
        [content.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor constant:-30],
        [content.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor constant:-40]
    ]];

    UIStackView *topRow = [[UIStackView alloc] init];
    topRow.axis = UILayoutConstraintAxisHorizontal;
    topRow.alignment = UIStackViewAlignmentCenter;
    topRow.spacing = 12;
    [content addArrangedSubview:topRow];
    [topRow.widthAnchor constraintEqualToAnchor:content.widthAnchor].active = YES;
    UIButton *back = GameButton(@"‹", GameColor(0xE9ECE8), GameColor(0x243B39));
    back.titleLabel.font = [UIFont systemFontOfSize:29 weight:UIFontWeightRegular];
    [back.widthAnchor constraintEqualToConstant:46].active = YES;
    [back.heightAnchor constraintEqualToConstant:46].active = YES;
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [topRow addArrangedSubview:back];
    UILabel *eyebrow = GameLabel(@"PLAY & RELAX", 12, UIFontWeightBold, GameColor(0x6D998A));
    [topRow addArrangedSubview:eyebrow];
    UILabel *title = GameLabel(@"小游戏乐园", 32, UIFontWeightBold, GameColor(0x243B39));
    [content addArrangedSubview:title];
    content.spacing = 11;
    UILabel *intro = GameLabel(@"给忙碌的日常，留一点轻松时刻。", 15, UIFontWeightRegular, GameColor(0x798986));
    [content addArrangedSubview:intro];
    [content setCustomSpacing:23 afterView:intro];

    UIView *hero = [[UIView alloc] init];
    hero.backgroundColor = GameColor(0x355D55);
    hero.layer.cornerRadius = 24;
    [content addArrangedSubview:hero];
    [hero.widthAnchor constraintEqualToAnchor:content.widthAnchor].active = YES;
    [hero.heightAnchor constraintEqualToConstant:165].active = YES;
    UILabel *heroIcon = GameLabel(@"✦", 74, UIFontWeightLight, GameColor(0xE8CFA2));
    heroIcon.translatesAutoresizingMaskIntoConstraints = NO;
    [hero addSubview:heroIcon];
    UILabel *heroTitle = GameLabel(@"随时开玩", 24, UIFontWeightBold, UIColor.whiteColor);
    heroTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [hero addSubview:heroTitle];
    UILabel *heroDetail = GameLabel(@"四款经典小游戏\n从一局开始，放松一下。", 14, UIFontWeightRegular, GameColor(0xD8E6DF));
    heroDetail.translatesAutoresizingMaskIntoConstraints = NO;
    [hero addSubview:heroDetail];
    [NSLayoutConstraint activateConstraints:@[
        [heroTitle.leadingAnchor constraintEqualToAnchor:hero.leadingAnchor constant:22],
        [heroTitle.topAnchor constraintEqualToAnchor:hero.topAnchor constant:30],
        [heroDetail.leadingAnchor constraintEqualToAnchor:heroTitle.leadingAnchor],
        [heroDetail.topAnchor constraintEqualToAnchor:heroTitle.bottomAnchor constant:10],
        [heroIcon.trailingAnchor constraintEqualToAnchor:hero.trailingAnchor constant:-24],
        [heroIcon.centerYAnchor constraintEqualToAnchor:hero.centerYAnchor]
    ]];

    UILabel *section = GameLabel(@"挑一个喜欢的", 20, UIFontWeightBold, GameColor(0x243B39));
    [content addArrangedSubview:section];
    [content setCustomSpacing:15 afterView:hero];
    [content setCustomSpacing:15 afterView:section];

    NSArray<NSArray<NSString *> *> *items = @[
        @[@"五子棋", @"双人对弈 · 连成五子", @"●", @"DDECE3"],
        @[@"数字拼图", @"移动方块 · 排好顺序", @"▦", @"F3E9D9"],
        @[@"数独", @"静心思考 · 填满九宫", @"9", @"E8E5F2"],
        @[@"俄罗斯方块", @"旋转下落 · 消除整行", @"▣", @"E7EDF2"]
    ];
    for (NSInteger row = 0; row < 2; row++) {
        UIStackView *cards = [[UIStackView alloc] init];
        cards.axis = UILayoutConstraintAxisHorizontal;
        cards.distribution = UIStackViewDistributionFillEqually;
        cards.spacing = 12;
        [content addArrangedSubview:cards];
        [cards.widthAnchor constraintEqualToAnchor:content.widthAnchor].active = YES;
        [cards.heightAnchor constraintEqualToConstant:182].active = YES;
        for (NSInteger column = 0; column < 2; column++) {
            NSInteger index = row * 2 + column;
            [cards addArrangedSubview:[self cardWithInfo:items[index] index:index]];
        }
    }
    UILabel *footer = GameLabel(@"每一局，都是自己的节奏。", 13, UIFontWeightRegular, GameColor(0x9AA8A3));
    footer.textAlignment = NSTextAlignmentCenter;
    [content addArrangedSubview:footer];
}

- (UIView *)cardWithInfo:(NSArray<NSString *> *)info index:(NSInteger)index {
    UIButton *card = [UIButton buttonWithType:UIButtonTypeCustom];
    unsigned int hex = 0;
    [[NSScanner scannerWithString:info[3]] scanHexInt:&hex];
    card.backgroundColor = GameColor(hex);
    card.layer.cornerRadius = 22;
    card.tag = index;
    [card addTarget:self action:@selector(openGame:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *icon = GameLabel(info[2], 34, UIFontWeightBold, GameColor(0x355D55));
    icon.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:icon];
    UILabel *name = GameLabel(info[0], 19, UIFontWeightBold, GameColor(0x263A3B));
    name.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:name];
    UILabel *detail = GameLabel(info[1], 11, UIFontWeightRegular, GameColor(0x71817B));
    detail.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:detail];
    [NSLayoutConstraint activateConstraints:@[
        [icon.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:18],
        [icon.topAnchor constraintEqualToAnchor:card.topAnchor constant:15],
        [name.leadingAnchor constraintEqualToAnchor:icon.leadingAnchor],
        [name.trailingAnchor constraintLessThanOrEqualToAnchor:card.trailingAnchor constant:-8],
        [name.bottomAnchor constraintEqualToAnchor:detail.topAnchor constant:-5],
        [detail.leadingAnchor constraintEqualToAnchor:icon.leadingAnchor],
        [detail.trailingAnchor constraintLessThanOrEqualToAnchor:card.trailingAnchor constant:-8],
        [detail.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-18]
    ]];
    return card;
}

- (void)openGame:(UIButton *)sender {
    UIViewController *controller = nil;
    switch (sender.tag) {
        case 0: controller = [[CRMGomokuController alloc] init]; break;
        case 1: controller = [[CRMPuzzleController alloc] init]; break;
        case 2: controller = [[CRMSudokuController alloc] init]; break;
        case 3: controller = [[CRMTetrisController alloc] init]; break;
        default: return;
    }
    [self.navigationController pushViewController:controller animated:YES];
}

@end
