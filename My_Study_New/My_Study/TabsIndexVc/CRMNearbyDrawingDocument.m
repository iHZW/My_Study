#import "CRMNearbyDrawingDocument.h"
#import <math.h>

static const NSUInteger CRMMaxPoints = 20000;
static const NSUInteger CRMMaxStrokes = 500;

static BOOL CRMNumber(id value, double minimum, double maximum) {
    if (![value isKindOfClass:NSNumber.class] || CFGetTypeID((__bridge CFTypeRef)value) == CFBooleanGetTypeID()) return NO;
    double number = [value doubleValue];
    return isfinite(number) && number >= minimum && number <= maximum;
}
static BOOL CRMInteger(id value, NSUInteger maximum) {
    return CRMNumber(value, 0, maximum) && floor([value doubleValue]) == [value doubleValue];
}
static BOOL CRMPoints(id points) {
    if (![points isKindOfClass:NSArray.class] || [points count] == 0 || [points count] > CRMMaxPoints) return NO;
    for (id point in points) {
        if (![point isKindOfClass:NSArray.class] || [point count] != 2 ||
            !CRMNumber(point[0], 0, 1) || !CRMNumber(point[1], 0, 1)) return NO;
    }
    return YES;
}
static BOOL CRMStroke(id stroke) {
    if (![stroke isKindOfClass:NSDictionary.class]) return NO;
    id identifier = stroke[@"id"];
    return [identifier isKindOfClass:NSString.class] && [identifier length] > 0 && [identifier length] <= 64 &&
        CRMInteger(stroke[@"color"], 5) && CRMNumber(stroke[@"width"], 1, 30) && CRMPoints(stroke[@"points"]);
}

@interface CRMNearbyDrawingDocument ()
@property (nonatomic) NSUInteger revision;
@property (nonatomic) NSUInteger pointCount;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *storage;
@end

@implementation CRMNearbyDrawingDocument
- (instancetype)init {
    if ((self = [super init])) _storage = [NSMutableArray array];
    return self;
}
- (NSArray<NSDictionary *> *)strokes { return [self.storage copy]; }
- (BOOL)applyOperation:(NSDictionary *)operation {
    if (![operation isKindOfClass:NSDictionary.class] ||
        !CRMInteger(operation[@"revision"], 1000000000) ||
        [operation[@"revision"] unsignedIntegerValue] != self.revision + 1) return NO;
    NSString *type = operation[@"type"];
    if (![type isKindOfClass:NSString.class]) return NO;
    if ([type isEqualToString:@"begin"]) {
        NSDictionary *stroke = operation[@"stroke"];
        if (!CRMStroke(stroke) || self.storage.count >= CRMMaxStrokes ||
            self.pointCount + [stroke[@"points"] count] > CRMMaxPoints) return NO;
        for (NSDictionary *existing in self.storage) if ([existing[@"id"] isEqual:stroke[@"id"]]) return NO;
        // 深拷贝网络数据，防止调用方后续修改破坏画布状态。
        NSDictionary *copy = [NSJSONSerialization JSONObjectWithData:[NSJSONSerialization dataWithJSONObject:stroke options:0 error:nil] options:0 error:nil];
        [self.storage addObject:copy];
        self.pointCount += [copy[@"points"] count];
    } else if ([type isEqualToString:@"append"]) {
        NSDictionary *last = self.storage.lastObject;
        NSArray *points = operation[@"points"];
        if (!last || ![last[@"id"] isEqual:operation[@"id"]] || !CRMPoints(points) || self.pointCount + points.count > CRMMaxPoints) return NO;
        NSMutableDictionary *updated = [last mutableCopy];
        NSData *data = [NSJSONSerialization dataWithJSONObject:points options:0 error:nil];
        updated[@"points"] = [last[@"points"] arrayByAddingObjectsFromArray:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
        self.storage[self.storage.count - 1] = updated;
        self.pointCount += points.count;
    } else if ([type isEqualToString:@"undo"]) {
        if (!self.storage.count) return NO;
        self.pointCount -= [self.storage.lastObject[@"points"] count];
        [self.storage removeLastObject];
    } else if ([type isEqualToString:@"clear"]) {
        [self.storage removeAllObjects];
        self.pointCount = 0;
    } else return NO;
    self.revision++;
    return YES;
}
- (NSDictionary *)snapshot {
    return @{@"type": @"snapshot", @"version": @1, @"revision": @(self.revision), @"strokes": self.strokes};
}
- (BOOL)loadSnapshot:(NSDictionary *)snapshot {
    if (![snapshot isKindOfClass:NSDictionary.class] || ![snapshot[@"version"] isEqual:@1] ||
        !CRMInteger(snapshot[@"revision"], 1000000000) || ![snapshot[@"strokes"] isKindOfClass:NSArray.class] ||
        [snapshot[@"strokes"] count] > CRMMaxStrokes) return NO;
    NSUInteger count = 0;
    NSMutableSet *identifiers = [NSMutableSet set];
    for (id stroke in snapshot[@"strokes"]) {
        if (!CRMStroke(stroke) || [identifiers containsObject:stroke[@"id"]]) return NO;
        [identifiers addObject:stroke[@"id"]];
        count += [stroke[@"points"] count];
        if (count > CRMMaxPoints) return NO;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:snapshot[@"strokes"] options:0 error:nil];
    self.storage = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] mutableCopy];
    self.pointCount = count;
    self.revision = [snapshot[@"revision"] unsignedIntegerValue];
    return YES;
}
@end
