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

const podspecTargetPath = path.join(
  __dirname,
  '..',
  'node_modules',
  'react-native-track-player',
  'react-native-track-player.podspec',
)

// SwiftAudioEx 0.14.7 的 QueueManager 没有线程同步，快速切歌时偶发数组越界
// 崩溃；官方 PR #55 已在 1.1.0 通过 NSRecursiveLock 全量加锁修复。因此升级
// 依赖到 1.1.0（原先的「队列索引事件防越界」补丁随之移除），并适配新 API：
// 1. queueIndex 事件更名为 currentItem，负载直接携带曲目与索引，无需再按
//    索引回读 player.items；receiveMetadata 更名为 receiveCommonMetadata，
//    负载类型不变。
// 2. next()/previous() 不再抛出异常，需在调用前手动检查队列边界，以维持
//    JS 侧 queue_exhausted / no_previous_track 的拒绝契约。
if (!fs.existsSync(podspecTargetPath)) {
  throw new Error(`找不到 react-native-track-player podspec：${podspecTargetPath}`)
}

const podspecAnchor = 's.dependency "SwiftAudioEx", "0.14.7"'
const podspecReplacement = 's.dependency "SwiftAudioEx", "1.1.0"'
const podspecSource = fs.readFileSync(podspecTargetPath, 'utf8')
if (podspecSource.includes(podspecReplacement)) {
  console.log('react-native-track-player podspec SwiftAudioEx 1.1.0 补丁已存在')
} else if (podspecSource.includes(podspecAnchor)) {
  fs.writeFileSync(podspecTargetPath, podspecSource.replace(podspecAnchor, podspecReplacement))
  console.log('已应用 react-native-track-player podspec SwiftAudioEx 1.1.0 补丁')
} else {
  throw new Error('react-native-track-player podspec 结构已变化，无法安全应用补丁')
}

if (!fs.existsSync(targetPath)) {
  throw new Error(`找不到 react-native-track-player 源文件：${targetPath}`)
}

