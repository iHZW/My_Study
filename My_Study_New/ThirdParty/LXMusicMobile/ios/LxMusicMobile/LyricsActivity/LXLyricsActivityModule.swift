import ActivityKit
import Foundation
import React

@objc(LXLyricsActivityModule)
final class LXLyricsActivityModule: NSObject {
  private struct TimelineLine {
    let time: Double
    let text: String
  }

  private struct ActivitySnapshot {
    let songId: String
    let title: String
    let artist: String
    let isPlaying: Bool
    let backgroundColor: String
    let foregroundColor: String
  }

  private var timelineSongId = ""
  private var timelineLines: [TimelineLine] = []
  private var latestSnapshot: ActivitySnapshot?
  private var lastNativeLineIndex = -1
  private let stateLock = NSLock()
  private var activityOperationTask: Task<Void, Never>?

  override init() {
    super.init()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleNativePlaybackProgress(_:)),
      name: Notification.Name("LXLyricsPlaybackProgress"),
      object: nil
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  @objc static func requiresMainQueueSetup() -> Bool {
    false
  }

  @objc(startOrUpdate:title:artist:previousLine:currentLine:nextLine:isPlaying:backgroundColor:foregroundColor:position:playbackRate:resolver:rejecter:)
  func startOrUpdate(
    _ songId: String,
    title: String,
    artist: String,
    previousLine: String,
    currentLine: String,
    nextLine: String,
    isPlaying: Bool,
    backgroundColor: String,
    foregroundColor: String,
    position: Double,
    playbackRate _: Double,
    resolver resolve: @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock
  ) {
    guard #available(iOS 16.1, *) else {
      resolve("unsupported")
      return
    }

    let state = LXLyricsActivityAttributes.ContentState(
      songId: songId,
      title: title,
      artist: artist,
      previousLine: previousLine,
      currentLine: currentLine.isEmpty ? "纯音乐，请欣赏" : currentLine,
      nextLine: nextLine,
      isPlaying: isPlaying,
      backgroundColor: Self.validHexColor(backgroundColor, fallback: "#17191F"),
      foregroundColor: Self.validHexColor(foregroundColor, fallback: "#62D8FF")
    )

    stateLock.lock()
    latestSnapshot = ActivitySnapshot(
      songId: songId,
      title: title,
      artist: artist,
      isPlaying: isPlaying,
      backgroundColor: state.backgroundColor,
      foregroundColor: state.foregroundColor
    )
    lastNativeLineIndex = max(0, (timelineLines.lastIndex { $0.time <= position * 1_000 }) ?? 0)
    stateLock.unlock()

