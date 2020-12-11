import Foundation

struct MetricValue: Encodable, Decodable {
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
    
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        metric = Metric(rawValue: try values.decode(String.self, forKey: .metric)) ?? Metric.UNKNOWN
        value = try values.decode(Double.self, forKey: .value)
    }
    
    enum CodingKeys: String, CodingKey {
        case metric, value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(metric.rawValue, forKey: .metric)
        try container.encode(value, forKey: .value)
    }
}
