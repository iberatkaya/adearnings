import Foundation
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
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    }
    
    func sendOAuthTokenToWatch(token: String, refreshToken: String){
        session?.sendMessage(["type": "sendOAuthToken", "oAuthToken": token, "refreshToken": refreshToken], replyHandler: nil, errorHandler: nil)
    }
    
    func sendAdmobAccountToWatch(account: AdmobAccount){
        guard let accountJson = try? JSONEncoder().encode(account) else {
            return
        }
        print(accountJson)
        session?.sendMessage(["type": "sendAdmobAccount", "admobAccount": accountJson], replyHandler: nil, errorHandler: nil)
    }
}
