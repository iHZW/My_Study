#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(LXLyricsActivityModule, NSObject)

RCT_EXTERN_METHOD(startOrUpdate:(NSString *)songId
                  title:(NSString *)title
                  artist:(NSString *)artist
                  previousLine:(NSString *)previousLine
                  currentLine:(NSString *)currentLine
                  nextLine:(NSString *)nextLine
                  isPlaying:(BOOL)isPlaying
                  backgroundColor:(NSString *)backgroundColor
                  foregroundColor:(NSString *)foregroundColor
                  position:(double)position
                  playbackRate:(double)playbackRate
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(setTimeline:(NSString *)songId
                  lines:(NSArray *)lines
                  offset:(double)offset)

RCT_EXTERN_METHOD(getAuthorizationStatus:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(end)

@end
