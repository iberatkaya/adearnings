import SwiftUI

@main
struct ad_earningsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @ObservedObject var googleDelegate: GoogleDelegate = GoogleDelegate()
    
    init() {
        googleDelegate = appDelegate.googleDelegate
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(googleDelegate)
        }
    }
}
