import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    @Published var googleDelegate = GoogleDelegate()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        GIDSignIn.sharedInstance().clientID = clientID
        GIDSignIn.sharedInstance().delegate = googleDelegate
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/admob.report")
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
}
