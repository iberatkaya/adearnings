import SwiftUI

@main
struct ad_earningsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView(googleDelegate: appDelegate.googleDelegate)
        }
    }
}
