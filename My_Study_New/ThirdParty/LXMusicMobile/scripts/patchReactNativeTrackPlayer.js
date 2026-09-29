const fs = require('fs')
const path = require('path')

const targetPath = path.join(
  __dirname,
  '..',
  'node_modules',
  'react-native-track-player',
  'ios',
  'RNTrackPlayer',
  'RNTrackPlayer.swift',
)

const jsTargetPath = path.join(
  __dirname,
  '..',
  'node_modules',
  'react-native-track-player',
  'lib',
  'trackPlayer.js',
)

const webSocketTargetPath = path.join(
  __dirname,
  '..',
  'node_modules',
  'react-native',
  'React',
  'CoreModules',
  'RCTWebSocketModule.mm',
)

const marker = '// SwiftAudioEx 会异步派发队列索引事件。'
const anchor = `    func handleAudioPlayerQueueIndexChange(previousIndex: Int?, nextIndex: Int?) {
        var dictionary: [String: Any] = [ "position": player.currentTime ]`
const replacement = `    func handleAudioPlayerQueueIndexChange(previousIndex: Int?, nextIndex: Int?) {
        ${marker}清理旧曲目后，先前排队的事件
        // 可能携带已经失效的索引；必须在读取 player.items 前丢弃该事件。
        if let nextIndex = nextIndex,
           (nextIndex != player.currentIndex || !player.items.indices.contains(nextIndex)) {
            return
        }

        var dictionary: [String: Any] = [ "position": player.currentTime ]`

if (!fs.existsSync(targetPath)) {
  throw new Error(`找不到 react-native-track-player 源文件：${targetPath}`)
}

const source = fs.readFileSync(targetPath, 'utf8')
if (source.includes(marker)) {
  console.log('react-native-track-player iOS 队列边界补丁已存在')
} else if (source.includes(anchor)) {
  fs.writeFileSync(targetPath, source.replace(anchor, replacement))
  console.log('已应用 react-native-track-player iOS 队列边界补丁')
} else {
  throw new Error('react-native-track-player 源码结构已变化，无法安全应用补丁')
}

// Metro Reload 会销毁旧 React Bridge，但 SwiftAudioEx 的后台队列可能仍有
// 已排队的播放器事件。旧模块此时直接调用 sendEvent 会因为
// RCTCallableJSModules 已清空而触发 NSInternalInconsistencyException。
// 所有事件统一切回主线程，并在存在 JS 监听器时才发送。
const eventMarker = '// React Bridge 生命周期保护。'
const eventAnchor = `    private var hasInitialized = false
    private let player = QueuedAudioPlayer()`
const eventGuard = `    ${eventMarker}
    private var canSendEvents = false

    public override func startObserving() {
        super.startObserving()
        canSendEvents = true
    }

    public override func stopObserving() {
        canSendEvents = false
        super.stopObserving()
    }

    private func sendEventIfReady(withName name: String, body: Any?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.canSendEvents, self.bridge != nil else { return }
            self.sendEvent(withName: name, body: body)
        }
    }`

let eventSource = fs.readFileSync(targetPath, 'utf8')
if (eventSource.includes(eventMarker)) {
  console.log('react-native-track-player React Bridge 生命周期补丁已存在')
} else if (eventSource.includes(eventAnchor)) {
  eventSource = eventSource.replaceAll('sendEvent(withName:', 'sendEventIfReady(withName:')
  eventSource = eventSource.replace(eventAnchor, `${eventAnchor}\n\n${eventGuard}`)
  fs.writeFileSync(targetPath, eventSource)
  console.log('已应用 react-native-track-player React Bridge 生命周期补丁')
} else {
  throw new Error('react-native-track-player 源码结构已变化，无法安全应用 Bridge 生命周期补丁')
}

// 当前分叉版本的 Android 原生方法接收 metadata 与 playing 两个参数，
// 但 iOS 原生桥接只接收 metadata。公共 JS 包装器无条件传两个参数会触发
// RCTModuleMethod 参数数量异常，因此按平台调用对应签名。
const jsMarker = "react_native_1.Platform.OS === 'ios'"
const jsAnchor = '    return TrackPlayer.updateNowPlayingMetadata(metadata, playing);'
const jsReplacement = `    return ${jsMarker}
        ? TrackPlayer.updateNowPlayingMetadata(metadata)
        : TrackPlayer.updateNowPlayingMetadata(metadata, playing);`

