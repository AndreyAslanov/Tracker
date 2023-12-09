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

protocol TrackerViewControllerDataSource {
    func numberOfSections() -> Int
    func dataForCell(at indexPath: IndexPath) -> Tracker?
    func numberOfRows(at section: Int) -> Int
    func titleForSection(section: Int) -> String
}

// MARK: - TrackerStore
final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private let scheduleMarshalling = ScheduleMarshalling()
    static let trackerStore = TrackerStore()
    
    var delegate: TrackerStoreDelegate?
    var dataSource: TrackerViewControllerDataSource?
    var statisticViewModel: StatisticViewModel?
    var trackerViewController: TrackerViewController?
    
    var insertedIndexes: IndexSet?
    var deletedIndexes: IndexSet?
    
    private var currentNameFilter: String?
    private var currentFilterWeekDay: Int = 0
    private var selectedCategory: String?
    
    lazy var fetchedResultController: NSFetchedResultsController<TrackerCoreData> = {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")

        let pinnedSortDescriptor = NSSortDescriptor(keyPath: \TrackerCoreData.isPinned, ascending: false)
        let categorySortDescriptor = NSSortDescriptor(keyPath: \TrackerCoreData.category?.titleCategory, ascending: false)

        request.sortDescriptors = [pinnedSortDescriptor, categorySortDescriptor]

        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: #keyPath(TrackerCoreData.category.titleCategory),
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
        print("trackers: \(trackers)")
        return trackers
    }
    
    var pinnedTrackers: [Tracker] {
        guard let objects = self.fetchedResultController.fetchedObjects else {
            return []
        }
        let pinnedTrackers = try? objects.compactMap { try self.makeTrackers(from: $0) }.filter { $0.isPinned }
        return pinnedTrackers ?? []
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
    
    func updateCategoryPredicate(category: String?) {
        selectedCategory = category
        applyCurrentPredicates()
    }

    func updateNameFilter(nameFilter: String?) {
        currentNameFilter = nameFilter
        applyCurrentPredicates()
    }

    func updateDayOfWeekPredicate(for date: Date) {
        currentFilterWeekDay = (Calendar.current.component(.weekday, from: date) + 5) % 7
        let dayPredicate = NSPredicate(format: "mySchedule CONTAINS[c] %@", "\(currentFilterWeekDay)")
        fetchedResultController.fetchRequest.predicate = dayPredicate

        do {
            try fetchedResultController.performFetch()
        } catch {
            print("Error performing fetch: \(error)")
        }
    }

    func applyCurrentPredicates() {
        var predicates: [NSPredicate] = []
        // Предикат для дня недели
        predicates.append(NSPredicate(format: "mySchedule CONTAINS[c] %@", "\(currentFilterWeekDay)"))
        // Предикат для категории
        if let category = selectedCategory {
            predicates.append(NSPredicate(format: "category.name == %@", category))
        }
        // Предикат для фильтрации по названию трекера
        if let nameFilter = currentNameFilter, !nameFilter.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[c] %@", nameFilter))
        }
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchedResultController.fetchRequest.predicate = compoundPredicate
        do {
            try fetchedResultController.performFetch()
        } catch {
            print("Error performing fetch: \(error)")
        }
    }
    
    func createTracker(from tracker: Tracker, category: TrackerCategoryCoreData) {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.trackerID = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.mySchedule = tracker.mySchedule.map { $0.rawValue }.map(String.init).joined(separator: ",")
        trackerCoreData.isPinned = tracker.isPinned
        trackerCoreData.category = category
        trackerCoreData.mainCategory = tracker.mainCategory
        trackerCoreData.records = []
        contextSave()
        print("Tracker created with isPinned: \(tracker.isPinned)")
    }
    
    func updateTracker(value: TrackerRecord) {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerID), "\(value.id)")
        
        guard let trackers = try? context.fetch(request) else {
            assertionFailure("Enabled to fetch(request)")
            return
        }
        if let tracker = trackers.first {
            let trackerRecording = TrackerRecordCoreData(context: context)
            trackerRecording.trackerid = value.id
            trackerRecording.date = value.date
            tracker.addToRecords(trackerRecording)
            contextSave()
            notifyStatisticsModel()
        }
    }
    
    private func notifyStatisticsModel() {
        statisticViewModel?.viewWillAppear()
    }
    
    func setStatisticViewModel(_ viewModel: StatisticViewModel) {
        statisticViewModel = viewModel
    }

    func makeTrackers(from trackersCoreData: TrackerCoreData) throws -> Tracker {
        print("Making Tracker from TrackerCoreData: \(trackersCoreData)")
        guard let id = trackersCoreData.trackerID,
              let name = trackersCoreData.name,
              let color = trackersCoreData.color,
              let emoji = trackersCoreData.emoji,
              let myScheduleString = trackersCoreData.mySchedule,
              let records = trackersCoreData.records,
              let mainCategory = trackersCoreData.mainCategory
        else {
            print("Failed to retrieve necessary data from CoreData")
            throw TrackerStoreError.error }
        
        let mySchedule = scheduleMarshalling.convertMyScheduleStringToSet(myScheduleString)
        print("My Schedule: \(mySchedule)")
        
        let isPinned = trackersCoreData.isPinned

        return Tracker(id: id,
                       name: name,
                       color: uiColorMarshalling.color(from: color),
                       emoji: emoji,
                       mySchedule: mySchedule,
                       records: [],
                       isPinned: isPinned,
                       mainCategory: mainCategory
        )
       
    }
    
    func deleteTracker(with id: UUID) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerID), id.uuidString)
        do {
            let results = try context.fetch(request)
            for object in results {
                if let trackerObject = object as? TrackerCoreData {
                    if let records = trackerObject.records {
                        for case let record as TrackerRecordCoreData in records {
                            context.delete(record)
                        }
                    }
                    context.delete(trackerObject)
                }
            }
            contextSave()
        } catch {
            print("Error fetching and deleting trackers: \(error)")
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
    
    func getTracker(with id: UUID) -> Tracker? {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerID), id.uuidString)

        guard let trackerCoreData = try? context.fetch(request).first else {
            return nil // Возвращаем nil, если трекер не найден
        }
            
        do {
            return try makeTrackers(from: trackerCoreData)
        } catch {
            print("Error making Tracker from CoreData: \(error)")
            return nil
        }
    }
    
    func getTrackerCoreData(from tracker: Tracker) -> TrackerCoreData? {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerID), tracker.id.uuidString)
        guard let trackerCoreData = try? context.fetch(request).first else {
            return nil
        }
        return trackerCoreData
    }
    
    func setIsPinned(for tracker: Tracker) {
        guard var trackerCoreData = getTrackerCoreData(from: tracker) else {
            return
        }

        print(#function, "Tracker \(tracker.name) isPinned: \(trackerCoreData.isPinned)")
        trackerCoreData.isPinned.toggle()

        print("Tracker \(tracker.name) isPinned: \(trackerCoreData.isPinned)")

        if trackerCoreData.isPinned {
            if let pinnedCategory = TrackerCategoryStore.shared.fetchedCategory(with: LocalizableStringKeys.pinned) {
                pinnedCategory.addToTrackers(trackerCoreData)
            }
        } else {
            let mainCategoryTitle = tracker.mainCategory
            if !mainCategoryTitle.isEmpty,
                let mainCategory = TrackerCategoryStore.shared.fetchedCategory(with: mainCategoryTitle) {
                mainCategory.addToTrackers(trackerCoreData)
            }
            print("Tracker \(tracker.name) unpinned successfully.")
        }

        contextSave()
        delegate?.didUpdate()
    }
    
    func getMainCategoryByTrackerID(_ trackerID: UUID) -> String? {
        guard let objects = self.fetchedResultController.fetchedObjects else {
            return nil
        }

        if let coreDataTracker = objects.first(where: { $0.trackerID == trackerID }) {
            return coreDataTracker.mainCategory
        }

        return nil
    }
}
// MARK: - extension
extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
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

