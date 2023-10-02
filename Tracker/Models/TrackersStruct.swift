//
//  TrackersStruct.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import UIKit

struct TrackerCellViewModel {
    let name: String
    let emoji: String
    let color: UIColor?
    var trackerIsDone: Bool
    let doneButtonIsEnabled: Bool
    var counter: UInt
    let id: UUID
    
    func updated(trackerIsDone: Bool, counter: UInt) -> TrackerCellViewModel {
        return TrackerCellViewModel(
            name: self.name,
            emoji: self.emoji,
            color: self.color,
            trackerIsDone: trackerIsDone,
            doneButtonIsEnabled: self.doneButtonIsEnabled,
            counter: counter,
            id: self.id
        )
    }
}
