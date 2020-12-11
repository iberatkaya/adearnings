import SwiftUI
import Charts

struct BarChart: UIViewRepresentable {
    var xValues: [String]
    var yValues: [Double]
    
    func makeUIView(context: Context) -> BarChartView {
        let barChart = BarChartView()
        barChart.drawValueAboveBarEnabled = false
        barChart.legend.enabled = false

        barChart.leftAxis.drawGridLinesEnabled = true
        barChart.leftAxis.gridColor = UIColor.gray.withAlphaComponent(0.25)
        barChart.leftAxis.setLabelCount(12, force: false)

        barChart.rightAxis.drawGridLinesEnabled = false
        barChart.rightAxis.drawLabelsEnabled = false
        barChart.extraRightOffset = 20

        barChart.xAxis.drawGridLinesEnabled = true
        //barChart.xAxis.setLabelCount(10, force: false)
        barChart.xAxis.gridColor = UIColor.gray.withAlphaComponent(0.25)
        
        barChart.doubleTapToZoomEnabled = false
        
        let marker: BalloonMarker = BalloonMarker(
            color: UIColor(white: 180/250, alpha: 1),
            font: UIFont(name: "Helvetica", size: 12)!,                                                  textColor: UIColor.white,
            insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0))
        
        marker.minimumSize = CGSize(width: 60.0, height: 40.0)
        barChart.marker = marker
        
        
        //barChart.rightAxis.drawAxisLineEnabled = false
        return barChart
    }
    
    func updateUIView(_ uiView: BarChartView, context: Context) {
        uiView.setBarChartData(xValues: xValues, yValues: yValues, label: "")
    }
}



struct BarChart_Previews: PreviewProvider {
    static var previews: some View {
        BarChart(xValues: ["August", "September", "October", "November", "December", "January"], yValues: [5, 12, 25, 2, 35, 5])
    }
}
