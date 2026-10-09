//
//  CRMAlarmKitBridge.swift
//  My_Study
//
//  iOS 26 系统闹钟桥接层，供 Objective-C 提醒页面调用。
//

import Foundation
#if canImport(AlarmKit)
import AlarmKit
import SwiftUI
#endif

@objcMembers
public final class CRMAlarmKitBridge: NSObject {
    public static let shared = CRMAlarmKitBridge()

    private override init() {
        super.init()
    }

    /// 创建指定日期的一次性系统闹钟。
    public func scheduleAlarm(
        title: String,
        date: Date,
        completion: @escaping (String?, Error?) -> Void
    ) {
        guard #available(iOS 26.0, *) else {
            completion(nil, bridgeError(code: 1, description: "当前系统不支持系统闹钟"))
            return
        }

        Task {
            do {
                let authorization = try await requestAlarmAuthorization()
                guard authorization else {
                    throw bridgeError(code: 2, description: "系统闹钟权限未开启")
                }
                guard date.timeIntervalSinceNow >= 30 else {
                    throw bridgeError(code: 3, description: "闹钟时间需要在未来")
                }

                let identifier = try await createAlarm(title: title, date: date)
                await MainActor.run {
                    completion(identifier.uuidString, nil)
                }
            } catch {
                await MainActor.run {
                    completion(nil, error)
                }
            }
        }
    }

    /// 取消由本应用创建的系统闹钟。
    public func cancelAlarm(identifier: String, completion: @escaping (Error?) -> Void) {
        guard #available(iOS 26.0, *) else {
            completion(bridgeError(code: 1, description: "当前系统不支持系统闹钟"))
            return
        }
        guard let alarmID = UUID(uuidString: identifier) else {
            completion(bridgeError(code: 4, description: "闹钟标识无效"))
            return
        }

        do {
            try cancelAlarm(id: alarmID)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    private func bridgeError(code: Int, description: String) -> NSError {
        NSError(
            domain: "com.zw.My-Study.AlarmKit",
            code: code,
            userInfo: [NSLocalizedDescriptionKey: description]
        )
    }
}

@available(iOS 26.0, *)
private extension CRMAlarmKitBridge {
    func requestAlarmAuthorization() async throws -> Bool {
        let manager = AlarmManager.shared
        switch manager.authorizationState {
        case .authorized:
            return true
        case .denied:
            return false
        case .notDetermined:
            return try await manager.requestAuthorization() == .authorized
        @unknown default:
            return false
        }
    }

    func createAlarm(title: String, date: Date) async throws -> UUID {
        let alarmID = UUID()
        let stopButton = AlarmButton(
            text: "停止",
            textColor: .white,
            systemImageName: "stop.circle.fill"
        )
        let alert = AlarmPresentation.Alert(
            title: LocalizedStringResource(stringLiteral: title),
            stopButton: stopButton
        )
        let presentation = AlarmPresentation(alert: alert)
        let attributes = AlarmAttributes<CRMReminderAlarmMetadata>(
            presentation: presentation,
            metadata: CRMReminderAlarmMetadata(task: title),
            tintColor: .orange
        )
        let configuration = AlarmManager.AlarmConfiguration.alarm(
            schedule: .fixed(date),
            attributes: attributes
        )
        _ = try await AlarmManager.shared.schedule(id: alarmID, configuration: configuration)
        return alarmID
    }

    func cancelAlarm(id: UUID) throws {
        try AlarmManager.shared.cancel(id: id)
    }
}

#if canImport(AlarmKit)
@available(iOS 26.0, *)
private struct CRMReminderAlarmMetadata: AlarmMetadata {
    let task: String
}
#endif
