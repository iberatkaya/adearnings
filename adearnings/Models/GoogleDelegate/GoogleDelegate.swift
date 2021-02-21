import GoogleSignIn

class GoogleDelegate: NSObject, GIDSignInDelegate, ObservableObject {
    override init() {
        super.init()
        if let admobData = UserDefaults.standard.object(forKey:  "admobAccount") {
            if let mydata = try? JSONDecoder().decode(AdmobAccount.self, from: admobData as! Data) {
                self.admobAccount = mydata
            }
        }
    }
    
    var connectivityController: ConnectivityController?
    
    ///Check if the Google User is signed in.
    @Published var signedIn: Bool = false
    
    ///Boolean to check if the user made their first fetch. Used to display an error message in the UI.
    @Published var madeFirstFetch: Bool = false
    
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
    
    ///The Mediation Report based on clicks
    @Published var clicksMediationData: AdmobMediation?
    
    ///Get the current Google User.
    func currentUser() -> GIDGoogleUser? {
        return GIDSignIn.sharedInstance()?.currentUser
    }
    
    /**
     * Make a Google Sign In.
     * Required by the GIDSignInDelegate Protocol.
     */
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print("user signed in")
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
            } else {
                print("\(error.localizedDescription)")
            }
            signedIn = false
            return
        }
        signedIn = true
        connectivityController?.sendOAuthTokenToWatch(token: user.authentication.accessToken, refreshToken: user.authentication.refreshToken)
        
        if(admobAccount != nil){
            print("send admob account to watch")
            connectivityController?.sendAdmobAccountToWatch(account: admobAccount!)
            fetchInitialMediationReport()
            mediationReport(startDate: Date() - TimeInterval(weekInSeconds), endDate: Date(), metric: Metric.CLICKS, completed: { report in
                DispatchQueue.main.async {
                    self.clicksMediationData = report
                    
                }
            })
        }
        else {
            accountsRequest(completed: {success in
                if(success){
                    self.fetchInitialMediationReport()
                    self.mediationReport(startDate: Date() - TimeInterval(weekInSeconds), endDate: Date(), metric: Metric.CLICKS, completed: { report in
                        DispatchQueue.main.async {
                            self.clicksMediationData = report
                            
                        }
                    })
                }
            })
        }
    }
    
    /**
     * Fetch the mediation reports based on the current week.
     * - Parameter completed: A closure that is called when the fetching is completed.
     */
    func fetchInitialMediationReport(completed: @escaping (AdmobMediation?) -> Void = {_ in }) {
        currentWeekMediationData?.rows = []
        mediationReport(
            startDate: Date() - TimeInterval(weekInSeconds),
            endDate: Date(),
            completed: {report in
                DispatchQueue.main.async {
                    self.mediationData = report
                    self.currentWeekMediationData = report
                }
                completed(report)
            })
    }
    
    ///Make a Google Sign In in SwiftUI.
    func attemptLoginGoogle() {
        GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.windows.last?.rootViewController
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    ///Sign out from the Google Account
    func signOut() {
        GIDSignIn.sharedInstance().signOut()
        admobAccount = nil
        mediationData = nil
        UserDefaults.standard.removeObject(forKey:  "admobAccount")
        signedIn = false
        madeFirstFetch = false
    }
    
    /**
     * Attempt a silent sign in.
     * - Parameter completed: A closure that is called when the silent sign in attemps is completed with the success bool.
     */
    func silentSignIn(completed: @escaping (Bool) -> Void){
        print("silent sign in completed")
        if (GIDSignIn.sharedInstance() != nil) {
            if(GIDSignIn.sharedInstance().hasPreviousSignIn()){
                //User was previously authenticated to Google. Attempt to sign in.
                GIDSignIn.sharedInstance()?.restorePreviousSignIn()
                completed(true)
            }
            else {
                completed(false)
            }
        }
        else {
            completed(false)
        }
    }
    
    /**
     * Request the Gogole User's Admob Accounts.
     * According to https://developers.google.com/admob/api/v1/reference/rest/v1/accounts/list,
     * all credentials have access to at most one AdMob account. Therefore only the first account from the
     * array is returned.
     *
     * - Parameter completed: A closure that is called when the account request is completed with the success bool.
     */
    func accountsRequest(completed: @escaping (Bool) -> Void) {
        let url = URL(string: "https://admob.googleapis.com/v1/accounts")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(GIDSignIn.sharedInstance()!.currentUser!.authentication.accessToken!)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        session.dataTask(with: request)  { (data, response, error)  in
            guard let data = data else {
                completed(false)
                return
            }
            do {
                let admobAccounts = try JSONDecoder().decode(AccountsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.admobAccount = admobAccounts.account.first
                    print("got admob")
                    if(self.admobAccount != nil){
                        print("send admob account to watch")
                        self.connectivityController?.sendAdmobAccountToWatch(account: self.admobAccount!)
                    }
                    completed(true)
                }
            } catch {
                print("JSONDecoder error:", error)
                completed(false)
            }
        }.resume()
    }
    
    func mediationReport(startDate: Date, endDate: Date, dimension: Dimension = Dimension.DATE, sort: Sort = Sort.DESCENDING, metric: Metric = Metric.ESTIMATED_EARNINGS, completed: @escaping (AdmobMediation?) -> Void = { _ in }){
        guard let admobAccount = admobAccount,
              let GIDInstance = GIDSignIn.sharedInstance(),
              let currentUser = GIDInstance.currentUser
        else {
            completed(nil)
            return
        }
        
        let url = URL(string: "https://admob.googleapis.com/v1/\(admobAccount.name)/mediationReport:generate")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(currentUser.authentication.accessToken!)", forHTTPHeaderField: "Authorization")
        
        let jsonBody: [String : Any] = AdmobMediationParams(startDate: startDate, endDate: endDate, accountInfo: admobAccount, dimension: dimension, sort: sort, metric: metric).toDict()
        
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonBody)
        request.httpBody = jsonData
        
        let session = URLSession.shared
        session.dataTask(with: request)  { (data, response, error)  in
            DispatchQueue.main.async {
                self.madeFirstFetch = true
            }
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
                
                var admobMediation: AdmobMediation? = AdmobMediation.fromDicts(jsons: dictData, metric: metric)
                admobMediation?.rows.reverse()
                completed(admobMediation)
            } catch {
                print("JSONDecoder error:", error)
                completed(nil)
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
    
    func mapEarningsXValuesForChart() -> [String]? {
        return mediationData?.rows
            .map({ $0.dimensionValue.displayLabel ?? String($0.dimensionValue.value.suffix(2))
            })
    }
    
    func mapEarningsYValuesForChart() -> [Double]? {
        return mediationData?.rows.map({ $0.metricValue.value })
    }
    
    func mapClicksXValuesForChart() -> [String]? {
        return clicksMediationData?.rows
            .map({ $0.dimensionValue.displayLabel ?? String($0.dimensionValue.value.suffix(2))
            })
    }
    
    func mapClicksYValuesForChart() -> [Double]? {
        return clicksMediationData?.rows.map({ $0.metricValue.value })
    }
    
    func getTotalEarningsOfMediationData() -> Double? {
        return mediationData?.rows.reduce(0, {$0 + $1.metricValue.value})
    }
    
    func getTotalClicksOfMediationData() -> Double? {
        return clicksMediationData?.rows.reduce(0, {$0 + $1.metricValue.value})
    }
}
