import ActivityKit
import SwiftUI
import WidgetKit

@main
struct LyricsActivityWidgetBundle: WidgetBundle {
  var body: some Widget {
    LyricsActivityWidget()
  }
}

struct LyricsActivityWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: LXLyricsActivityAttributes.self) { context in
      LyricsLockScreenView(state: context.state)
        .activityBackgroundTint(Color(hex: context.state.backgroundColor))
        .activitySystemActionForegroundColor(.white)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          ActivityWaveform(isPlaying: context.state.isPlaying, phase: context.state.currentLine, color: Color(hex: context.state.foregroundColor))
        }
        DynamicIslandExpandedRegion(.trailing) {
          Text(context.state.artist)
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }
        DynamicIslandExpandedRegion(.center) {
          Text(context.state.title)
            .font(.headline)
            .lineLimit(1)
        }
        DynamicIslandExpandedRegion(.bottom) {
          Text(context.state.currentLine)
            .font(.body.weight(.semibold))
            .multilineTextAlignment(.center)
            .lineLimit(2)
        }
      } compactLeading: {
        ActivityWaveform(isPlaying: context.state.isPlaying, phase: context.state.currentLine, color: Color(hex: context.state.foregroundColor))
      } compactTrailing: {
        Text(context.state.currentLine)
          .font(.caption2)
          .lineLimit(1)
      } minimal: {
        Image(systemName: "music.note")
          .foregroundStyle(Color(hex: context.state.foregroundColor))
      }
      .keylineTint(Color(hex: context.state.foregroundColor))
    }
  }
}

private struct LyricsLockScreenView: View {
  let state: LXLyricsActivityAttributes.ContentState

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(spacing: 8) {
        Image(systemName: state.isPlaying ? "waveform" : "pause.fill")
          .font(.caption.weight(.bold))
          .foregroundStyle(Color(hex: state.foregroundColor))

        VStack(alignment: .leading, spacing: 1) {
          Text(state.title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .lineLimit(1)
          Text(state.artist)
            .font(.caption2)
            .foregroundStyle(.white.opacity(0.58))
            .lineLimit(1)
        }

        Spacer(minLength: 8)

        Text(state.isPlaying ? "播放中" : "已暂停")
          .font(.caption2)
          .foregroundStyle(.white.opacity(0.55))
      }

      VStack(spacing: 6) {
        lyricLine(state.previousLine, font: .caption, opacity: 0.42, limit: 1, color: Color(hex: state.foregroundColor))
        lyricLine(state.currentLine, font: .body.weight(.semibold), opacity: 1, limit: 2, color: Color(hex: state.foregroundColor))
        lyricLine(state.nextLine, font: .caption, opacity: 0.5, limit: 1, color: Color(hex: state.foregroundColor))
      }
      .frame(maxWidth: .infinity)
      .multilineTextAlignment(.center)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
  }

  @ViewBuilder
  private func lyricLine(
    _ text: String,
    font: Font,
    opacity: Double,
    limit: Int,
    color: Color
  ) -> some View {
    Text(text.isEmpty ? " " : text)
      .font(font)
      .foregroundStyle(color.opacity(opacity))
      .lineLimit(limit)
      .minimumScaleFactor(0.78)
  }
}

/// 以单色高低柱表现波形；每次歌词推进时切换柱高，形成轻量跳动感。
private struct ActivityWaveform: View {
  let isPlaying: Bool
  let phase: String
  let color: Color
  private let pattern: [CGFloat] = [5, 10, 7, 15, 9, 12, 5]

  private var heights: [CGFloat] {
    let offset = phase.unicodeScalars.reduce(0) { ($0 + Int($1.value)) % pattern.count }
    return Array(pattern[offset...] + pattern[..<offset])
  }

  var body: some View {
    HStack(alignment: .center, spacing: 2) {
      ForEach(Array(heights.enumerated()), id: \.offset) { _, height in
        Capsule()
          .fill(color.opacity(isPlaying ? 1 : 0.45))
          .frame(width: 2, height: isPlaying ? height : 4)
      }
    }
    .animation(.easeInOut(duration: 0.35), value: phase)
    .accessibilityLabel(isPlaying ? "正在播放" : "已暂停")
  }
}

private extension Color {
  init(hex: String) {
    let value = UInt64(hex.dropFirst(), radix: 16) ?? 0x17191F
    self.init(
      .sRGB,
      red: Double((value >> 16) & 0xFF) / 255,
      green: Double((value >> 8) & 0xFF) / 255,
      blue: Double(value & 0xFF) / 255,
      opacity: 1
    )
  }
}
