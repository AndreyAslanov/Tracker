//
//  TrackerStore.swift
//  Tracker
//
//  Created by Андрей Асланов on 04.10.23.
//

import UIKit
import CoreData

enum TrackerStoreError: Error {
    case error
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private let scheduleMarshalling = ScheduleMarshalling()
    
    private lazy var fetchedResultController: NSFetchedResultsController<TrackerCoreData> = {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let sortDescriptor = NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        try? controller.performFetch()
        return controller
    }()
    
    var trackers: [Tracker] {
        guard let objects = fetchedResultController.fetchedObjects,
              let trackers = try? objects.map({ try makeTrackers(from: $0) })
        else { return [] }
        return trackers
    }
    
//    convenience override init() {
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistantContainer.viewContext
//        self.init(context: context)
//        print("TrackerStore initialized")
//    }
//
//    init(context: NSManagedObjectContext) {
//        self.context = context
//        print("TrackerStore initialized with context: \(context)")
//    }
    
    convenience override init() {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let context = appDelegate.persistantContainer.viewContext
                self.init(context: context)
            } else {
                fatalError("Unable to access the AppDelegate")
            }
        }

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    func createTracker(from tracker: Tracker) throws -> TrackerCoreData {
        print("Creating TrackerCoreData from Tracker: \(tracker)")
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.trackerID = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.mySchedule = scheduleMarshalling.convertSetToMyScheduleString(tracker.mySchedule)
        contextSave()
        return trackerCoreData
    }

    func makeTrackers(from trackersCoreData: TrackerCoreData) throws -> Tracker {
        print("Making Tracker from TrackerCoreData: \(trackersCoreData)")
        guard let id = trackersCoreData.trackerID,
              let name = trackersCoreData.name,
              let color = trackersCoreData.color,
              let emoji = trackersCoreData.emoji,
              let myScheduleString = trackersCoreData.mySchedule
        else { throw TrackerStoreError.error }
        
        let mySchedule = scheduleMarshalling.convertMyScheduleStringToSet(myScheduleString)

        return Tracker(id: id,
                       name: name,
                       color: uiColorMarshalling.color(from: color),
                       emoji: emoji,
                       mySchedule: mySchedule)
    }
    
    func deleteTracker(with id: UUID) {
        print("Deleting Tracker with id: \(id)")
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerID), id.uuidString)
        guard let trackers = try? context.fetch(request) else {
            assertionFailure("Enabled to fetch(request)")
            return
        }
        if let trackerDelete = trackers.first {
            context.delete(trackerDelete)
            contextSave()
        }
    }
    
    func deleteAllTrackers() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TrackerCoreData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            contextSave()
            print("Все трекеры успешно удалены из Core Data.")
        } catch {
            let error = error as NSError
            print("Ошибка при удалении всех трекеров из Core Data: \(error.localizedDescription)")
        }
    }

    private func contextSave() {
        do {
            try context.save()
            print("Данные успешно сохранены в CoreData.")
        } catch {
            let error = error as NSError
            assertionFailure("Failed to save context: \(error.localizedDescription)")
            print("Ошибка при сохранении данных в CoreData: \(error.localizedDescription)")
        }
    }
}
