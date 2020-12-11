import Foundation

struct AdmobMediationHeader: Encodable, Decodable {
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
    
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        startDate = try values.decode(Date.self, forKey: .startDate)
        endDate = try values.decode(Date.self, forKey: .endDate)
        currencyCode = try values.decode(String.self, forKey: .currencyCode)
        languageCode = try values.decode(String.self, forKey: .languageCode)
    }
    
    enum CodingKeys: String, CodingKey {
        case startDate, endDate, currencyCode, languageCode
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(currencyCode, forKey: .currencyCode)
        try container.encode(languageCode, forKey: .languageCode)
    }
    
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
