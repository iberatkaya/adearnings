import Foundation

struct MetricValue {
    init(metric: Metric, value: Double) {
        self.metric = metric
        self.value = value
    }
    
    init(metric: String, value: Double) {
        self.metric = Metric(rawValue: metric) ?? Metric.UNKNOWN
        self.value = value
    }
    
    var metric: Metric
    var value: Double
}
