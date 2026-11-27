import AppKit
import AVKit
import SwiftUI
import UniformTypeIdentifiers

enum Format: String, CaseIterable, Identifiable {
    case portrait = "竖屏 320 × 576"
    case landscape = "横屏 576 × 320"
    case square = "方形 384 × 384"

    var id: Self { self }
    var size: (width: Int, height: Int) {
        switch self {
        case .portrait: (320, 576)
        case .landscape: (576, 320)
        case .square: (384, 384)
        }
    }
}

struct VideoRequest {
    let prompt: String
    let image: URL?
    let output: URL
    let format: Format
    let frames: Int
    let audio: Bool

    func arguments(in storage: URL) -> [String] {
        let size = format.size
        var args = [
            "generate", "--distilled", "--low-ram",
            "--model", storage.appendingPathComponent("model").path,
            "--gemma", storage.appendingPathComponent("gemma").path,
            "--width", String(size.width), "--height", String(size.height),
            "--frames", String(frames), "--frame-rate", "24",
            "--output", output.path
        ]
        if !audio { args.append("--no-audio") }
        if let image { args += ["--image", image.path, "0", "1.0", "replace"] }
        args.append("--prompt=\(prompt)")
        return args
    }
}

@MainActor
final class Studio: ObservableObject {
    @Published var prompt = ""
    @Published var image: URL?
    @Published var format = Format.portrait
    @Published var frames = 49
    @Published var audio = false
    @Published private(set) var status = ""
    @Published private(set) var log = ""
    @Published private(set) var running = false
    @Published private(set) var result: URL?
    @Published private(set) var player: AVPlayer?

    private var process: Process?
    private var logURL: URL?
    private var cancelled = false
    private let storage: URL

    init(storage: URL) {
        self.storage = storage
        status = ready ? "可以生成视频" : "请先准备本地模型和运行环境"
    }

    private var engine: URL { storage.appendingPathComponent("engine/.venv/bin/ltx-2-mlx") }
    var ready: Bool {
        FileManager.default.isExecutableFile(atPath: engine.path)
            && FileManager.default.fileExists(atPath: storage.appendingPathComponent(".ready").path)
    }

    func chooseImage() {
        let picker = NSOpenPanel()
        picker.allowedContentTypes = [.png, .jpeg]
        picker.allowsMultipleSelection = false
        if picker.runModal() == .OK { image = picker.url }
    }

    func generate() {
        guard !running, ready else { return }
        let text = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        let job = storage.appendingPathComponent("videos/\(UUID().uuidString)")
        let output = job.appendingPathComponent("成片.mp4")
        let logFile = job.appendingPathComponent("生成日志.txt")
        let request = VideoRequest(prompt: text, image: image, output: output,
                                   format: format, frames: frames, audio: audio)
        player?.pause()
        player = nil
        result = nil
        log = ""
        cancelled = false
        do {
            try FileManager.default.createDirectory(at: job, withIntermediateDirectories: true)
            try Data().write(to: logFile)
            let handle = try FileHandle(forWritingTo: logFile)
            defer { try? handle.close() }
            let task = Process()
            task.executableURL = engine
            task.arguments = request.arguments(in: storage)
            task.currentDirectoryURL = job
            task.environment = ProcessInfo.processInfo.environment.merging([
                "HF_HUB_OFFLINE": "1", "TRANSFORMERS_OFFLINE": "1",
                "HF_HOME": storage.appendingPathComponent("hf-cache").path,
                "PYTHONUNBUFFERED": "1"
            ]) { _, value in value }
            task.standardOutput = handle
            task.standardError = handle
            task.terminationHandler = { [weak self] completed in
                let code = completed.terminationStatus
                Task { @MainActor in self?.finish(code: code, output: output) }
            }
            try task.run()
            logURL = logFile
            process = task
            running = true
            status = "正在本机生成。短片也可能需要几分钟或更久。"
        } catch {
            status = "启动失败：\(error.localizedDescription)"
        }
    }

