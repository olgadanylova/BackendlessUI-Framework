
import Foundation

extension NSObject {
    
    // ********** Date convert **********
    
    func stringToDate(_ stringValue: String?) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy h:mm a Z"
        if let date = dateFormatter.date(from: stringValue!) {
            return date
        }
        return Date()
    }
    
    func dateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy h:mm a Z"
        return dateFormatter.string(from: date)
    }
}
