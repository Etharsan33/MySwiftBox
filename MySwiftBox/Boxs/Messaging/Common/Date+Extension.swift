//
//  Date+Extension.swift
//  MySwiftBox
//
//  Created by Elankumaran Tharsan on 12/10/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import Foundation

// MARK: - Date extension
public extension Date {
    
    /// HHhmm Date formatter
    static let messageTimeFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "CEST")
        formatter.dateFormat = "dd/MM/YYYY - HH:mm"
        return formatter
    }()
    
    var messageTimeStyle: String {
        return Date.messageTimeFormatter.string(from: self)
    }
}

