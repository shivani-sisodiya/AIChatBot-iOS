//
//  AIChatBotApp.swift
//  AIChatBot
//
//  Created by Shivani Sisodiya on 19/11/24.
//

import SwiftUI
import SwiftData

@main
struct AIChatBotApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(for: [Session.self, Message.self])
        }
    }
}
