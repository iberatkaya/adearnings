import SwiftUI
import GoogleSignIn

struct HomeView: View {
    ///The Google Delegate Environment Object.
    @EnvironmentObject var googleDelegate: GoogleDelegate
    
    ///On mount, attempt to make a silent sign in.
    func onMount(){
        googleDelegate.silentSignIn()
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
                    Text("Get Admob Account")
                }
                Button(action: {
                    print(googleDelegate.currentUser())
                }) {
                    Text("User")
                }
                Button(action: {
                    googleDelegate.signOut()
                }) {
                    Text("Sign Out")
                }
            }
        }.onAppear(perform: onMount)
    }
}
