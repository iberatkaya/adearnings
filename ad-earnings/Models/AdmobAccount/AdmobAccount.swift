struct AdmobAccount: Decodable {
    init(currencyCode: String, name: String, publisherId: String, reportingTimeZone: String) {
        self.currencyCode = currencyCode
        self.name = name
        self.publisherId = publisherId
        self.reportingTimeZone = reportingTimeZone
    }
    
    var currencyCode: String
    var name: String
    var publisherId: String
    var reportingTimeZone: String
    
    enum CodingKeys: String, CodingKey {
        case currencyCode, name, publisherId, reportingTimeZone
    }
}
