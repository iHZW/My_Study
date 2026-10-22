#import "CRMNearbyDrawingDocument.h"
#import <assert.h>

static NSDictionary *Begin(NSUInteger revision, NSString *identifier) {
    return @{@"type":@"begin", @"revision":@(revision), @"stroke":@{@"id":identifier, @"color":@0, @"width":@9, @"points":@[@[@0.1,@0.2]]}};
}
int main(void) {
    @autoreleasepool {
        CRMNearbyDrawingDocument *host = [CRMNearbyDrawingDocument new];
        CRMNearbyDrawingDocument *viewer = [CRMNearbyDrawingDocument new];
        assert(([host applyOperation:Begin(1, @"first")]));
        assert((![host applyOperation:Begin(1, @"duplicate-revision")]));
        assert(([viewer loadSnapshot:host.snapshot]));
        NSDictionary *append = @{@"type":@"append", @"revision":@2, @"id":@"first", @"points":@[@[@0.5,@0.8], @[@1,@1]]};
        assert(([host applyOperation:append] && [viewer applyOperation:append]));
        assert(([host.snapshot isEqual:viewer.snapshot]));
        assert((![viewer applyOperation:Begin(4,@"out-of-order")]));
        assert((viewer.revision == 2));
        assert(([host applyOperation:Begin(3,@"second")]));
        assert(([viewer loadSnapshot:host.snapshot]));
        assert(([host.snapshot isEqual:viewer.snapshot]));
        assert(([host applyOperation:@{@"type":@"undo", @"revision":@4}]));
        assert((host.strokes.count == 1 && host.pointCount == 3));
        NSDictionary *good = host.snapshot;
        for (id invalid in @[@[], @{@"version":@1,@"revision":@-1,@"strokes":@[]},
                             @{@"version":@1,@"revision":@4,@"strokes":@[@{@"id":@"x",@"color":@100,@"width":@9,@"points":@[@[@0,@0]]}]}]) {
            assert((![host loadSnapshot:invalid]));
            assert(([host.snapshot isEqual:good]));
        }
        assert((![host applyOperation:@{@"type":@"append",@"revision":@5,@"id":@"first",@"points":@[@[@2,@0]]}]));
        assert((![host applyOperation:@{@"type":@"append",@"revision":@5,@"id":@"wrong",@"points":@[@[@0,@0]]}]));
        assert((![host applyOperation:@{@"type":@"append",@"revision":@5,@"id":@"first",@"points":@[@[@YES,@0]]}]));
        assert(([host applyOperation:@{@"type":@"clear",@"revision":@5}]));
        assert((host.pointCount == 0 && host.strokes.count == 0));
        assert((![host applyOperation:@{@"type":@"undo",@"revision":@6}]));
        assert(([host applyOperation:Begin(6,@"capacity")]));
        NSMutableArray *points = [NSMutableArray array];
        for (NSUInteger i = 0; i < 19999; i++) [points addObject:@[@0.5,@0.5]];
        assert(([host applyOperation:@{@"type":@"append",@"revision":@7,@"id":@"capacity",@"points":points}]));
        assert((![host applyOperation:Begin(8,@"overflow")]));
        assert(([viewer loadSnapshot:host.snapshot]));
        assert((viewer.pointCount == 20000));
        NSData *wire = [NSJSONSerialization dataWithJSONObject:host.snapshot options:0 error:nil];
        assert((wire.length < 2 * 1024 * 1024));
        assert(([viewer loadSnapshot:[NSJSONSerialization JSONObjectWithData:wire options:0 error:nil]]));
        for (NSUInteger i = 0; i < 500; i++) {
            if (i == 0) assert(([host applyOperation:@{@"type":@"clear",@"revision":@8}]));
            assert(([host applyOperation:Begin(9+i, [NSString stringWithFormat:@"%lu", (unsigned long)i])]));
        }
        assert((![host applyOperation:Begin(509,@"stroke-overflow")]));
        NSLog(@"通过：笔迹同步、断线快照恢复、乱序检测、撤销清空、非法消息及画布容量边界。");
    }
}
