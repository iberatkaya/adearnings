struct AdmobAccount: Encodable, Decodable {
    init(currencyCode: String, name: String, publisherId: String, reportingTimeZone: String) {
        self.currencyCode = currencyCode
        self.name = name
        self.publisherId = publisherId
        self.reportingTimeZone = reportingTimeZone
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        currencyCode = try values.decode(String.self, forKey: .currencyCode)
        name = try values.decode(String.self, forKey: .name)
        publisherId = try values.decode(String.self, forKey: .publisherId)
        reportingTimeZone = try values.decode(String.self, forKey: .reportingTimeZone)
    }
    
    var currencyCode: String
    var name: String
    var publisherId: String
    var reportingTimeZone: String
    
    var description: String {
        return "AdmobAccount(name: \(name), currencyCode: \(currencyCode), publisherId: \(publisherId), reportingTimeZone: \(reportingTimeZone))"
    }
    
    enum CodingKeys: String, CodingKey {
        case currencyCode, name, publisherId, reportingTimeZone
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currencyCode, forKey: .currencyCode)
        try container.encode(name, forKey: .name)
        try container.encode(publisherId, forKey: .publisherId)
        try container.encode(reportingTimeZone, forKey: .reportingTimeZone)
    }
}
