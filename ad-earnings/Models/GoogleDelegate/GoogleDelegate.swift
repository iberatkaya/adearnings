import GoogleSignIn
import Charts

class GoogleDelegate: NSObject, GIDSignInDelegate, ObservableObject {
    override init() {
        super.init()
        if let admobData = UserDefaults.standard.object(forKey:  "admobAccount") {
            if let mydata = try? JSONDecoder().decode(AdmobAccount.self, from: admobData as! Data) {
                self.admobAccount = mydata
            }
        }
    }
    
    ///Check if the Google User is signed in.
    @Published var signedIn: Bool = false
    
    ///This Bool is used in order to make less requests to Google API.
    private var requestAdmobAccount: Bool = false
    
    ///The AdMob Account
    @Published var admobAccount: AdmobAccount? {
        didSet {
            if let encoded = try? JSONEncoder().encode(admobAccount) {
                UserDefaults.standard.set(encoded, forKey: "admobAccount")
            }
        }
    }
    
    @Published var mediationData: AdmobMediation?
    
    ///Get the current Google User.
    func currentUser() -> GIDGoogleUser? {
        return GIDSignIn.sharedInstance()?.currentUser
    }
    
    /**
     * Make a Google Sign In.
     * Required by the GIDSignInDelegate Protocol.
     */
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
            } else {
                print("\(error.localizedDescription)")
            }
            signedIn = false
            return
        }
        signedIn = true
        if(requestAdmobAccount){
            accountsRequest()
        }
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
        requestAdmobAccount = true
    }
    
    ///Attempt a silent sign in.
    func silentSignIn(){
        if (GIDSignIn.sharedInstance() != nil) {
            if(GIDSignIn.sharedInstance().hasPreviousSignIn()){
                //User was previously authenticated to Google. Attempt to sign in.
                GIDSignIn.sharedInstance()?.restorePreviousSignIn()
                signedIn = true
            }
            else {
                signedIn = false
                requestAdmobAccount = true
            }
        } else {
            signedIn = false
            requestAdmobAccount = true
        }
    }
    
    /**
     * Request the Gogole User's Admob Accounts.
     * According to https://developers.google.com/admob/api/v1/reference/rest/v1/accounts/list,
     * all credentials have access to at most one AdMob account. Therefore only the first account from the
     * array is returned.
     */
    func accountsRequest() {
        let url = URL(string: "https://admob.googleapis.com/v1/accounts")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(GIDSignIn.sharedInstance()!.currentUser!.authentication.accessToken!)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        session.dataTask(with: request)  { (data, response, error)  in
            guard let data = data else {
                return
            }
            do {
                let admobAccounts = try JSONDecoder().decode(AccountsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.admobAccount = admobAccounts.account.first
                }
            } catch {
                print("JSONDecoder error:", error)
            }
        }.resume()
    }
    
    func mediationReport(startDate: Date, endDate: Date, dimension: Dimension = Dimension.DATE, sort: Sort = Sort.DESCENDING, metric: Metric = Metric.ESTIMATED_EARNINGS){
        guard let admobAccount = admobAccount else {
            return
        }
        guard let GIDInstance = GIDSignIn.sharedInstance() else {
            return
        }
        guard let currentUser = GIDInstance.currentUser else {
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
            guard let data = data else {
                return
            }
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data) as? [[String:Any]]
                guard let dictData = parsedData else {
                    return
                }
                
                var admobMediation: AdmobMediation? = AdmobMediation.fromDicts(jsons: dictData)
                DispatchQueue.main.async {
                    if(dimension == Dimension.DATE){
                        admobMediation?.rows.sort(by: {(a, b) in
                            print((Double(a.dimensionValue.value.suffix(2)) ?? -1) < (Double(b.dimensionValue.value.suffix(2)) ?? -1))
                            return (Double(a.dimensionValue.value.suffix(2)) ?? -1) < (Double(b.dimensionValue.value.suffix(2)) ?? -1)
                        })
                    }
                    self.mediationData = admobMediation
                }
                
            } catch {
                print("JSONDecoder error:", error)
                
            }
        }.resume()
    }
}
