//
//  String.swift
//  Resolved
//
//  Created by Dante Kim on 7/12/24.
//

import Foundation

extension String {
    func trimmingLeadingZerosFromTime() -> String {
        let parts = split(separator: ":")
        guard let firstPart = parts.first else { return self }
        return firstPart.trimmingCharacters(in: .whitespacesAndNewlines) + suffix(from: firstPart.endIndex)
    }

    subscript(idx: Int) -> String {
        String(self[index(startIndex, offsetBy: idx)])
    }
    
    func toDate(format: String = "dd-MM-yyyy HH:mm:ss") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
}
