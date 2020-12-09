import Foundation

struct MetricValue: Encodable {
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
    
    
    enum CodingKeys: String, CodingKey {
        case metric, value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(metric.rawValue, forKey: .metric)
        try container.encode(value, forKey: .value)
    }
}
