import Foundation

///A Date extension taken from https://stackoverflow.com/a/52704760
extension Date {
    
    /// Create a date from specified parameters
    ///
    /// - Parameters:
    ///   - year: The desired year
    ///   - month: The desired month
    ///   - day: The desired day
    /// - Returns: A `Date` object
    static func from(year: Int, month: Int, day: Int) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return calendar.date(from: dateComponents) ?? nil
    }
    
    /**
     * A date adder method taken from https://stackoverflow.com/a/41395355
     * @author https://stackoverflow.com/users/6433023/nirav-d
     */
    func getDateFor(days:Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: days, to: Date())
    }
}
