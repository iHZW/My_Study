#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTUtils.h>

@interface LXDocumentPickerModule : NSObject <RCTBridgeModule, UIDocumentPickerDelegate>
@property (nonatomic, copy) RCTPromiseResolveBlock resolve;
@property (nonatomic, copy) RCTPromiseRejectBlock reject;
@property (nonatomic, strong) UIDocumentPickerViewController *picker;
@end

@implementation LXDocumentPickerModule

RCT_EXPORT_MODULE(LXDocumentPickerModule)

+ (BOOL)requiresMainQueueSetup { return YES; }

RCT_REMAP_METHOD(pickFile, pickFile:(BOOL)multi resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.picker) {
      reject(@"picker_busy", @"文件选择器已打开", nil);
      return;
    }
    UIViewController *controller = RCTPresentedViewController();
    if (!controller) {
      reject(@"picker_unavailable", @"无法打开文件选择器", nil);
      return;
    }
    self.resolve = resolve;
    self.reject = reject;
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc]
        initWithDocumentTypes:@[@"public.item"] inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    picker.allowsMultipleSelection = multi;
    self.picker = picker;
    [controller presentViewController:picker animated:YES completion:nil];
  });
}

- (void)finishWithError:(NSError *)error path:(NSString *)path {
  if (error) self.reject(@"file_import_failed", error.localizedDescription, error);
  else self.resolve(@{ @"path": path ?: @"" });
  self.resolve = nil;
  self.reject = nil;
  self.picker = nil;
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller
    didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
  NSURL *source = urls.firstObject;
  if (!source) {
    [self finishWithError:[NSError errorWithDomain:@"LXDocumentPicker" code:1
                                        userInfo:@{NSLocalizedDescriptionKey: @"未选择文件"}] path:nil];
    return;
  }
  BOOL scoped = [source startAccessingSecurityScopedResource];
  NSFileManager *manager = [NSFileManager defaultManager];
  NSURL *cache = [manager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask].firstObject;
  NSURL *folder = [[cache URLByAppendingPathComponent:@"LXImportedFiles" isDirectory:YES]
      URLByAppendingPathComponent:NSUUID.UUID.UUIDString isDirectory:YES];
  NSError *error = nil;
  [manager createDirectoryAtURL:folder withIntermediateDirectories:YES attributes:nil error:&error];
  NSURL *target = [folder URLByAppendingPathComponent:source.lastPathComponent ?: @"imported-file"];
  if (!error) [manager copyItemAtURL:source toURL:target error:&error];
  if (scoped) [source stopAccessingSecurityScopedResource];
  [self finishWithError:error path:target.path];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
  self.reject(@"picker_cancelled", @"用户取消了文件选择", nil);
  self.resolve = nil;
  self.reject = nil;
  self.picker = nil;
}

@end
