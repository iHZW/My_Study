#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface LXCacheModule : NSObject <RCTBridgeModule>
@end

@implementation LXCacheModule

RCT_EXPORT_MODULE(CacheModule)

+ (BOOL)requiresMainQueueSetup { return NO; }

- (NSURL *)cacheURL {
  return [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask].firstObject;
}

- (unsigned long long)sizeOfDirectory:(NSURL *)directory {
  NSDirectoryEnumerator<NSURL *> *enumerator = [[NSFileManager defaultManager]
      enumeratorAtURL:directory
      includingPropertiesForKeys:@[NSURLIsRegularFileKey, NSURLFileSizeKey]
      options:NSDirectoryEnumerationSkipsHiddenFiles
      errorHandler:nil];
  unsigned long long size = 0;
  for (NSURL *fileURL in enumerator) {
    NSNumber *isFile = nil;
    NSNumber *fileSize = nil;
    [fileURL getResourceValue:&isFile forKey:NSURLIsRegularFileKey error:nil];
    if (isFile.boolValue && [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil]) {
      size += fileSize.unsignedLongLongValue;
    }
  }
  return size;
}

RCT_REMAP_METHOD(getAppCacheSize, getAppCacheSizeWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  NSURL *directory = [self cacheURL];
  resolve(@([self sizeOfDirectory:directory]));
}

RCT_REMAP_METHOD(clearAppCache, clearAppCacheWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  NSURL *directory = [self cacheURL];
  NSFileManager *manager = [NSFileManager defaultManager];
  NSError *error = nil;
  NSArray<NSURL *> *items = [manager contentsOfDirectoryAtURL:directory
                                  includingPropertiesForKeys:nil options:0 error:&error];
  if (error) {
    reject(@"cache_read_failed", error.localizedDescription, error);
    return;
  }
  for (NSURL *item in items) {
    if (![manager removeItemAtURL:item error:&error]) {
      reject(@"cache_clear_failed", error.localizedDescription, error);
      return;
    }
  }
  resolve(nil);
}

@end
