//
//  Tracker.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let mySchedule: Set <WeekDay>
    let records: Set <TrackerRecord>
    var isPinned: Bool
    var mainCategory: String
}

enum WeekDay: Int, CaseIterable {
    case monday = 0
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var fullDayName: String {
        switch self {
        case .monday: return LocalizableStringKeys.monday
        case .tuesday: return LocalizableStringKeys.tuesday
        case .wednesday: return LocalizableStringKeys.wednesday
        case .thursday: return LocalizableStringKeys.thursday
        case .friday: return LocalizableStringKeys.friday
        case .saturday: return LocalizableStringKeys.saturday
        case .sunday: return LocalizableStringKeys.sunday
        }
    }
    
    var shortDayName: String {
        switch self {
        case .monday: return LocalizableStringKeys.mon
        case .tuesday: return LocalizableStringKeys.tue
        case .wednesday: return LocalizableStringKeys.wed
        case .thursday: return LocalizableStringKeys.thu
        case .friday: return LocalizableStringKeys.fri
        case .saturday: return LocalizableStringKeys.sat
        case .sunday: return LocalizableStringKeys.sun
        }
    }
    
    static func fromRawValue(_ rawValue: Int) -> WeekDay? {
        return WeekDay(rawValue: rawValue)
    }
}
