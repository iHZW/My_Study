#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

int main(void) {
  @autoreleasepool {
    NSString *path = @"ios/LXMusicNative/Resources/user-api-preload.js";
    NSString *preload = [NSString stringWithContentsOfFile:path
                                                 encoding:NSUTF8StringEncoding error:nil];
    NSCAssert(preload.length > 0, @"音源预载脚本缺失");
    __block NSString *initAction = nil;
    __block NSString *initData = nil;
    __block NSString *exceptionText = nil;
    NSLog(@"开始创建 JavaScriptCore 上下文");
    JSContext *context = [[JSContext alloc] init];
    NSLog(@"JavaScriptCore 上下文创建完成");
    context.exceptionHandler = ^(JSContext *jsContext, JSValue *exception) {
      exceptionText = [exception toString];
    };
    context[@"console"] = @{ @"log": ^(JSValue *value) {} };
    context[@"__lx_native_call__"] = ^(NSString *key, NSString *action, NSString *data) {
      if (![key isEqualToString:@"test-key"]) return;
      initAction = action;
      initData = data;
    };
    context[@"__lx_native_call__set_timeout"] = ^(NSNumber *identifier, NSNumber *delay) {};
    context[@"__lx_native_call__utils_str2b64"] = ^NSString *(NSString *value) { return value; };
    context[@"__lx_native_call__utils_b642buf"] = ^NSString *(NSString *value) { return @"[]"; };
    context[@"__lx_native_call__utils_str2md5"] = ^NSString *(NSString *value) { return @""; };
    context[@"__lx_native_call__utils_aes_encrypt"] = ^NSString *(NSString *text, NSString *key,
                                                                   NSString *iv, NSString *mode) { return @""; };
    context[@"__lx_native_call__utils_rsa_encrypt"] = ^NSString *(NSString *text, NSString *key,
                                                                   NSString *padding) { return @""; };
    NSLog(@"开始载入音源预载脚本");
    [context evaluateScript:preload];
    NSCAssert(!exceptionText, @"预载脚本失败：%@", exceptionText);
    NSLog(@"开始初始化音源环境");
    [context[@"lx_setup"] callWithArguments:@[@"test-key", @"test-id", @"测试源", @"", @"", @"", @"", @""]];
    NSCAssert(!exceptionText, @"音源环境初始化失败：%@", exceptionText);
    NSLog(@"开始执行音源脚本");
    [context evaluateScript:@"lx.send(lx.EVENT_NAMES.inited, { sources: {} })"];
    NSCAssert(!exceptionText, @"音源脚本执行失败：%@", exceptionText);
    NSCAssert([initAction isEqualToString:@"init"] && [initData containsString:@"\"status\":true"],
              @"音源初始化事件未返回");
    NSLog(@"LX UserApi 冒烟测试通过");
  }
  return 0;
}
