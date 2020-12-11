import SwiftUI
import SwiftUICharts

struct HomeView: View {
    @EnvironmentObject var connectivityController: ConnectivityController
    
    @EnvironmentObject var googleDelegate: GoogleDelegate
    
    ///The current index used to go over the weeks in the Bar Chart.
    @State var currentIndex = 0
    
    ///The start date of the analytics.
    @State var startDate = Date() - TimeInterval(weekInSeconds)
    ///The end date of the analytics.
    @State var endDate = Date()
    
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
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                BarChartView(
                    data: ChartData(
                        values: googleDelegate.mapCurrentWeekMediationDataToChartData() ?? []),
                    title: "Week",
                    legend: "Date - " + (googleDelegate.admobAccount?.currencyCode ?? ""),
                    style: ChartStyle(backgroundColor: Color.black, accentColor: Color.blue, gradientColor: GradientColor(start: Color.black, end: Color.black), textColor: Color.gray, legendTextColor: Color.blue, dropShadowColor: Color.black),
                    dropShadow: false
                )
                HStack {
                    Button(action: {
                        currentIndex -= 1
                        startDate = Date() - TimeInterval(weekInSeconds) * Double((-currentIndex + 1))
                        endDate = Date()  - TimeInterval(weekInSeconds) * Double(-currentIndex)
                        googleDelegate.mediationReport(
                            startDate: startDate,
                            endDate: endDate
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
                        startDate = Date() - TimeInterval(weekInSeconds) * Double((-currentIndex + 1))
                        endDate = Date()  - TimeInterval(weekInSeconds) * Double(-currentIndex)
                        googleDelegate.mediationReport(
                            startDate: startDate,
                            endDate: endDate
                        )
                    }) {
                        Image(systemName: "arrow.forward")
                    }
                }
                HStack {
                    Spacer()
                    VStack {
                        Text("Start Date").foregroundColor(.gray).font(.footnote)
                        Text("\(startDate, formatter: dateFormatter)")
                    }
                    Spacer()
                    VStack {
                        Text("End Date").foregroundColor(.gray).font(.footnote)
                        Text("\(endDate, formatter: dateFormatter)")
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
                HStack {
                    Spacer()
                    Button(action: {
                        startDate = Date() - TimeInterval(weekInSeconds)
                        endDate = Date()
                        self.googleDelegate.fetchCurrentWeekMediationReport()
                    }) {
                        Text("Refresh")
                    }
                    
                    Spacer()
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
