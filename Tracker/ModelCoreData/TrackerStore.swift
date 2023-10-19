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

protocol TrackerStoreDelegate {
    func didUpdate()
}

// MARK: - TrackerStore
final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private let scheduleMarshalling = ScheduleMarshalling()
    
    var delegate: TrackerStoreDelegate?
    
    var insertedIndexes: IndexSet?
    var deletedIndexes: IndexSet?
    
    private lazy var fetchedResultController: NSFetchedResultsController<TrackerCoreData> = {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let sortDescriptor = NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        let frc = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        try? frc.performFetch()
        frc.delegate = self
        return frc
    }()
    
    var trackers: [Tracker] {
        guard
            let objects = fetchedResultController.fetchedObjects,
            let trackers = try? objects.map({
                try makeTrackers(from: $0)
            })
        else { return [] }
        return trackers
    }

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
        trackerCoreData.records = []
        contextSave()
        return trackerCoreData
    }
    
    func updateTracker(value: TrackerRecord) {
        let request = TrackerCoreData.fetchRequest()
        
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(
                TrackerCoreData.trackerID
            ),
            "\(value.id)"
        )
        guard let trackers = try? context.fetch(request) else {
            assertionFailure("Enabled to fetch(request)")
            return
        }
        if let tracker = trackers.first {
            let trackerRec = TrackerRecordCoreData(context: context)
            trackerRec.trackerid = value.id
            trackerRec.date = value.date
            tracker.addToRecords(trackerRec)
            contextSave()
        }
    }

    func makeTrackers(from trackersCoreData: TrackerCoreData) throws -> Tracker {
        print("Making Tracker from TrackerCoreData: \(trackersCoreData)")
        guard let id = trackersCoreData.trackerID,
              let name = trackersCoreData.name,
              let color = trackersCoreData.color,
              let emoji = trackersCoreData.emoji,
              let myScheduleString = trackersCoreData.mySchedule,
              let records = trackersCoreData.records
        else {
            print("Failed to retrieve necessary data from CoreData")
            throw TrackerStoreError.error }
        
        let mySchedule = scheduleMarshalling.convertMyScheduleStringToSet(myScheduleString)

        return Tracker(id: id,
                       name: name,
                       color: uiColorMarshalling.color(from: color),
                       emoji: emoji,
                       mySchedule: mySchedule,
                       records: []
        )
       
    }
    
    private func deleteTracker(with id: UUID) {
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
    
    private func deleteAllTrackers() {
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
// MARK: - extension
extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}