    // ActivityKit 的更新不要求主线程。避免强制切换到 MainActor，防止 App
    // 进入后台后主线程调度暂停，导致歌曲和歌词永久停留在旧状态。
    enqueueActivityOperation {
      if let activity = Activity<LXLyricsActivityAttributes>.activities.first {
        await self.update(activity, state: state)
        resolve("updated")
        return
      }

      // 暂停状态只更新已存在的卡片，不主动创建新的实时活动。
      guard isPlaying else {
        resolve("inactive")
        return
      }
      guard ActivityAuthorizationInfo().areActivitiesEnabled else {
        resolve("disabled")
        return
      }
      do {
        let attributes = LXLyricsActivityAttributes(activityName: "锁屏歌词")
        if #available(iOS 16.2, *) {
          let content = ActivityContent(state: state, staleDate: nil)
          _ = try Activity.request(attributes: attributes, content: content, pushType: nil)
        } else {
          _ = try Activity.request(attributes: attributes, contentState: state, pushType: nil)
        }
        resolve("started")
      } catch {
        NSLog("[锁屏歌词] 创建实时活动失败：%@", error.localizedDescription)
        reject("lyrics_activity_start_failed", error.localizedDescription, error)
      }
    }
  }

  @objc(setTimeline:lines:offset:)
  func setTimeline(_ songId: String, lines: [[String: Any]], offset: Double) {
    let parsedLines = lines.compactMap { line -> TimelineLine? in
      guard let time = (line["time"] as? NSNumber)?.doubleValue,
            let text = line["text"] as? String else { return nil }
      return TimelineLine(time: max(0, time - offset), text: text)
    }.sorted { $0.time < $1.time }

    stateLock.lock()
    timelineSongId = songId
    timelineLines = parsedLines
    lastNativeLineIndex = -1
    stateLock.unlock()
  }

  private static func validHexColor(_ value: String, fallback: String) -> String {
    let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard normalized.range(of: "^#[0-9A-Fa-f]{6}$", options: .regularExpression) != nil else {
      return fallback
    }
    return normalized
  }

  @objc(getAuthorizationStatus:rejecter:)
  func getAuthorizationStatus(
    _ resolve: @escaping RCTPromiseResolveBlock,
    rejecter _: @escaping RCTPromiseRejectBlock
  ) {
    guard #available(iOS 16.1, *) else {
      resolve("unsupported")
      return
    }
    resolve(ActivityAuthorizationInfo().areActivitiesEnabled ? "enabled" : "disabled")
  }

  @objc func end() {
    guard #available(iOS 16.1, *) else { return }
    stateLock.lock()
    latestSnapshot = nil
    lastNativeLineIndex = -1
    stateLock.unlock()
    enqueueActivityOperation {
      for activity in Activity<LXLyricsActivityAttributes>.activities {
        if #available(iOS 16.2, *) {
          await activity.end(nil, dismissalPolicy: .immediate)
        } else {
          await activity.end(using: nil, dismissalPolicy: .immediate)
        }
      }
    }
  }

  @objc private func handleNativePlaybackProgress(_ notification: Notification) {
    guard #available(iOS 16.1, *) else { return }
    handleAvailableNativePlaybackProgress(notification)
  }

  @available(iOS 16.1, *)
  private func handleAvailableNativePlaybackProgress(_ notification: Notification) {
    guard let position = (notification.userInfo?["position"] as? NSNumber)?.doubleValue else { return }
    stateLock.lock()
    guard let snapshot = latestSnapshot,
          snapshot.isPlaying,
          timelineSongId == snapshot.songId,
          !timelineLines.isEmpty else {
      stateLock.unlock()
      return
    }

    let index = max(0, (timelineLines.lastIndex { $0.time <= position * 1_000 }) ?? 0)
    guard index != lastNativeLineIndex else {
      stateLock.unlock()
      return
    }
    lastNativeLineIndex = index
    let state = LXLyricsActivityAttributes.ContentState(
      songId: snapshot.songId,
      title: snapshot.title,
      artist: snapshot.artist,
      previousLine: index > 0 ? timelineLines[index - 1].text : "",
      currentLine: timelineLines[index].text,
      nextLine: index + 1 < timelineLines.count ? timelineLines[index + 1].text : "",
      isPlaying: true,
      backgroundColor: snapshot.backgroundColor,
      foregroundColor: snapshot.foregroundColor
    )
    stateLock.unlock()

    guard let activity = Activity<LXLyricsActivityAttributes>.activities.first else { return }
    enqueueActivityOperation { [weak self] in
      await self?.update(activity, state: state)
    }
  }

  /// ActivityKit 更新严格串行执行，避免快速切歌时旧任务晚于新任务完成，
  /// 导致前台或锁屏重新显示上一句歌词。
  private func enqueueActivityOperation(_ operation: @escaping () async -> Void) {
    stateLock.lock()
    let previousTask = activityOperationTask
    let nextTask = Task {
      await previousTask?.value
      await operation()
    }
    activityOperationTask = nextTask
    stateLock.unlock()
  }

  @available(iOS 16.1, *)
  private func update(
    _ activity: Activity<LXLyricsActivityAttributes>,
    state: LXLyricsActivityAttributes.ContentState
  ) async {
    if #available(iOS 16.2, *) {
      await activity.update(ActivityContent(state: state, staleDate: nil))
    } else {
      await activity.update(using: state)
    }
  }
}