extension TrackerStore: TrackerViewControllerDataSource {
    func numberOfSections() -> Int {
        return fetchedResultController.sections?.count ?? 0
    }
    
    func dataForCell(at indexPath: IndexPath) -> Tracker? {
        return try? makeTrackers(from: fetchedResultController.object(at: indexPath))
    }

    func numberOfRows(at section: Int) -> Int {
        return fetchedResultController.sections?[section].numberOfObjects ?? 0
    }

    func titleForSection(section: Int) -> String {
        return fetchedResultController.sections?[section].name ?? ""

    }
}

extension TrackerStore {
    func filterForToday() {
        let currentDate = Date().withoutTime()
        let datePredicate = NSPredicate(format: "ANY records.date == %@", currentDate! as NSDate)
        fetchedResultController.fetchRequest.predicate = datePredicate

        do {
            try fetchedResultController.performFetch()
        } catch {
            print("Error performing fetch: \(error)")
        }
    }

    func filterCompleted(for date: Date) -> Bool {
        let completedPredicate = NSPredicate(format: "ANY records.date == %@", date as NSDate)
        fetchedResultController.fetchRequest.predicate = completedPredicate

        do {
            try fetchedResultController.performFetch()
            return true
        } catch {
            print("Error performing fetch: \(error)")
            return false
        }
    }

    func filterNotCompleted(for date: Date) {
        let currentFilterWeekDay = (Calendar.current.component(.weekday, from: date) + 5) % 7
        let notCompletedPredicate = NSPredicate(format: "SUBQUERY(records, $record, $record.date == %@).@count == 0 AND mySchedule CONTAINS[c] %@", date as NSDate, "\(currentFilterWeekDay)")
        fetchedResultController.fetchRequest.predicate = notCompletedPredicate

        do {
            try fetchedResultController.performFetch()
            print("Filter not completed result count: \(fetchedResultController.sections?.first?.numberOfObjects ?? 0)")
        } catch {
            print("Error performing fetch: \(error)")
        }
    }

    func clearFilters() {
        fetchedResultController.fetchRequest.predicate = nil

        do {
            try fetchedResultController.performFetch()
        } catch {
            print("Error performing fetch: \(error)")
        }
    }
}
