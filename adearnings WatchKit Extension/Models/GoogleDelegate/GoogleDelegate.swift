import SwiftUI

class GoogleDelegate: ObservableObject {
    
    init() {
        if let admobData = UserDefaults.standard.object(forKey:  "admobAccount") {
            if let mydata = try? JSONDecoder().decode(AdmobAccount.self, from: admobData as! Data) {
                self.admobAccount = mydata
            }
        }
        if let tokenData = UserDefaults.standard.string(forKey:  "oAuthToken") {
            self.oAuthToken = tokenData
        }
        if let refreshTokenData = UserDefaults.standard.string(forKey:  "refreshToken") {
            self.refreshToken = refreshTokenData
        }
        mediationReport(
            startDate: Date() - TimeInterval(weekInSeconds),
            endDate: Date(),
            completed: {report in
                DispatchQueue.main.async {
                    self.currentWeekMediationData = report
                }
            }
        )
    }
    
    @Published var oAuthToken: String? {
        didSet {
            UserDefaults.standard.set(oAuthToken, forKey: "oAuthToken")
        }
    }
    
    @Published var refreshToken: String? {
        didSet {
            UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
        }
    }
    
    ///Check if the Google User is signed in.
    @Published var signedIn: Bool = false
    
    ///The AdMob Account
    @Published var admobAccount: AdmobAccount? {
        didSet {
            if let encoded = try? JSONEncoder().encode(admobAccount) {
                UserDefaults.standard.set(encoded, forKey: "admobAccount")
            }
        }
    }
    
    ///The current week's Mediation Data in order to display in the UI.
    @Published var currentWeekMediationData: AdmobMediation?
    
    ///The Mediation Data requested by the user.
    @Published var mediationData: AdmobMediation?
    
    func mediationReport(startDate: Date, endDate: Date, dimension: Dimension = Dimension.DATE, sort: Sort = Sort.DESCENDING, metric: Metric = Metric.ESTIMATED_EARNINGS, completed: @escaping (AdmobMediation?) -> Void = { _ in }){
        guard let admobAccount = admobAccount,
              let token = self.oAuthToken
        else {
            completed(nil)
            return
        }
        
        mediationData?.rows = []
        
        let url = URL(string: "https://admob.googleapis.com/v1/\(admobAccount.name)/mediationReport:generate")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let jsonBody: [String : Any] = AdmobMediationParams(startDate: startDate, endDate: endDate, accountInfo: admobAccount, dimension: dimension, sort: sort, metric: metric).toDict()
        
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonBody)
        request.httpBody = jsonData
        
        let session = URLSession.shared
        session.dataTask(with: request)  { (data, response, error)  in
            guard let data = data else {
                completed(nil)
                return
            }
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
                guard let dictData = parsedData else {
                    completed(nil)
                    return
                }
                if let error = parsedData?[0]["error"] as? [String: Any] {
                    print(error)
                    if let errorCode = error["code"] as? Int {
                        if(errorCode == 401){
                            self.refreshOAuthToken(completed: {
                                self.mediationReport(
                                    startDate: Date() - TimeInterval(weekInSeconds),
                                    endDate: Date(),
                                    completed: {report in
                                        DispatchQueue.main.async {
                                            self.currentWeekMediationData = report
                                        }
                                    }
                                )
                            })
                        }
                    }
                    completed(nil)
                    return
                }
                
                var admobMediation: AdmobMediation? = AdmobMediation.fromDicts(jsons: dictData)
                DispatchQueue.main.async {
                    self.mediationData?.rows = []
                    if(dimension == Dimension.DATE){
                        admobMediation?.rows.reverse()
                    }
                    self.mediationData = admobMediation
                    completed(admobMediation)
                }
            } catch {
                print("JSONDecoder error:", error)
                completed(nil)
            }
        }.resume()
    }
    
    func refreshOAuthToken(completed: @escaping () -> Void = {}){
        let url = URL(string: "https://oauth2.googleapis.com/token")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let params = ["client_id": clientID, "grant_type": "refresh_token", "refresh_token": refreshToken]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: params)
        request.httpBody = jsonData
        
        let session = URLSession.shared
        session.dataTask(with: request)  { (data, response, error)  in
            guard let data = data else {
                completed()
                return
            }
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let dictData = parsedData else {
                    completed()
                    return
                }
                guard let authToken = dictData["access_token"] as? String else {
                    completed()
                    return
                }
                DispatchQueue.main.async {
                    self.oAuthToken = authToken
                    completed()
                }
            } catch {
                print("JSONDecoder error:", error)
                completed()
            }
        }.resume()
    }
    
    ///Get today's earnings.
    func getTodayEarnings() -> Double? {
        return currentWeekMediationData?.rows.last?.metricValue.value
    }
    
    ///Get yesterday's earnings.
    func getYesterdayEarnings() -> Double? {
        if(currentWeekMediationData == nil){
            return 0
        }
        if(currentWeekMediationData!.rows.count < 2){
            return 0
        }
        return currentWeekMediationData!.rows[currentWeekMediationData!.rows.count - 2].metricValue.value
    }
    
    ///Get this week's total earnings.
    func getCurrentWeekEarningsTotal() -> Double? {
        return currentWeekMediationData?.rows.map({row in row.metricValue.value}).reduce(0, {current, next in
            current + next
        })
    }
    
    func mapCurrentWeekMediationDataToChartData() -> [(String, Double)]? {
        return currentWeekMediationData?.rows.map({ ($0.dimensionValue.displayLabel ?? String($0.dimensionValue.value.suffix(2) + " - " + (admobAccount?.currencyCode ?? "")), $0.metricValue.value)
        })
    }
    
    func mapMediationDataToChartData() -> [(String, Double)]? {
        return mediationData?.rows.map({ ($0.dimensionValue.displayLabel ?? String($0.dimensionValue.value.suffix(2) + " - " + (admobAccount?.currencyCode ?? "")), $0.metricValue.value)
        })
    }
}
