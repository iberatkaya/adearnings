import SwiftUI
import WatchConnectivity

class ConnectivityController: NSObject,  WCSessionDelegate, ObservableObject {
    var session: WCSession?
    var googleDelegate: GoogleDelegate
    
    init(googleDelegate: GoogleDelegate){
        self.googleDelegate = googleDelegate
        super.init()
        if(WCSession.isSupported()){
            self.session = WCSession.default
            self.session?.delegate = self
            session?.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print(message)
        guard let type = message["type"] as? String else {
            return
        }
        if(type == "sendOAuthToken"){
            guard let token = message["oAuthToken"] as? String,
                  let refreshToken = message["refreshToken"] as? String
            else {
                return
            }
            DispatchQueue.main.async {
                self.googleDelegate.oAuthToken = token
                self.googleDelegate.refreshToken = refreshToken
            }
        }
        else if(type == "sendAdmobAccount"){
            guard let admobAccount = try? JSONDecoder().decode(AdmobAccount.self, from: message["admobAccount"] as! Data) else {
                return
            }
            DispatchQueue.main.async {
                self.googleDelegate.admobAccount = admobAccount
            }
        }
    }
    
}
