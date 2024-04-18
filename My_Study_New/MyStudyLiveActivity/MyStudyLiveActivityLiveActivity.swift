//
//  MyStudyLiveActivityLiveActivity.swift
//  MyStudyLiveActivity
//
//  Created by hzw on 2024/2/23.
//  Copyright © 2024 HZW. All rights reserved.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MyStudyLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct MyStudyLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MyStudyLiveActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension MyStudyLiveActivityAttributes {
    fileprivate static var preview: MyStudyLiveActivityAttributes {
        MyStudyLiveActivityAttributes(name: "World")
    }
}

extension MyStudyLiveActivityAttributes.ContentState {
    fileprivate static var smiley: MyStudyLiveActivityAttributes.ContentState {
        MyStudyLiveActivityAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: MyStudyLiveActivityAttributes.ContentState {
         MyStudyLiveActivityAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: MyStudyLiveActivityAttributes.preview) {
   MyStudyLiveActivityLiveActivity()
} contentStates: {
    MyStudyLiveActivityAttributes.ContentState.smiley
    MyStudyLiveActivityAttributes.ContentState.starEyes
}
