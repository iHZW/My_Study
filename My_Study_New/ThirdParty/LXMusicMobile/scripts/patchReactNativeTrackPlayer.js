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
