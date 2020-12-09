//
//  ad_earningsApp.swift
//  ad-earnings WatchKit Extension
//
//  Created by Ibrahim Berat Kaya on 3.12.2020.
//

import SwiftUI

@main
struct ad_earningsApp: App {
    @ObservedObject var connectivityController = ConnectivityController()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView().environmentObject(connectivityController)
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
