import SwiftUI
import SwiftUICharts

struct HomeView: View {
    @EnvironmentObject var connectivityController: ConnectivityController
    
    @EnvironmentObject var googleDelegate: GoogleDelegate
    
    ///The current index used to go over the weeks in the Bar Chart.
    @State var currentIndex = 0
    
    ///The start date of the earnings report.
    @State var earningsStartDate = Date() - TimeInterval(weekInSeconds)
    ///The end date of the earnings report.
    @State var earningsEndDate = Date()
    ///The start date of the clicks report.
    @State var clicksStartDate = Date() - TimeInterval(weekInSeconds)
    ///The end date of the clicks report.
    @State var clicksEndDate = Date()
    
    @State var isShowing = false
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var body: some View {
        if(googleDelegate.signedIn){
            VStack {
                Text("Welcome To AdEarnings!").font(.title3).bold().padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
                Text("Google Sign In on your iPhone to view your AdMob Earnings").foregroundColor(Color.gray)
            }
        }
        else {
            ScrollView {
                if(googleDelegate.oAuthToken == nil){
                    Text("Please Google Sign In!")
                }
                VStack {
                    VStack {
                        Text("Today").font(.footnote).bold()
                        Text(String(format: "%.2f", googleDelegate.getTodayEarnings() ?? 0) + " " + (googleDelegate.admobAccount?.currencyCode ?? "")).bold()
                    }
                    VStack {
                        Text("Yesterday").font(.footnote).bold()
                        Text(String(format: "%.2f", googleDelegate.getYesterdayEarnings() ?? 0) + " " + (googleDelegate.admobAccount?.currencyCode ?? "")).bold()
                    }
                    VStack {
                        Text("This Week").font(.footnote).bold()
                        Text(String(format: "%.2f", googleDelegate.getCurrentWeekEarningsTotal() ?? 0) + " " + (googleDelegate.admobAccount?.currencyCode ?? "")).bold()
                    }
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
                HStack {
                    Spacer()
                    Button(action: {
                        //Reset all the dates
                        earningsStartDate = Date() - TimeInterval(weekInSeconds)
                        earningsEndDate = Date()
                        clicksStartDate = Date() - TimeInterval(weekInSeconds)
                        clicksEndDate = Date()
                        self.googleDelegate.fetchInitialMediationReport(completed: {_ in self.isShowing = false})
                    }) {
                        Text("Refresh")
                    }
                    
                    Spacer()
                }
                
                Divider().padding(EdgeInsets(top: 4, leading: 0, bottom: 8, trailing: 0))
                
                //The Earnings Medation Report graph
                VStack {
                    Text("Earnings").font(.title3)
                    HStack {
                        Button(action: {
                            currentIndex -= 1
                            earningsStartDate = Date() - TimeInterval(weekInSeconds) * Double((-currentIndex + 1))
                            earningsEndDate = Date()  - TimeInterval(weekInSeconds) * Double(-currentIndex)
                            googleDelegate.mediationData?.rows = []
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
                            Image(systemName: "arrow.backward")
                        }
                        BarChartView(
                            data: ChartData(
                                values: googleDelegate.mapMediationDataToChartData() ?? []),
                            title: "Browse",
                            legend: "Date - " + (googleDelegate.admobAccount?.currencyCode ?? ""),
                            style: ChartStyle(backgroundColor: Color.black, accentColor: Color.blue, gradientColor: GradientColor(start: Color.black, end: Color.black), textColor: Color.gray, legendTextColor: Color.blue, dropShadowColor: Color.black),
                            dropShadow: false
                        )
                        Button(action: {
                            if(currentIndex == 0) {
                                return
                            }
                            currentIndex += 1
                            earningsStartDate = Date() - TimeInterval(weekInSeconds) * Double((-currentIndex + 1))
                            earningsEndDate = Date()  - TimeInterval(weekInSeconds) * Double(-currentIndex)
                            googleDelegate.mediationData?.rows = []
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
                            Image(systemName: "arrow.forward")
                        }
                    }
                    HStack {
                        Spacer()
                        VStack {
                            Text("Start Date").foregroundColor(.gray).font(.footnote)
                            Text("\(earningsStartDate, formatter: dateFormatter)")
                        }
                        Spacer()
                        VStack {
                            Text("End Date").foregroundColor(.gray).font(.footnote)
                            Text("\(earningsEndDate, formatter: dateFormatter)")
                        }
                        Spacer()
                    }.padding(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 0))
                    HStack {
                        Spacer()
                        HStack {
                            Text("Range Total:").foregroundColor(.gray).font(.footnote)
                            Text(String(format: "%.2f", googleDelegate.getTotalEarningsOfMediationData() ?? 0)).bold()
                        }
                        Spacer()
                    }
                }
                
                Divider().padding(EdgeInsets(top: 4, leading: 0, bottom: 8, trailing: 0))
                
                //The Clicks Medation Report graph.
                VStack {
                    Text("Clicks").font(.title3)
                    HStack {
                        Button(action: {
                            currentIndex -= 1
                            clicksStartDate = Date() - TimeInterval(weekInSeconds) * Double((-currentIndex + 1))
                            clicksEndDate = Date()  - TimeInterval(weekInSeconds) * Double(-currentIndex)
                            googleDelegate.clicksMediationData?.rows = []
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
                            Image(systemName: "arrow.backward")
                        }
                        BarChartView(
                            data: ChartData(
                                values: googleDelegate.mapClickMediationDataToChartData() ?? []),
                            title: "Browse",
                            legend: "Date - " + (googleDelegate.admobAccount?.currencyCode ?? ""),
                            style: ChartStyle(backgroundColor: Color.black, accentColor: Color.blue, gradientColor: GradientColor(start: Color.black, end: Color.black), textColor: Color.gray, legendTextColor: Color.blue, dropShadowColor: Color.black),
                            dropShadow: false
                        )
                        Button(action: {
                            if(currentIndex == 0) {
                                return
                            }
                            currentIndex += 1
                            clicksStartDate = Date() - TimeInterval(weekInSeconds) * Double((-currentIndex + 1))
                            clicksEndDate = Date()  - TimeInterval(weekInSeconds) * Double(-currentIndex)
                            googleDelegate.clicksMediationData?.rows = []
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
                            Image(systemName: "arrow.forward")
                        }
                    }
                    HStack {
                        Spacer()
                        VStack {
                            Text("Start Date").foregroundColor(.gray).font(.footnote)
                            Text("\(clicksStartDate, formatter: dateFormatter)")
                        }
                        Spacer()
                        VStack {
                            Text("End Date").foregroundColor(.gray).font(.footnote)
                            Text("\(clicksEndDate, formatter: dateFormatter)")
                        }
                        Spacer()
                    }.padding(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 0))
                    HStack {
                        Spacer()
                        HStack {
                            Text("Range Total:").foregroundColor(.gray).font(.footnote)
                            Text(String(format: "%.2f", googleDelegate.getTotalOfClicksMediationData() ?? 0)).bold()
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(GoogleDelegate())
    }
}
