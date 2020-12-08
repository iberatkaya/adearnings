import Foundation

struct DimensionValue {
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
}
