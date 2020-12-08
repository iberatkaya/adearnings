import Foundation

struct AdmobMediationHeader {
    init(startDate: Date, endDate: Date, currencyCode: String, languageCode: String) {
        self.startDate = startDate
        self.endDate = endDate
        self.currencyCode = currencyCode
        self.languageCode = languageCode
    }
    
    var startDate: Date
    var endDate: Date
    var currencyCode: String
    var languageCode: String
    
    static func fromDict(json: [String: Any]) -> AdmobMediationHeader? {
        guard let dateRange = json["dateRange"] as? [String : Any] else {
            return nil
        }
        guard let startDateDict = dateRange["startDate"] as? [String : Any],
              let endDateDict = dateRange["endDate"] as? [String: Any],
              let localizationSettingsDict: [String: Any] = json["localizationSettings"] as? [String : Any]
        else {
            return nil
        }
        
        guard let startYear = startDateDict["year"] as? Int,
              let startMonth = startDateDict["month"] as? Int,
              let startDay = startDateDict["day"] as? Int,
              let startDate = Date.from(year: startYear, month: startMonth, day: startDay)
        else {
            return nil
        }
        
        guard let endYear = endDateDict["year"] as? Int,
              let endMonth = endDateDict["month"] as? Int,
              let endDay = endDateDict["day"] as? Int,
              let endDate = Date.from(year: endYear, month: endMonth, day: endDay)
        else {
            return nil
        }
        
        guard let currencyCode = localizationSettingsDict["currencyCode"] as? String,
              let languageCode = localizationSettingsDict["languageCode"] as? String
        else {
            return nil
        }
        
        return AdmobMediationHeader(
            startDate: startDate,
            endDate: endDate,
            currencyCode: currencyCode,
            languageCode: languageCode
        )
    }
}
