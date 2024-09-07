//
//  Note.swift
//  SimpleNotes
//
//  Created by Matthew Zierl on 8/15/24.
//

import Foundation

class Note: NSObject, Codable {
    
    var title: String = ""
    var body: String = ""
    var isLocked = false
    var dateCreated: Date = Date.now
    var dateModified: Date = Date.now {
        didSet {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.month, .year], from: dateModified) // for now, sorting by
            if let month = components.month, let year = components.year {
                key = "\(getNameMonth(month: month)) \(year)"
            }
        }
    }
    var key: String = "Unknown"
    
    func getNameMonth(month: Int) -> String {
        switch month {
        case 1:
            return "January"
        case 2:
            return "February"
        case 3:
            return "March"
        case 4:
            return "April"
        case 5:
            return "May"
        case 6:
            return "June"
        case 7:
            return "July"
        case 8:
            return "August"
        case 9:
            return "September"
        case 10:
            return "October"
        case 11:
            return "November"
        case 12:
            return "December"
        default:
            return "Uknown"
        }
    }
}
