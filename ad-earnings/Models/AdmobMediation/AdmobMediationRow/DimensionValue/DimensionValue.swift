import Foundation

struct DimensionValue: Encodable {
    init(dimension: Dimension, value: String, displayLabel: String? = nil) {
        self.dimension = dimension
        self.value = value
        self.displayLabel = displayLabel
    }
    
    init(dimension: String, value: String, displayLabel: String? = nil){
        self.dimension = Dimension(rawValue: dimension) ?? Dimension.UNKNOWN
        self.value = value
        self.displayLabel = displayLabel
    }
    
    var dimension: Dimension
    var value: String
    var displayLabel: String?
    
    
    enum CodingKeys: String, CodingKey {
        case dimension, value, displayLabel
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dimension.rawValue, forKey: .dimension)
        try container.encode(value, forKey: .value)
        try container.encode(displayLabel, forKey: .displayLabel)
    }
}