const swiftPatches = [
  {
    name: 'SwiftAudioEx 1.1.0 事件监听器注册',
    marker: 'player.event.currentItem.addListener(self, handleAudioPlayerCurrentItemChange)',
    anchor: `        player.event.receiveMetadata.addListener(self, handleAudioPlayerMetadataReceived)
        player.event.stateChange.addListener(self, handleAudioPlayerStateChange)
        player.event.fail.addListener(self, handleAudioPlayerFailed)
        player.event.queueIndex.addListener(self, handleAudioPlayerQueueIndexChange)`,
    replacement: `        player.event.receiveCommonMetadata.addListener(self, handleAudioPlayerMetadataReceived)
        player.event.stateChange.addListener(self, handleAudioPlayerStateChange)
        player.event.fail.addListener(self, handleAudioPlayerFailed)
        player.event.currentItem.addListener(self, handleAudioPlayerCurrentItemChange)`,
  },
  {
    name: 'SwiftAudioEx 1.1.0 队列边界检查',
    marker: 'player.nextItems.isEmpty && player.repeatMode != .queue',
    anchor: `    @objc(skipToNext:rejecter:)
    public func skipToNext(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        print("Skipping to next track")
        do {
            try player.next()
            resolve(NSNull())
        } catch (_) {
            reject("queue_exhausted", "There is no tracks left to play", nil)
        }
    }

    @objc(skipToPrevious:rejecter:)
    public func skipToPrevious(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        print("Skipping to next track")
        do {
            try player.previous()
            resolve(NSNull())
        } catch (_) {
            reject("no_previous_track", "There is no previous track", nil)
        }
    }`,
    replacement: `    @objc(skipToNext:rejecter:)
    public func skipToNext(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        print("Skipping to next track")
        // SwiftAudioEx 1.1.0 起 next()/previous() 不再抛出异常，
        // 必须在调用前手动检查队列边界以维持 JS 侧的拒绝契约。
        if player.nextItems.isEmpty && player.repeatMode != .queue {
            reject("queue_exhausted", "There is no tracks left to play", nil)
            return
        }
        player.next()
        resolve(NSNull())
    }

    @objc(skipToPrevious:rejecter:)
    public func skipToPrevious(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        print("Skipping to next track")
        if player.previousItems.isEmpty && player.repeatMode != .queue {
            reject("no_previous_track", "There is no previous track", nil)
            return
        }
        player.previous()
        resolve(NSNull())
    }`,
  },
  {
    name: 'SwiftAudioEx 1.1.0 单曲循环事件',
    marker: 'handleAudioPlayerCurrentItemChange(item: player.currentItem',
    anchor: `        // fire an event for the same track starting again
        switch player.repeatMode {
        case .track:
            handleAudioPlayerQueueIndexChange(previousIndex: player.currentIndex, nextIndex: player.currentIndex)
        default: break
        }`,
    replacement: `        // fire an event for the same track starting again
        switch player.repeatMode {
        case .track:
            handleAudioPlayerCurrentItemChange(item: player.currentItem, index: player.currentIndex, lastItem: player.currentItem, lastIndex: player.currentIndex, lastPosition: player.currentTime)
        default: break
        }`,
  },
  {
    name: 'SwiftAudioEx 1.1.0 曲目切换事件',
    marker: 'func handleAudioPlayerCurrentItemChange(',
    anchor: `    func handleAudioPlayerQueueIndexChange(previousIndex: Int?, nextIndex: Int?) {
        var dictionary: [String: Any] = [ "position": player.currentTime ]

        if let previousIndex = previousIndex { dictionary["track"] = previousIndex }
        if let nextIndex = nextIndex { dictionary["nextTrack"] = nextIndex }

        // Load isLiveStream option for track
        var isTrackLiveStream = false
        if let nextIndex = nextIndex {
            let track = player.items[nextIndex]
            isTrackLiveStream = (track as? Track)?.isLiveStream ?? false
        }

        if player.automaticallyUpdateNowPlayingInfo {
            player.nowPlayingInfoController.set(keyValue: NowPlayingInfoProperty.isLiveStream(isTrackLiveStream))
        }

        sendEvent(withName: "playback-track-changed", body: dictionary)
    }`,
    replacement: `    // SwiftAudioEx 1.1.0：queueIndex 事件由 currentItem 事件取代，
    // 事件负载直接携带曲目与索引，无需再按索引回读 player.items。
    func handleAudioPlayerCurrentItemChange(item: AudioItem?, index: Int?, lastItem: AudioItem?, lastIndex: Int?, lastPosition: Double?) {
        var dictionary: [String: Any] = [ "position": lastPosition ?? player.currentTime ]

        if let lastIndex = lastIndex { dictionary["track"] = lastIndex }
        if let index = index { dictionary["nextTrack"] = index }

        // Load isLiveStream option for track
        let isTrackLiveStream = (item as? Track)?.isLiveStream ?? false

        if player.automaticallyUpdateNowPlayingInfo {
            player.nowPlayingInfoController.set(keyValue: NowPlayingInfoProperty.isLiveStream(isTrackLiveStream))
        }

        sendEvent(withName: "playback-track-changed", body: dictionary)
    }`,
  },
]

let swiftSource = fs.readFileSync(targetPath, 'utf8')
for (const patch of swiftPatches) {
  if (swiftSource.includes(patch.marker)) {
    console.log(`react-native-track-player ${patch.name}补丁已存在`)
    continue
  }
  if (!swiftSource.includes(patch.anchor)) {
    throw new Error(`react-native-track-player 源码结构已变化，无法安全应用${patch.name}补丁`)
  }
  swiftSource = swiftSource.replace(patch.anchor, patch.replacement)
  console.log(`已应用 react-native-track-player ${patch.name}补丁`)
}
fs.writeFileSync(targetPath, swiftSource)

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
