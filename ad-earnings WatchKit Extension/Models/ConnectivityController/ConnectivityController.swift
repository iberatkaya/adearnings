import SwiftUI
import WatchConnectivity

class ConnectivityController: NSObject,  WCSessionDelegate, ObservableObject {
    var session: WCSession?
    
    @Published var admobMediationRows: [AdmobMediationRow]  = []
    
    override init(){
        super.init()
        if(WCSession.isSupported()){
            self.session = WCSession.default
            self.session?.delegate = self
            session?.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("connected and send message")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], completed: @escaping (AdmobMediation?) -> Void) {
        print(message)
        DispatchQueue.main.async {
            let jsons = try? JSONSerialization.jsonObject(with: message["currentWeek"] as! Data) as? [[String: Any]]
            print(jsons)
            if jsons == nil {
                return
            }
            var admobMediationRows: [AdmobMediationRow] = []
            for json in jsons! {
                for (key, val) in json {
                    let data = AdmobMediationRow.fromDict(json: val as! [String : Any])
                }
            }
            self.admobMediationRows = admobMediationRows
        }
    }
}
