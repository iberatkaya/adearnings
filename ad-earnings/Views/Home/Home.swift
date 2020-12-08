import SwiftUI
import Charts

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
                Text(googleDelegate.admobAccount?.name.prefix(12) ?? "").multilineTextAlignment(.center)
                BarChart(xValues: googleDelegate.mediationData?.rows
                            .map({ $0.dimensionValue.displayLabel ?? String($0.dimensionValue.value.suffix(2))
                            }) ?? [],
                         yValues: googleDelegate.mediationData?.rows.map({ $0.metricValue.value }) ?? [])
                Button(action: {
                    googleDelegate.accountsRequest()
                }) {
                    Text("Get Admob Account")
                }
                Button(action: {
                    googleDelegate.mediationReport(startDate: Date.from(year: 2020, month: 11, day: 1)!, endDate: Date.from(year: 2020, month: 11, day: 30)!)
                }) {
                    Text("Get Mediation")
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(GoogleDelegate())
    }
}
