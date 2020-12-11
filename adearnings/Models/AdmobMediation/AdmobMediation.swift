import Foundation

struct AdmobMediation: Encodable, Decodable {
    init(header: AdmobMediationHeader, rows: [AdmobMediationRow], footer: AdmobMediationFooter) {
        self.header = header
        self.rows = rows
        self.footer = footer
    }
    
    var header: AdmobMediationHeader
    var rows: [AdmobMediationRow]
    var footer: AdmobMediationFooter
    
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        header = try values.decode(AdmobMediationHeader.self, forKey: .header)
        rows = try values.decode([AdmobMediationRow].self, forKey: .rows)
        footer = try values.decode(AdmobMediationFooter.self, forKey: .footer)
    }
    
    enum CodingKeys: String, CodingKey {
        case header, rows, footer
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(header, forKey: .header)
        try container.encode(rows, forKey: .rows)
        try container.encode(footer, forKey: .footer)
    }
    
    static func fromDicts(jsons: [[String: Any]]) -> AdmobMediation? {
        var header: AdmobMediationHeader?
        var rows: [AdmobMediationRow] = []
        var footer: AdmobMediationFooter?
        for json in jsons {
            for (key, val) in json {
                if key == "footer" {
                    footer = AdmobMediationFooter.fromDict(json: val as! [String : Any])
                }
                else if key == "header" {
                    header = AdmobMediationHeader.fromDict(json: val as! [String : Any])
                }
                else if key == "row" {
                    if let row: AdmobMediationRow = AdmobMediationRow.fromDict(json: val as! [String : Any]) {
                        rows.append(row)
                    }
                }
            }
        }
        if let footer = footer, let header = header {
            return AdmobMediation(header: header, rows: rows, footer: footer)
        }
        else {
            return nil
        }
    }
}


enum Dimension: String {
    case APP = "APP",
         COUNTRY = "COUNTRY",
         PLATFORM = "PLATFORM",
         MONTH = "MONTH",
         WEEK = "WEEK",
         DATE = "DATE",
         UNKNOWN = "UNKNOWN"
}

enum Sort: String {
    case ASCENDING = "ASCENDING",
         DESCENDING = "DESCENDING",
         UNKNOWN = "UNKNOWN"
}

enum Metric: String {
    case ESTIMATED_EARNINGS = "ESTIMATED_EARNINGS",
         CLICKS = "CLICKS",
         IMPRESSIONS = "IMPRESSIONS",
         UNKNOWN = "UNKNOWN"
}
