#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <CommonCrypto/CommonDigest.h>
#import <React/RCTEventEmitter.h>
#import "LXCrypto.h"

@interface LXUserApiModule : RCTEventEmitter
@property (nonatomic, strong) JSContext *context;
@property (nonatomic, copy) NSString *sessionKey;
@property (nonatomic, assign) NSUInteger generation;
@property (nonatomic, strong) dispatch_queue_t scriptQueue;
@property (nonatomic, assign) BOOL initialized;
@end

@implementation LXUserApiModule

RCT_EXPORT_MODULE(UserApiModule)

+ (BOOL)requiresMainQueueSetup { return NO; }

- (instancetype)init {
  self = [super init];
  if (self) {
    _scriptQueue = dispatch_queue_create("cn.toside.lxmusic.ios.userapi", DISPATCH_QUEUE_SERIAL);
  }
  return self;
}

- (NSArray<NSString *> *)supportedEvents { return @[@"api-action"]; }

- (void)emitAction:(NSString *)action data:(NSString *)data {
  if ([action isEqualToString:@"init"]) {
    if (self.initialized) return;
    self.initialized = YES;
  }
  [self sendEventWithName:@"api-action" body:@{ @"action": action ?: @"",
                                           @"data": data ?: @"null" }];
}

- (void)emitError:(NSString *)message {
  NSString *safeMessage = message.length > 1024 ? [message substringToIndex:1024] : (message ?: @"脚本执行失败");
  [self sendEventWithName:@"api-action" body:@{ @"action": @"log", @"type": @"error",
                                           @"log": safeMessage }];
}

- (void)emitInitFailure:(NSString *)message {
  if (self.initialized) return;
  NSDictionary *data = @{ @"info": [NSNull null], @"status": @NO,
                          @"errorMessage": message ?: @"脚本初始化失败" };
  NSData *json = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
  [self emitAction:@"init" data:[[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]];
  [self emitError:message];
}

- (NSString *)md5OfURLEncodedString:(NSString *)encoded {
  NSString *decoded = encoded.stringByRemovingPercentEncoding ?: encoded;
  NSData *data = [decoded dataUsingEncoding:NSUTF8StringEncoding];
  unsigned char digest[CC_MD5_DIGEST_LENGTH];
  CC_MD5(data.bytes, (CC_LONG)data.length, digest);
  NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
  for (NSUInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) [result appendFormat:@"%02x", digest[i]];
  return result;
}

- (void)installFunctionsIntoContext:(JSContext *)context generation:(NSUInteger)generation {
  __weak typeof(self) weakSelf = self;
  context[@"console"] = @{ @"log": ^(JSValue *value) {},
                            @"error": ^(JSValue *value) {
    [weakSelf emitError:[value toString]];
  } };
  context[@"__lx_native_call__"] = ^(NSString *key, NSString *action, NSString *data) {
    typeof(self) strongSelf = weakSelf;
    if (!strongSelf || generation != strongSelf.generation ||
        ![key isEqualToString:strongSelf.sessionKey]) return;
    [strongSelf emitAction:action data:data];
  };
  context[@"__lx_native_call__utils_str2b64"] = ^NSString *(NSString *value) {
    return [[value dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
  };
  context[@"__lx_native_call__utils_b642buf"] = ^NSString *(NSString *value) {
    NSData *decoded = [[NSData alloc] initWithBase64EncodedString:value options:0];
    if (!decoded) return @"";
    NSMutableArray<NSNumber *> *bytes = [NSMutableArray arrayWithCapacity:decoded.length];
    const int8_t *raw = decoded.bytes;
    for (NSUInteger i = 0; i < decoded.length; i++) [bytes addObject:@(raw[i])];
    NSData *json = [NSJSONSerialization dataWithJSONObject:bytes options:0 error:nil];
    return [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding] ?: @"";
  };
  context[@"__lx_native_call__utils_str2md5"] = ^NSString *(NSString *value) {
    return [weakSelf md5OfURLEncodedString:value];
  };
  context[@"__lx_native_call__utils_aes_encrypt"] = ^NSString *(NSString *text,
                                                                   NSString *key,
                                                                   NSString *iv,
                                                                   NSString *mode) {
    return LXAES(text, key, iv, mode, YES);
  };
  context[@"__lx_native_call__utils_rsa_encrypt"] = ^NSString *(NSString *text,
                                                                   NSString *key,
                                                                   NSString *padding) {
    return LXRSA(text, key, padding, YES);
  };
  context[@"__lx_native_call__set_timeout"] = ^(NSNumber *identifier, NSNumber *delay) {
    NSInteger milliseconds = MAX(0, MIN(delay.integerValue, 3600000));
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)milliseconds * NSEC_PER_MSEC),
                   weakSelf.scriptQueue, ^{
      typeof(self) strongSelf = weakSelf;
      if (!strongSelf || generation != strongSelf.generation) return;
      [strongSelf callScript:@"__set_timeout__" info:[identifier stringValue]];
    });
  };
}

