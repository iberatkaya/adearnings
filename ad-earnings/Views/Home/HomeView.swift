import SwiftUI
import Charts
import ExytePopupView

struct HomeView: View {
    ///The Google Delegate Environment Object.
    @EnvironmentObject var googleDelegate: GoogleDelegate
    
    @EnvironmentObject var connectivityController: ConnectivityController
    
    ///The start date of the analytics. 604800 is a week in seconds.
    @State private var startDate = Date() - TimeInterval(weekInSeconds)
    ///The end date of the analytics.
    @State private var endDate = Date()
    
    ///The boolean that will display a toast
    @State var showToast = false
    
    ///On mount, attempt to make a silent sign in.
    func onMount(){
        googleDelegate.silentSignIn()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if(!googleDelegate.signedIn){
                    VStack {
                        Text("Welcome To AdEarnings!").font(.title2).padding(EdgeInsets(top: 12, leading: 0, bottom: 8, trailing: 0))
                        Text("Google Sign In to view your AdMob Earnings").padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)).foregroundColor(Color.gray)
                        GoogleSignIn().padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                            .onTapGesture {
                                googleDelegate.attemptLoginGoogle()
                            }
                    }
                }
                else {
                    VStack {
                        if(googleDelegate.admobAccount == nil && googleDelegate.madeFirstFetch){
                            Text("Check if you have an AdMob Account!").font(.title3).foregroundColor(.red).bold()
                        }
                        HStack {
                            Spacer()
                            VStack {
                                Text("Today")
                                Text(String(format: "%.2f", googleDelegate.getTodayEarnings()?.rounded(toPlaces: 2) ?? 0) + (googleDelegate.admobAccount?.currencyCode ?? "")).bold()
                            }
                            Spacer()
                            VStack {
                                Text("Yesterday")
                                Text(String(format: "%.2f", googleDelegate.getYesterdayEarnings()?.rounded(toPlaces: 2) ?? 0) + (googleDelegate.admobAccount?.currencyCode ?? "")).bold()
                            }
                            Spacer()
                            VStack {
                                Text("This Week")
                                Text(String(format: "%.2f", googleDelegate.getCurrentWeekEarningsTotal()?.rounded(toPlaces: 2) ?? 0) + (googleDelegate.admobAccount?.currencyCode ?? "")).bold()
                            }
                            Spacer()
                        }.padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)).border(Color.black.opacity(0.3)).padding(EdgeInsets(top: 2, leading: 16, bottom: 6, trailing: 16))
                        HStack {
                            Spacer()
                            VStack {
                                Text("Start Date").font(.title2)
                                DatePicker("Start Date",
                                           selection: $startDate,
                                           in: (endDate - TimeInterval(weekInSeconds * 6))...endDate,
                                           displayedComponents: .date).labelsHidden()
                            }
                            Spacer()
                            VStack {
                                Text("End Date").font(.title2)
                                DatePicker("End Date",
                                           selection: $endDate,
                                           in: ...Date(),
                                           displayedComponents: .date).labelsHidden()
                            }
                            Spacer()
                        }
                        BarChart(xValues: googleDelegate.mediationData?.rows
                                    .map({ $0.dimensionValue.displayLabel ?? String($0.dimensionValue.value.suffix(2))
                                    }) ?? [],
                                 yValues: googleDelegate.mediationData?.rows.map({ $0.metricValue.value }) ?? [])
                        Button(action: {
                            googleDelegate.mediationReport(
                                startDate: startDate,
                                endDate: endDate)
                        }) {
                            Text("Get Report!")
                        }.buttonStyle(BlueButtonStyle())
                        
                    }
                }
            }
            .popup(isPresented: $showToast, type: .toast, position: .bottom, autohideIn: 2) {
                HStack {
                    Text("Check your internet connection!").font(.system(size: 14))
                }
                .frame(width: 240, height: 40)
                .background(Color(red: 1, green: 0.55, blue: 0.55))
                .cornerRadius(12)
            }.padding(EdgeInsets(top: 16, leading: 0, bottom: 2, trailing: 0))
            .navigationBarTitle("AdEarnings", displayMode: .inline)
            .navigationBarItems(
                trailing:
                    HStack {
                        if(googleDelegate.signedIn){
                            Button(action: {
                                googleDelegate.signOut()
                            }) {
                                Text("Sign Out")
                            }
                        }
                    }
            )
        }.onAppear(perform: onMount)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(GoogleDelegate())
    }
}
