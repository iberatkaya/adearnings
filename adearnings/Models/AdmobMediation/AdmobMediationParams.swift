import Foundation

struct AdmobMediationParams {
    init(startDate: Date, endDate: Date, accountInfo: AdmobAccount, dimension: Dimension, sort: Sort, metric: Metric) {
        self.startDate = startDate
        self.endDate = endDate
        self.accountInfo = accountInfo
        self.dimension = dimension
        self.sort = sort
        self.metric = metric
    }
    
    ///The start date of the analytics range.
    var startDate: Date
    
    ///The end date of the analytics range.
    var endDate: Date
    
    ///The Admob account information.
    var accountInfo: AdmobAccount
    
    ///The analytics data attribution.
    var dimension: Dimension
    
    ///The sorting of the analytics.
    var sort: Sort
    
    ///The analytics metric.
    var metric: Metric
    
    
    ///Convert the Struct into a Dictionary sendable to Google AdMob API
    func toDict() -> [String: Any] {
        let calendarStartDate = Calendar.current.dateComponents([.day, .year, .month], from: startDate)
        let calendarEndDate = Calendar.current.dateComponents([.day, .year, .month], from: endDate)
        
        return [
            "reportSpec": [
                "dateRange": [
                    "startDate": ["year": calendarStartDate.year, "month": calendarStartDate.month, "day": calendarStartDate.day],
                    "endDate": ["year": calendarEndDate.year, "month": calendarEndDate.month, "day": calendarEndDate.day]
                ],
                "dimensions": [String(describing: dimension)],
                "metrics": [String(describing: metric)],
                "dimensionFilters": [],
                "sortConditions": [
                    ["dimension": String(describing: dimension), "order": String(describing: sort)]
                ],
                "localizationSettings": [
                    "currencyCode": accountInfo.currencyCode,
                    "languageCode": "en-US"
                ]
            ]
        ]
    }
}
