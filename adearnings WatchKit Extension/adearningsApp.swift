import SwiftUI

@main
struct adearningsApp: App {
    @ObservedObject var googleDelegate: GoogleDelegate = GoogleDelegate()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(googleDelegate: googleDelegate)
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
