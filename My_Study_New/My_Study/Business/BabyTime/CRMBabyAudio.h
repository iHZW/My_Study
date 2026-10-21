#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT NSNotificationName const CRMBabyAudioChanged;
@interface CRMBabyAudio : NSObject
@property (nonatomic, readonly) NSString *status;
@property (nonatomic, readonly) BOOL recording;
@property (nonatomic, readonly) BOOL playing;
@property (nonatomic, readonly) NSTimeInterval remaining;
+ (instancetype)shared;
- (void)playURL:(NSURL *)url title:(NSString *)title;
- (void)togglePause;
- (void)stop;
- (void)startRecording;
- (void)setSleepMinutes:(NSInteger)minutes;
@end
NS_ASSUME_NONNULL_END
