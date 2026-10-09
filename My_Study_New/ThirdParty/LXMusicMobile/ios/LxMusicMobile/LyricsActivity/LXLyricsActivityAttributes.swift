import ActivityKit
import Foundation

@available(iOS 16.1, *)
struct LXLyricsActivityAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable {
    let songId: String
    let title: String
    let artist: String
    let previousLine: String
    let currentLine: String
    let nextLine: String
    let isPlaying: Bool
    let backgroundColor: String
    let foregroundColor: String

    private enum CodingKeys: String, CodingKey {
      case songId, title, artist, previousLine, currentLine, nextLine, isPlaying
      case backgroundColor, foregroundColor
    }

    init(
      songId: String,
      title: String,
      artist: String,
      previousLine: String,
      currentLine: String,
      nextLine: String,
      isPlaying: Bool,
      backgroundColor: String,
      foregroundColor: String
    ) {
      self.songId = songId
      self.title = title
      self.artist = artist
      self.previousLine = previousLine
      self.currentLine = currentLine
      self.nextLine = nextLine
      self.isPlaying = isPlaying
      self.backgroundColor = backgroundColor
      self.foregroundColor = foregroundColor
    }

    init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      songId = try values.decode(String.self, forKey: .songId)
      title = try values.decode(String.self, forKey: .title)
      artist = try values.decode(String.self, forKey: .artist)
      previousLine = try values.decode(String.self, forKey: .previousLine)
      currentLine = try values.decode(String.self, forKey: .currentLine)
      nextLine = try values.decode(String.self, forKey: .nextLine)
      isPlaying = try values.decode(Bool.self, forKey: .isPlaying)
      // 保留升级前已创建的实时活动，缺少颜色字段时使用默认配色。
      backgroundColor = try values.decodeIfPresent(String.self, forKey: .backgroundColor) ?? "#17191F"
      foregroundColor = try values.decodeIfPresent(String.self, forKey: .foregroundColor) ?? "#62D8FF"
    }

    func updatingLyrics(previousLine: String, currentLine: String, nextLine: String) -> Self {
      Self(
        songId: songId,
        title: title,
        artist: artist,
        previousLine: previousLine,
        currentLine: currentLine,
        nextLine: nextLine,
        isPlaying: isPlaying,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor
      )
    }
  }

  let activityName: String
}
