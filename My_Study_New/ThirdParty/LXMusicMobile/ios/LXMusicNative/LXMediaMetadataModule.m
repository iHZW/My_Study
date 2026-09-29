#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <React/RCTBridgeModule.h>

@interface LXMediaMetadataModule : NSObject <RCTBridgeModule>
@end

@implementation LXMediaMetadataModule

RCT_EXPORT_MODULE(LXMediaMetadataModule)

+ (BOOL)requiresMainQueueSetup { return NO; }

- (NSString *)metadataPath:(NSString *)path { return [path stringByAppendingString:@".lxmeta.json"]; }
- (NSString *)lyricPath:(NSString *)path {
  return [[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"lrc"];
}
- (NSString *)coverPath:(NSString *)path extension:(NSString *)extension {
  return [[path stringByAppendingString:@".lxcover"] stringByAppendingPathExtension:extension];
}

- (NSString *)metadataValue:(NSString *)key asset:(AVAsset *)asset {
  for (AVMetadataItem *item in asset.commonMetadata) {
    if ([item.commonKey isEqualToString:key] && [item.value isKindOfClass:NSString.class]) {
      return (NSString *)item.value;
    }
  }
  return @"";
}

- (NSDictionary *)sidecarMetadata:(NSString *)path {
  NSData *data = [NSData dataWithContentsOfFile:[self metadataPath:path]];
  if (!data) return @{};
  id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  return [result isKindOfClass:NSDictionary.class] ? result : @{};
}

RCT_REMAP_METHOD(readMetadata, readMetadata:(NSString *)path resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
    resolve(nil);
    return;
  }
  AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
  NSString *extension = path.pathExtension.lowercaseString;
  NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
  AVAssetTrack *audio = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
  double duration = CMTimeGetSeconds(asset.duration);
  if (!isfinite(duration)) duration = 0;
  NSMutableDictionary *result = [@{
    @"name": [self metadataValue:@"title" asset:asset].length
        ? [self metadataValue:@"title" asset:asset] : path.lastPathComponent.stringByDeletingPathExtension,
    @"singer": [self metadataValue:@"artist" asset:asset],
    @"albumName": [self metadataValue:@"albumName" asset:asset],
    @"interval": @(duration),
    @"bitrate": audio ? [NSString stringWithFormat:@"%.0f", audio.estimatedDataRate / 1000.0] : @"0",
    @"type": extension,
    @"ext": extension,
    @"size": attributes[NSFileSize] ?: @0,
  } mutableCopy];
  [result addEntriesFromDictionary:[self sidecarMetadata:path]];
  resolve(result);
}

RCT_REMAP_METHOD(writeMetadata, writeMetadata:(NSString *)path metadata:(NSDictionary *)metadata
                 overwrite:(BOOL)overwrite resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
    reject(@"file_not_found", @"音频文件不存在", nil);
    return;
  }
  NSMutableDictionary *data = overwrite ? [NSMutableDictionary dictionary]
                                        : [[self sidecarMetadata:path] mutableCopy];
  for (NSString *key in @[@"name", @"singer", @"albumName"]) {
    if ([metadata[key] isKindOfClass:NSString.class]) data[key] = metadata[key];
  }
  NSError *error = nil;
  NSData *json = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
  if (json && [json writeToFile:[self metadataPath:path] options:NSDataWritingAtomic error:&error]) {
    resolve(nil);
  } else reject(@"metadata_write_failed", error.localizedDescription, error);
}

RCT_REMAP_METHOD(readPic, readPic:(NSString *)path directory:(NSString *)directory
                 resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  for (NSString *extension in @[@"jpg", @"jpeg", @"png", @"webp"]) {
    NSString *sidecar = [self coverPath:path extension:extension];
    if ([[NSFileManager defaultManager] fileExistsAtPath:sidecar]) {
      resolve(sidecar);
      return;
    }
  }
  AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
  NSData *artwork = nil;
  for (AVMetadataItem *item in asset.commonMetadata) {
    if ([item.commonKey isEqualToString:@"artwork"] && [item.value isKindOfClass:NSData.class]) {
      artwork = (NSData *)item.value;
      break;
    }
  }
  if (!artwork) {
    resolve(@"");
    return;
  }
  NSError *error = nil;
  [[NSFileManager defaultManager] createDirectoryAtPath:directory
                            withIntermediateDirectories:YES attributes:nil error:&error];
  NSString *target = [directory stringByAppendingPathComponent:
      [[path.lastPathComponent stringByAppendingString:@".artwork"] stringByAppendingPathExtension:@"jpg"]];
  if (!error && [artwork writeToFile:target options:NSDataWritingAtomic error:&error]) resolve(target);
  else reject(@"artwork_read_failed", error.localizedDescription, error);
}

RCT_REMAP_METHOD(writePic, writePic:(NSString *)path picture:(NSString *)picture
                 resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  NSString *extension = picture.pathExtension.lowercaseString;
  if (![@[@"jpg", @"jpeg", @"png", @"webp"] containsObject:extension]) extension = @"jpg";
  NSString *target = [self coverPath:path extension:extension];
  NSError *error = nil;
  [[NSFileManager defaultManager] removeItemAtPath:target error:nil];
  if ([[NSFileManager defaultManager] copyItemAtPath:picture toPath:target error:&error]) resolve(nil);
  else reject(@"artwork_write_failed", error.localizedDescription, error);
}

RCT_REMAP_METHOD(readLyric, readLyric:(NSString *)path readFile:(BOOL)readFile
                 resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  if (readFile) {
    NSString *sidecar = [NSString stringWithContentsOfFile:[self lyricPath:path]
                                                 encoding:NSUTF8StringEncoding error:nil];
    if (sidecar.length) {
      resolve(sidecar);
      return;
    }
  }
  AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
  resolve([self metadataValue:@"lyrics" asset:asset]);
}

RCT_REMAP_METHOD(writeLyric, writeLyric:(NSString *)path lyric:(NSString *)lyric
                 resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  NSError *error = nil;
  if ([lyric writeToFile:[self lyricPath:path] atomically:YES
               encoding:NSUTF8StringEncoding error:&error]) resolve(nil);
  else reject(@"lyric_write_failed", error.localizedDescription, error);
}

@end
