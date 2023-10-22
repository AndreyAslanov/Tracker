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
    let records: Set<TrackerRecord>
}

enum WeekDay: Int, CaseIterable {
    case monday = 0
    case tuesday = 1
    case wednesday = 2
    case thursday = 3
    case friday = 4
    case saturday = 5
    case sunday = 6
    
    static func weekDay(for day: Int) -> String {
        switch day {
        case 0: return "Понедельник"
        case 1: return "Вторник"
        case 2: return "Среда"
        case 3: return "Четверг"
        case 4: return "Пятница"
        case 5: return "Суббота"
        case 6: return "Воскресенье"
        default: return ""
        }
    }
    
    static func shortName(for day: Int) -> String {
        switch day {
        case 0: return "Пн"
        case 1: return "Вт"
        case 2: return "Ср"
        case 3: return "Чт"
        case 4: return "Пт"
        case 5: return "Сб"
        case 6: return "Вс"
        default: return ""
        }
    }
}
