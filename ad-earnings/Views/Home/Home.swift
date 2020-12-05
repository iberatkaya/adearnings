import SwiftUI
import GoogleSignIn

struct HomeView: View {
    @State var signedIn: Bool = false
    @EnvironmentObject var googleDelegate: GoogleDelegate
    
    private func checkIfGoogleUserIsAuthorized() {
        googleDelegate.silentSignIn()
    }
    
    func onMount(){
        checkIfGoogleUserIsAuthorized()
    }
    
    
    
    var body: some View {
        VStack {
            if(!googleDelegate.signedIn){
                GoogleSignIn()
                    .onTapGesture {
                        googleDelegate.attemptLoginGoogle()
                    }
            }
            else {
                Button(action: {
                    print(googleDelegate.accountsRequest(completed: { admobAccount in
                        print("got admob account \(admobAccount)")
                    }))
                }) {
                    Text("Get User")
                }
                Button(action: {
                    print(googleDelegate.currentUser())
                }) {
                    Text("User")
                }
                Button(action: {
                    googleDelegate.signOut()
                    print("sign out")
                    signedIn = false
                }) {
                    Text("Sign Out")
                }
            }
        }.onAppear(perform: onMount)
    }
}
