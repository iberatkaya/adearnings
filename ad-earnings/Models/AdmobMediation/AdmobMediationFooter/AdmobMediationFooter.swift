import Foundation

struct AdmobMediationFooter {
    init(matchingRowCount: Int) {
        self.matchingRowCount = matchingRowCount
    }
    
    var matchingRowCount: Int
    
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
