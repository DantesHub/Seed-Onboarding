//
//  GetDate.swift
//  Resolved
//
//  Created by Gaganjot Singh on 12/11/24.
//

import Foundation

class GetDate {
    static func yesterday() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: -1, to: Date())!
    }
    
    static func tomorrow() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 1, to: Date())!
    }
}
