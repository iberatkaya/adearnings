import Foundation

struct AdmobMediationFooter: Encodable, Decodable {
    init(matchingRowCount: Int) {
        self.matchingRowCount = matchingRowCount
    }
    
    var matchingRowCount: Int
    
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        matchingRowCount = try values.decode(Int.self, forKey: .matchingRowCount)
    }
    
    enum CodingKeys: String, CodingKey {
        case matchingRowCount
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(matchingRowCount, forKey: .matchingRowCount)
    }
    
    static func fromDict(json: [String: Any]) -> AdmobMediationFooter? {
        guard let matchingRowCountStr = json["matchingRowCount"] as? NSString,
              let matchingRowCount = Int(matchingRowCountStr as String)
        else {
            return nil
        }
        return AdmobMediationFooter(
            matchingRowCount: matchingRowCount
        )
    }
}
