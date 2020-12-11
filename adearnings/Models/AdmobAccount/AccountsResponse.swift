/*
 Example response
 {
   "account": [
     {
       "name": "accounts/pub-1234",
       "publisherId": "pub-1234",
       "reportingTimeZone": "Europe/Istanbul",
       "currencyCode": "TRY"
     }
   ]
 }
 */

struct AccountsResponse: Decodable {
    init(account: [AdmobAccount]) {
        self.account = account
    }
    
    var account: [AdmobAccount]
    
    enum CodingKeys: String, CodingKey {
        case account
    }
}
