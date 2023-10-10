//
//  TrackerManager.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import Foundation

// MARK: - CompletedTracker
struct CompletedTracker {
    let trackerId: UUID
    let date: Date
}

// MARK: - TrackerManager
class TrackerManager {
    static let shared = TrackerManager()
    
    private var completedTrackers: [CompletedTracker] = []
    
    func markTrackerAsCompleted(trackerId: UUID, date: Date) {
        let completedTracker = CompletedTracker(trackerId: trackerId, date: date)
        completedTrackers.append(completedTracker)
        
        let savedCompletedTrackers = completedTrackers
         print("Выполненные трекеры: \(savedCompletedTrackers)")
         
         TrackerRecordStore.shared.saveCompletedTracker(completedTracker)
    }
    
    func isTrackerCompleted(trackerId: UUID, date: Date) -> Bool {
        return completedTrackers.contains { $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func getCompletionCount(for trackerId: UUID) -> Int {
        return completedTrackers.filter { $0.trackerId == trackerId }.count
    }
    
    func decreaseCompletionCount(trackerId: UUID, date: Date) {
        if let index = completedTrackers.firstIndex(where: { $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            completedTrackers.remove(at: index)
        }
    }
    
    func clearCompletedTrackers() {
        completedTrackers.removeAll()
    }
}