- (NSString *)preloadScript {
  NSURL *bundleURL = [[NSBundle bundleForClass:self.class] URLForResource:@"LXMusicNative" withExtension:@"bundle"];
  NSBundle *bundle = bundleURL ? [NSBundle bundleWithURL:bundleURL] : nil;
  NSURL *scriptURL = [bundle URLForResource:@"user-api-preload" withExtension:@"js"];
  return scriptURL ? [NSString stringWithContentsOfURL:scriptURL
                                             encoding:NSUTF8StringEncoding error:nil] : nil;
}

- (void)callScript:(NSString *)action info:(NSString *)info {
  JSValue *function = self.context[@"__lx_native__"];
  if (!function || function.isUndefined) return;
  [function callWithArguments:@[self.sessionKey ?: @"", action ?: @"", info ?: [NSNull null]]];
  if (self.context.exception) {
    [self emitError:[self.context.exception toString]];
    self.context.exception = nil;
  }
}

RCT_EXPORT_METHOD(loadScript:(NSDictionary *)scriptInfo) {
  NSDictionary *info = [scriptInfo copy];
  dispatch_async(self.scriptQueue, ^{
    self.generation++;
    self.initialized = NO;
    self.context = nil;
    self.sessionKey = NSUUID.UUID.UUIDString;
    NSUInteger generation = self.generation;
    NSString *preload = [self preloadScript];
    if (!preload) {
      [self emitInitFailure:@"iOS 自定义音源预载脚本缺失"];
      return;
    }
    JSContext *context = [[JSContext alloc] init];
    self.context = context;
    __weak typeof(self) weakSelf = self;
    context.exceptionHandler = ^(JSContext *jsContext, JSValue *exception) {
      [weakSelf emitError:[exception toString]];
    };
    [self installFunctionsIntoContext:context generation:generation];
    [context evaluateScript:preload withSourceURL:[NSURL URLWithString:@"lx://user-api-preload.js"]];
    JSValue *setup = context[@"lx_setup"];
    if (!setup || setup.isUndefined) {
      [self emitInitFailure:@"iOS 自定义音源环境初始化失败"];
      return;
    }
    [setup callWithArguments:@[self.sessionKey,
                               info[@"id"] ?: @"", info[@"name"] ?: @"Unknown",
                               info[@"description"] ?: @"", info[@"version"] ?: @"",
                               info[@"author"] ?: @"", info[@"homepage"] ?: @"",
                               info[@"script"] ?: @""]];
    [context evaluateScript:info[@"script"] ?: @""
             withSourceURL:[NSURL URLWithString:@"lx://user-source.js"]];
    if (context.exception && !self.initialized) {
      [self emitInitFailure:[context.exception toString]];
      context.exception = nil;
    }
  });
}

RCT_EXPORT_METHOD(sendAction:(NSString *)action info:(NSString *)info) {
  dispatch_async(self.scriptQueue, ^{ [self callScript:action info:info]; });
}

RCT_EXPORT_METHOD(destroy) {
  dispatch_async(self.scriptQueue, ^{
    self.generation++;
    self.context = nil;
    self.sessionKey = nil;
    self.initialized = NO;
  });
}

@end
