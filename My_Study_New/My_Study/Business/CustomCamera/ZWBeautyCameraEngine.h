#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

/// 采集、美颜与编码均在串行队列运行，界面只消费最新一帧。
@interface ZWBeautyCameraEngine : NSObject
@property (atomic, strong, readonly, nullable) CIImage *previewImage;
@property (nonatomic, strong, readonly) CIContext *context;
@property (nonatomic, strong, readonly) id<MTLDevice> device;
@property (atomic) CGFloat smoothing;
@property (atomic) CGFloat whitening;
@property (atomic) CGFloat rosiness;
@property (atomic) CGFloat clarity;
@property (atomic) NSInteger filterIndex;
@property (atomic) BOOL original;
@property (atomic) CGFloat outputAspectRatio;
@property (atomic) NSTimeInterval maximumDuration;
@property (atomic, readonly) NSUInteger detectedFaceCount;
@property (atomic, readonly) BOOL torchEnabled;
@property (nonatomic, copy, nullable) void (^statusHandler)(NSString *message, BOOL ready);
@property (nonatomic, copy, nullable) void (^recordingHandler)(BOOL recording);
@property (nonatomic, copy, nullable) void (^movieHandler)(NSURL * _Nullable url, NSError * _Nullable error);
- (void)start;
- (void)stop;
- (void)switchCamera;
- (void)toggleTorch;
- (void)setZoom:(CGFloat)zoom;
- (void)takePhoto:(void (^)(UIImage * _Nullable image))completion;
- (void)startRecording;
- (void)finishRecording;
@end

NS_ASSUME_NONNULL_END
