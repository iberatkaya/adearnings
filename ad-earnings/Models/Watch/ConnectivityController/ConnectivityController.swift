import Foundation
import WatchConnectivity

class ConnectivityController: NSObject,  WCSessionDelegate, ObservableObject {
    var session: WCSession?
    var googleDelegate: GoogleDelegate
    
    init(googleDelegate: GoogleDelegate){
        self.googleDelegate = googleDelegate
        super.init()
        print(session)
        print(WCSession.isSupported())
        if(WCSession.isSupported()){
            self.session = WCSession.default
            self.session?.delegate = self
            print(self.session)
            session?.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("connected")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print(message)
        print(message["data"])
        if(message["data"] as? String == "requestWeek"){
            googleDelegate.mediationReport(startDate: Date() - TimeInterval(weekInSeconds), endDate: Date(), completed: {report in
                print(report)
                guard let data = try? JSONEncoder().encode(report?.rows) else {
                    return
                }
                session.sendMessage(["currentWeek": data], replyHandler: nil, errorHandler: nil)
            })
            
        }
    }
}
