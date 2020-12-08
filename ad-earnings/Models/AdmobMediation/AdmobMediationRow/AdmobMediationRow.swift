import Foundation

struct AdmobMediationRow {
    init(dimensionValue: DimensionValue, metricValue: MetricValue) {
        self.dimensionValue = dimensionValue
        self.metricValue = metricValue
    }
    
    var dimensionValue: DimensionValue
    var metricValue: MetricValue
    
    static func fromDict(json: [String: Any]) -> AdmobMediationRow? {
        guard let dimensionValues = json["dimensionValues"] as? [String: Any],
              let metricValues = json["metricValues"] as? [String: Any]
        else {
            return nil
        }
        
        guard let dimensionKey = dimensionValues.first?.key,
              let dimensionVal = dimensionValues.first?.value as? [String: Any],
              let metricKey = metricValues.first?.key,
              let metricVal = metricValues.first?.value as? [String: Any]
        else {
            return nil
        }
        
        guard let dimensionValue = dimensionVal["value"] as? String,
              let metricValue = (metricVal["microsValue"] as? NSString)?.doubleValue
        else {
                return nil
        }
        
        if let dimensionLabel = dimensionVal["displayLabel"] as? String {
            return AdmobMediationRow(
                dimensionValue: DimensionValue(
                    dimension: dimensionKey,
                    value: dimensionValue,
                    displayLabel: dimensionLabel
                ),
                metricValue: MetricValue(
                    metric: metricKey,
                    value: metricValue / 1_000_000
                )
            )
        }
        return AdmobMediationRow(
            dimensionValue: DimensionValue(
                dimension: dimensionKey,
                value: dimensionValue
            ),
            metricValue: MetricValue(
                metric: metricKey,
                value: metricValue / 1_000_000
            )
        )
    }
}
