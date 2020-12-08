import SwiftUI
import Charts

struct BarChart: UIViewRepresentable {
    var xValues: [String]
    var yValues: [Double]
    
    func makeUIView(context: Context) -> BarChartView {
        let barChart = BarChartView()
        barChart.drawValueAboveBarEnabled = false
        barChart.legend.enabled = false
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.leftAxis.drawGridLinesEnabled = false
        barChart.rightAxis.drawGridLinesEnabled = false
        return barChart
    }
    
    func updateUIView(_ uiView: BarChartView, context: Context) {
        uiView.setBarChartData(xValues: xValues, yValues: yValues, label: "")
    }
}



struct BarChart_Previews: PreviewProvider {
    static var previews: some View {
        BarChart(xValues: ["August"], yValues: [5])
    }
}