    func refreshLog() {
        guard let logURL, let handle = try? FileHandle(forReadingFrom: logURL) else { return }
        defer { try? handle.close() }
        guard let length = try? handle.seekToEnd() else { return }
        try? handle.seek(toOffset: length > 12_000 ? length - 12_000 : 0)
        if let bytes = try? handle.readToEnd() {
            log = String(decoding: bytes, as: UTF8.self).replacingOccurrences(of: "\r", with: "\n")
        }
    }

    func cancel() {
        guard let process, process.isRunning, !cancelled else { return }
        cancelled = true
        status = "正在取消生成"
        process.terminate()
    }

    private func finish(code: Int32, output: URL) {
        refreshLog()
        running = false
        process = nil
        let metadata = try? output.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])
        if cancelled {
            status = "已取消"
        } else if code == 0, metadata?.isRegularFile == true, (metadata?.fileSize ?? 0) > 0 {
            result = output
            player = AVPlayer(url: output)
            status = "视频已生成"
        } else {
            status = "生成未完成（退出码 \(code)）。详情见下方日志。"
        }
    }
}

struct StudioView: View {
    @ObservedObject var studio: Studio
    private let updates = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("本地视频工作室").font(.largeTitle.weight(.semibold))
                Text("选择首帧图片或直接输入文字，生成一段短视频。").foregroundStyle(.secondary)
                HStack {
                    Button("选择参考图…") { studio.chooseImage() }
                    Text(studio.image?.lastPathComponent ?? "未选择图片时使用文生视频")
                        .lineLimit(1).truncationMode(.middle)
                    if studio.image != nil { Button("移除") { studio.image = nil } }
                }.disabled(studio.running)
                if let url = studio.image, let preview = NSImage(contentsOf: url) {
                    Image(nsImage: preview).resizable().scaledToFit().frame(maxHeight: 125)
                }
                Text("描述镜头、动作和氛围").font(.headline)
                TextEditor(text: $studio.prompt).font(.system(size: 15)).frame(height: 100)
                    .border(.secondary.opacity(0.35)).disabled(studio.running)
                HStack {
                    Picker("画幅", selection: $studio.format) {
                        ForEach(Format.allCases) { Text($0.rawValue).tag($0) }
                    }
                    Picker("时长", selection: $studio.frames) {
                        Text("约 2 秒").tag(49)
                        Text("约 3 秒").tag(73)
                        Text("约 4 秒").tag(97)
                    }
                    Toggle("生成声音", isOn: $studio.audio)
                }.disabled(studio.running)
                HStack {
                    Button("生成视频") { studio.generate() }.buttonStyle(.borderedProminent)
                        .disabled(studio.running || !studio.ready || studio.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    if studio.running {
                        ProgressView().controlSize(.small)
                        Button("取消") { studio.cancel() }
                    }
                    Text(studio.status)
                }
                if let player = studio.player, let url = studio.result {
                    VideoPlayer(player: player).frame(height: 300)
                    Button("在访达显示成片") { NSWorkspace.shared.activateFileViewerSelecting([url]) }
                }
                if !studio.log.isEmpty {
                    DisclosureGroup("生成日志") {
                        Text(studio.log).font(.system(.caption, design: .monospaced)).textSelection(.enabled)
                    }
                }
            }.padding(26)
        }.frame(minWidth: 660, minHeight: 460)
            .onReceive(updates) { _ in if studio.running { studio.refreshLog() } }
    }
}

@main
struct VideoStudioApp: App {
    @StateObject private var studio = Studio(storage: URL(fileURLWithPath:
        ProcessInfo.processInfo.environment["VIDEO_STUDIO_DATA"] ?? "."))

    var body: some Scene {
        WindowGroup("本地视频工作室") { StudioView(studio: studio) }
    }
}
