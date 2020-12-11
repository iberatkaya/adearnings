/**
 * Taken from https://github.com/danielgindi/Charts/issues/1340#issuecomment-290653524.
 * @author https://github.com/AlexSmet
 */

import Charts

extension BarChartView {

    private class BarChartFormatter: NSObject, IAxisValueFormatter {
        
        var labels: [String]
        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return labels[Int(value)]
        }
        
        init(labels: [String]) {
            self.labels = labels
        }
    }
    
    func setBarChartData(xValues: [String], yValues: [Double], label: String) {
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<yValues.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: yValues[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: label)
        chartDataSet.colors = [NSUIColor.blue.withAlphaComponent(0.6), NSUIColor.blue.withAlphaComponent(0.4)]
        chartDataSet.drawValuesEnabled = false
        chartDataSet.highlightColor = NSUIColor.red
        let chartData = BarChartData(dataSet: chartDataSet)
        
        let chartFormatter = BarChartFormatter(labels: xValues)
        let xAxis = XAxis()
        xAxis.valueFormatter = chartFormatter
        xAxis.forceLabelsEnabled = true
        self.xAxis.valueFormatter = xAxis.valueFormatter
        
        self.data = chartData
    }
} 
