import GoogleSignIn

class GoogleDelegate: NSObject, GIDSignInDelegate, ObservableObject {
    ///Check if the Google User is signed in.
    @Published var signedIn: Bool = false
    
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
    }
    
    ///Make a Google Sign In in SwiftUI.
    func attemptLoginGoogle() {
        GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.windows.last?.rootViewController
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    ///Sign out from the Google Account
    func signOut() {
        GIDSignIn.sharedInstance().signOut()
        signedIn = false
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
            }
        } else {
            signedIn = false
        }
    }
    
    /**
     * Request the Gogole User's Admob Accounts.
     * According to https://developers.google.com/admob/api/v1/reference/rest/v1/accounts/list,
     * all credentials have access to at most one AdMob account. Therefore only the first account from the
     * array is returned.
     */
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
