import SwiftUI
import Charts
import ExytePopupView
import SwiftUIRefresh

struct HomeView: View {
    ///The Google Delegate Environment Object.
    @EnvironmentObject var googleDelegate: GoogleDelegate
    
    ///The start date of the earnings report.
    @State var earningsStartDate = Date() - TimeInterval(weekInSeconds)
    ///The end date of the earnings report.
    @State var earningsEndDate = Date()
    ///The start date of the clicks report.
    @State var clicksStartDate = Date() - TimeInterval(weekInSeconds)
    ///The end date of the clicks report.
    @State var clicksEndDate = Date()
    
    ///The boolean that will display a toast.
    @State var showToast = false
    
    ///The boolean that will be used in pull to refresh.
    @State var isShowing = false
    
    ///The boolean that will display a loading indicator on app launch.
    @State var hasPreviosSession = false
    
    ///On mount, attempt to make a silent sign in.
    func onMount(){
        googleDelegate.silentSignIn(completed: { hasSession in
            hasPreviosSession = hasSession
            print("hasPreviosSession completed: \(hasPreviosSession)")
        })
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if(hasPreviosSession && !googleDelegate.signedIn){
                    ScrollView {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                            .scaleEffect(2)
                            .padding(EdgeInsets(top: 24, leading: 0, bottom: 0, trailing: 0))
                        Text("Loading...")
                            .foregroundColor(.gray)
                            .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                    }
                }
                else if(!hasPreviosSession && !googleDelegate.signedIn){
                    ScrollView {
                        Text("Welcome To Ad Earnings!")
                            .font(.system(size: 24))
                            .bold()
                            .padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
                        Text("Google Sign In to view your AdMob Earnings!")
                            .font(.system(size: 17))
                            .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                            .foregroundColor(Color.gray)
                        GoogleSignIn()
                            .onTapGesture {
                                googleDelegate.attemptLoginGoogle()
                            }
                            .frame(height: 60)
                        Text("Open your Ad Earnings Watch App while signing in to use Ad Earnings on your Apple Watch.")
                            .font(.system(size: 16))
                            .padding(EdgeInsets(top: 12, leading: 0, bottom: 4, trailing: 0))
                            .foregroundColor(Color.gray)
                        Image("watch_ss")
                            .cornerRadius(12)
                            .scaleEffect(0.9)
                    }.padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                    Spacer()
                }
                else {
                    List {
                        if(googleDelegate.admobAccount == nil && googleDelegate.madeFirstFetch){
                            Text("Check if you have an AdMob Account!")
                                .font(.title3)
                                .foregroundColor(.red)
                                .bold()
                        }
                        HStack {
                            Spacer()
                            VStack {
                                Text("Today")
                                Text(String(format: "%.2f", googleDelegate.getTodayEarnings() ?? 0) + " " + (googleDelegate.admobAccount?.currencyCode ?? "")).bold()
                            }
                            Spacer()
                            VStack {
                                Text("Yesterday")
                                Text(String(format: "%.2f", googleDelegate.getYesterdayEarnings() ?? 0) + " " + (googleDelegate.admobAccount?.currencyCode ?? "")).bold()
                            }
                            Spacer()
                            VStack {
                                Text("This Week")
                                Text(String(format: "%.2f", googleDelegate.getCurrentWeekEarningsTotal() ?? 0) + " " + (googleDelegate.admobAccount?.currencyCode ?? "")).bold()
                            }
                            Spacer()
                        }.padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black.opacity(0.3), lineWidth: 2)
                        ).padding(EdgeInsets(top: 2, leading: 16, bottom: 6, trailing: 16))
                        VStack {
                            VStack {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Text("Earnings").font(.title2)
                                        Spacer()
                                    }.padding(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0))
                                    VStack {
                                        HStack {
                                            Text("Range Total:").foregroundColor(.gray)
                                            Text(String(format: "%.2f", googleDelegate.getTotalEarningsOfMediationData() ?? 0)).bold()
                                        }
                                    }
                                }
                                Divider()
                                HStack {
                                    Spacer()
                                    VStack {
                                        Text("Start Date").font(.title3)
                                        DatePicker("Start Date",
                                                   selection: $earningsStartDate,
                                                   in: (earningsEndDate - TimeInterval(weekInSeconds * 6))...earningsEndDate,
                                                   displayedComponents: .date).labelsHidden()
                                    }
                                    Spacer()
                                    VStack {
                                        Text("End Date").font(.title3)
                                        DatePicker("End Date",
                                                   selection: $earningsEndDate,
                                                   in: earningsStartDate...Date(),
                                                   displayedComponents: .date).labelsHidden()
                                    }
                                    Spacer()
                                }
                            }.padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                                .overlay(RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black.opacity(0.3), lineWidth: 2)
                            )
                            BarChart(
                                xValues: googleDelegate.mapEarningsXValuesForChart() ?? [],
                                yValues: googleDelegate.mapEarningsYValuesForChart() ?? [])
                                .frame(minHeight: 320)
                            HStack {
                                Spacer()
                                Button(action: {
                                    googleDelegate.mediationReport(
                                        startDate: earningsStartDate,
                                        endDate: earningsEndDate,
                                        completed: { report in
                                            DispatchQueue.main.async {
                                                googleDelegate.mediationData = report
                                            }
                                        }
                                    )
                                }) {
                                    Text("Get Report")
                                }.buttonStyle(BlueButtonStyle())
                                Spacer()
                            }.padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                        }
                        VStack {
                            VStack {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Text("Clicks").font(.title2)
                                        Spacer()
                                    }.padding(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0))
                                    VStack {
                                        HStack {
                                            Text("Range Total:").foregroundColor(.gray)
                                            Text(String(format: "%.2f", googleDelegate.getTotalClicksOfMediationData() ?? 0)).bold()
                                        }
                                    }
                                }
                                Divider()
                                HStack {
                                    Spacer()
                                    VStack {
                                        Text("Start Date").font(.title3)
                                        DatePicker("Start Date",
                                                   selection: $clicksStartDate,
                                                   in: (clicksEndDate - TimeInterval(weekInSeconds * 6))...clicksEndDate,
                                                   displayedComponents: .date).labelsHidden()
                                    }
                                    Spacer()
                                    VStack {
                                        Text("End Date").font(.title3)
                                        DatePicker("End Date",
                                                   selection: $clicksEndDate,
                                                   in: clicksStartDate...Date(),
                                                   displayedComponents: .date).labelsHidden()
                                    }
                                    Spacer()
                                }
                            }.padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black.opacity(0.3), lineWidth: 2)
                            )
                            BarChart(
                                xValues: googleDelegate.mapClicksXValuesForChart() ?? [],
                                yValues: googleDelegate.mapClicksYValuesForChart() ?? [])
                                .frame(minHeight: 320)
                            HStack {
                                Spacer()
                                Button(action: {
                                    googleDelegate.mediationReport(
                                        startDate: clicksStartDate,
                                        endDate: clicksEndDate,
                                        metric: Metric.CLICKS,
                                        completed: { report in
                                            DispatchQueue.main.async {
                                                googleDelegate.clicksMediationData = report
                                            }
                                        }
                                    )
                                }) {
                                    Text("Get Report")
                                }.buttonStyle(BlueButtonStyle())
                                Spacer()
                            }.padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                        }
                        VStack {
                            HStack {
                                Spacer()
                                VStack {
                                    Text("Publisher")
                                    Text(googleDelegate.admobAccount?.publisherId ?? "").bold()
                                }
                                Spacer()
                            }.padding(EdgeInsets(top: 4, leading: 0, bottom: 8, trailing: 0))
                            HStack {
                                Spacer()
                                Button(action: {
                                    googleDelegate.signOut()
                                    hasPreviosSession = false
                                }) {
                                    Text("Sign Out")
                                }.buttonStyle(BlueButtonStyle())
                                Spacer()
                            }.padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                        }
                    }.listStyle(PlainListStyle()).pullToRefresh(isShowing: $isShowing) {
                        //Reset all the dates
                        earningsStartDate = Date() - TimeInterval(weekInSeconds)
                        earningsEndDate = Date()
                        clicksStartDate = Date() - TimeInterval(weekInSeconds)
                        clicksEndDate = Date()
                        self.googleDelegate.fetchInitialMediationReport(completed: {_ in self.isShowing = false})
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
            }.navigationBarTitle("Ad Earnings", displayMode: .inline)
            .navigationBarItems(
                trailing:
                    HStack {
                        if(googleDelegate.signedIn){
                        }
                    }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: onMount)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(GoogleDelegate())
    }
}