if (!fs.existsSync(jsTargetPath)) {
  throw new Error(`找不到 react-native-track-player JS 文件：${jsTargetPath}`)
}

const jsSource = fs.readFileSync(jsTargetPath, 'utf8')
let patchedJsSource = jsSource
if (patchedJsSource.includes(jsMarker)) {
  console.log('react-native-track-player iOS 元数据参数补丁已存在')
} else if (patchedJsSource.includes(jsAnchor)) {
  patchedJsSource = patchedJsSource.replace(jsAnchor, jsReplacement)
  console.log('已应用 react-native-track-player iOS 元数据参数补丁')
} else {
  throw new Error('react-native-track-player JS 源码结构已变化，无法安全应用元数据参数补丁')
}

// Android 原生层以毫秒返回进度数据，而 SwiftAudioEx 的 iOS 原生层已经以秒
// 返回。公共包装器无条件除以 1000 会导致 iOS 时长和进度缩小 1000 倍。
const timeUnitMarker = "react_native_1.Platform.OS === 'ios' ? (_a.sent())"
const timeUnitAnchor = 'case 1: return [2 /*return*/, (_a.sent()) / 1000];'
const timeUnitReplacement = "case 1: return [2 /*return*/, react_native_1.Platform.OS === 'ios' ? (_a.sent()) : (_a.sent()) / 1000];"

if (patchedJsSource.includes(timeUnitMarker)) {
  console.log('react-native-track-player iOS 时间单位补丁已存在')
} else {
  const matches = patchedJsSource.split(timeUnitAnchor).length - 1
  if (matches !== 3) {
    throw new Error(`react-native-track-player 时间单位源码结构已变化，预期 3 处，实际 ${matches} 处`)
  }
  patchedJsSource = patchedJsSource.replaceAll(timeUnitAnchor, timeUnitReplacement)
  console.log('已应用 react-native-track-player iOS 时间单位补丁')
}

if (patchedJsSource !== jsSource) fs.writeFileSync(jsTargetPath, patchedJsSource)

// React Bridge 失效时，SocketRocket 主队列中可能仍留有已排队的回调。
// 这些回调继续 sendEvent 会因 RCTCallableJSModules 已清空而触发断言崩溃。
const webSocketMarker = 'BOOL _isInvalidated; // React Bridge 生命周期保护'
if (!fs.existsSync(webSocketTargetPath)) {
  throw new Error(`找不到 React Native WebSocket 文件：${webSocketTargetPath}`)
}

let webSocketSource = fs.readFileSync(webSocketTargetPath, 'utf8')
if (webSocketSource.includes(webSocketMarker)) {
  console.log('React Native WebSocket Bridge 生命周期补丁已存在')
} else {
  const ivarAnchor = '  NSMutableDictionary<NSNumber *, id<RCTWebSocketContentHandler>> *_contentHandlers;'
  const invalidateAnchor = `- (void)invalidate
{
  [super invalidate];`
  const callbackAnchors = [
    `- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{`,
    `- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{`,
    `- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{`,
    `- (void)webSocket:(SRWebSocket *)webSocket
    didCloseWithCode:(NSInteger)code
              reason:(NSString *)reason
            wasClean:(BOOL)wasClean
{`,
  ]
  if (!webSocketSource.includes(ivarAnchor) || !webSocketSource.includes(invalidateAnchor) || callbackAnchors.some(anchor => !webSocketSource.includes(anchor))) {
    throw new Error('React Native WebSocket 源码结构已变化，无法安全应用 Bridge 生命周期补丁')
  }
  webSocketSource = webSocketSource.replace(ivarAnchor, `${ivarAnchor}\n  ${webSocketMarker}`)
  webSocketSource = webSocketSource.replace(invalidateAnchor, '- (void)invalidate\n{\n  _isInvalidated = YES;\n  [super invalidate];')
  for (const anchor of callbackAnchors) {
    webSocketSource = webSocketSource.replace(anchor, `${anchor}\n  if (_isInvalidated) { return; }`)
  }
  fs.writeFileSync(webSocketTargetPath, webSocketSource)
  console.log('已应用 React Native WebSocket Bridge 生命周期补丁')
}
