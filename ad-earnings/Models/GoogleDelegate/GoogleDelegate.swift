import GoogleSignIn

class GoogleDelegate: NSObject, GIDSignInDelegate, ObservableObject {
    
    @Published var signedIn: Bool = false
    func currentUser() -> GIDGoogleUser? {
        return GIDSignIn.sharedInstance()?.currentUser
    }
    
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
    }
    
    func attemptLoginGoogle() {
        GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.windows.last?.rootViewController
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func signOut() {
        GIDSignIn.sharedInstance().signOut()
        signedIn = false
    }
    
    func silentSignIn(){
        if (GIDSignIn.sharedInstance() != nil) {
            if(GIDSignIn.sharedInstance().hasPreviousSignIn()){
                // User was previously authenticated to Google. Attempt to sign in.
                GIDSignIn.sharedInstance()?.restorePreviousSignIn()
                signedIn = true
            }
            else {
                signedIn = false
            }
        } else {
            signedIn = false
        }
    }
    
    func accountsRequest(completed: @escaping (AdmobAccount?) -> Void) {
        
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
                completed(admobAccounts.account.first)
            } catch {
                print("JSONDecoder error:", error)
                completed(nil)
            }
        }.resume()
    }
}
