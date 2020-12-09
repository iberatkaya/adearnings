///Taken from https://stackoverflow.com/a/32581409
///@author https://stackoverflow.com/users/746804/sebastian

import Darwin

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
