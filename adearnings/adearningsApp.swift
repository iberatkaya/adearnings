import SwiftUI

@main
struct adearningsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView(googleDelegate: appDelegate.googleDelegate)
        }
    }
}
