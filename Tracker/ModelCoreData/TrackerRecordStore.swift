//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Андрей Асланов on 04.10.23.
//

import UIKit
import CoreData

final class TrackerRecordStore: NSObject {
    static let shared = TrackerRecordStore()
    
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let sortDescriptor = NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        try? controller.performFetch()
        return controller
    }()
    
    var trackerRecords: [TrackerRecord] {
        guard let objects = fetchedResultController.fetchedObjects,
              let trackerRecords = try? objects.map({ try makeTrackerRecord(from: $0) })
        else { return [] }
        return trackerRecords
    }
    
//    convenience override init() {
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistantContainer.viewContext
//        self.init(context: context)
//    }
//
//    init(context: NSManagedObjectContext) {
//        self.context = context
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
    
    func makeTrackerRecord(from trackerRecordsCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let id = trackerRecordsCoreData.trackerid,
              let date = trackerRecordsCoreData.date
        else { throw TrackerStoreError.error }
        return TrackerRecord(id: id, date: date)
    }
    
    func createTrackerRecord(from trackerRecord: TrackerRecord) throws -> TrackerRecordCoreData {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.trackerid = trackerRecord.id
        trackerRecordCoreData.date = trackerRecord.date
        contextSave()
        return trackerRecordCoreData
    }
    
    func deleteTrackerRecord(trackerRecord: TrackerRecord) {
        guard let objects = fetchedResultController.fetchedObjects else { return }
        _ = objects.last { trackerRecordCoreData in
            if trackerRecordCoreData.trackerid == trackerRecord.id {
                context.delete(trackerRecordCoreData)
            }
            return true
        }
        contextSave()
    }
    
    func deleteTrackerRecord(with id: UUID) {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.trackerid), id.uuidString)
        guard let trackerRecords = try? context.fetch(request) else {
            assertionFailure("Enabled to fetch(request)")
            return
        }
        if let trackerRecordDelete = trackerRecords.first {
            context.delete(trackerRecordDelete)
            contextSave()
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
    
    func saveCompletedTracker(_ completedTracker: CompletedTracker) {
        let trackerRecord = TrackerRecord(id: completedTracker.trackerId, date: completedTracker.date)

        do {
            try createTrackerRecord(from: trackerRecord)
            
            // Вывести сохраненные отметки выполнения трекеров в консоль для проверки
            let savedTrackerRecords = TrackerRecordStore.shared.trackerRecords
            print("Сохраненные отметки выполнения трекеров: \(savedTrackerRecords)")
        } catch {
            print("Ошибка при сохранении отметки выполнения трекера в Core Data: \(error)")
        }
    }
}
