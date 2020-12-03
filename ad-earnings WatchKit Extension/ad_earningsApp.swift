//
//  ad_earningsApp.swift
//  ad-earnings WatchKit Extension
//
//  Created by Ibrahim Berat Kaya on 3.12.2020.
//

import SwiftUI

@main
struct ad_earningsApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
