//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Андрей Асланов on 04.10.23.
//

import UIKit
import CoreData

// MARK: - struct
private struct TrackerCategoryStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

// MARK: - TrackerCategoryStore
class TrackerCategoryStore: NSObject {
    
    private let context: NSManagedObjectContext
    private let trackerStore = TrackerStore()
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerCategoryStoreUpdate.Move>?
    
    public static let shared = TrackerCategoryStore()
    
    private let uiColorMarshalling = UIColorMarshalling()
    private let scheduleMarshalling = ScheduleMarshalling()
    
    private lazy var fetchedResultController: NSFetchedResultsController<TrackerCategoryCoreData>! = {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        let sortDescriptor = NSSortDescriptor(keyPath: \TrackerCategoryCoreData.titleCategory, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()
    
    var categories: [TrackerCategory] {
        guard let objects = self.fetchedResultController.fetchedObjects,
              var categories = try? objects.map({ try self.makeCategories(from: $0) })
        else { return [] }
        categories.removeAll { $0.title == LocalizableStringKeys.pinned }
        return categories
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
        self.createPinCategory()
    }
    
    private func makeCategories(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryCoreData.titleCategory else {
            throw TrackerCategoryStoreError.errorTitle
        }
        
        guard let trackers = trackerCategoryCoreData.trackers else {
            throw TrackerCategoryStoreError.errorCategory
        }
        
        return TrackerCategory(title: title, trackers: trackers.compactMap { coreDataTracker -> Tracker? in
            if let coreDataTracker = coreDataTracker as? TrackerCoreData {
                return try? trackerStore.makeTrackers(from: coreDataTracker)
            }
            return nil
        })
    }
    
    func fetchedCategory(with title: String) -> TrackerCategoryCoreData? {
        let request = fetchedResultController.fetchRequest
        request.predicate = NSPredicate(format: "%K == %@", argumentArray: ["titleCategory", title])
        guard let category = try? context.fetch(request) else { return nil }
        return category.first
    }
    
    func createCategory(_ category: TrackerCategory) throws {
        guard let entity = NSEntityDescription.entity(forEntityName: "TrackerCategoryCoreData", in: context) else { return }
        let categoryEntity = TrackerCategoryCoreData(entity: entity, insertInto: context)

        categoryEntity.titleCategory = category.title
        categoryEntity.trackers = NSSet(array: [])

        try context.save()
        try fetchedResultController.performFetch()
        
        print("createCategory в TrackerCategoryStore: \(category.title)")
    }
    
    func createTrackerWithCategory(tracker: Tracker, with titleCategory: String) throws {
        if let currentCategory = fetchedCategory(with: titleCategory) {
            trackerStore.createTracker(from: tracker, category: currentCategory)
            print(#function, currentCategory)
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.titleCategory = titleCategory
            trackerStore.createTracker(from: tracker, category: newCategory)
            print(#function, newCategory)
            // newCategory.addToTrackers(trackerCoreData)
        }
        do {
            try context.save()
        } catch {
            throw TrackerCategoryStoreError.errorCategoryModel
        }
    }
    
    func createPinCategory() {
        let name = LocalizableStringKeys.pinned
        if let fetchedNewCategory = fetchedCategory(with: name) {
        print(#function, "Закрепленные is already here")
            } else {
        guard let entity = NSEntityDescription.entity(forEntityName: "TrackerCategoryCoreData", in: context) else { return }
        let categoryEntity = TrackerCategoryCoreData(entity: entity, insertInto: context)

        categoryEntity.titleCategory = name
        categoryEntity.trackers = NSSet(array: [])
        contextSave()
        print(#function, entity)
      }
    }

    func editTrackerWithCategory(tracker: Tracker, oldCategoryTitle: String?, newCategoryTitle: String?) throws {
        do {
            guard let existingTracker = try findTracker(with: tracker.id) else {
                print("Трекер не найден")
                return
            }
            print("Existing Tracker: \(existingTracker)")

            if let newCategoryTitle = newCategoryTitle {
                if let oldCategoryTitle = oldCategoryTitle, oldCategoryTitle != newCategoryTitle {
                    if let oldCategory = try fetchedCategory(with: oldCategoryTitle) {
                        oldCategory.removeFromTrackers(existingTracker)
                    }
                }

                let newCategory: TrackerCategoryCoreData
                if let fetchedNewCategory = try fetchedCategory(with: newCategoryTitle) {
                    newCategory = fetchedNewCategory
                } else {
                    newCategory = TrackerCategoryCoreData(context: context)
                    newCategory.titleCategory = newCategoryTitle
                }

                existingTracker.category = newCategory
            }

            existingTracker.name = tracker.name
            existingTracker.color = uiColorMarshalling.hexString(from: tracker.color)
            existingTracker.emoji = tracker.emoji
            existingTracker.mySchedule = scheduleMarshalling.convertSetToMyScheduleString(tracker.mySchedule)

            try context.save()
            print("Tracker updated successfully")
        } catch {
            print("Ошибка при обновлении трекера: \(error)")
            throw TrackerCategoryStoreError.errorCategoryModel
        }
    }

     func findTracker(with id: UUID) throws -> TrackerCoreData? {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.predicate = NSPredicate(format: "%K == %@", argumentArray: ["trackerID", id as CVarArg])
        return try context.fetch(request).first
    }

    private func contextSave() {
        do {
            try context.save()
        } catch {
            let error = error as NSError
            assertionFailure(error.localizedDescription)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError() }
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else { fatalError() }
            updatedIndexes?.insert(indexPath.item)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
        @unknown default: return
        }
    }
}

extension TrackerCategoryStore {
    func getCategoryTitleByTrackerID(_ trackerID: UUID) -> String? {
        guard let objects = self.fetchedResultController.fetchedObjects else {
            return nil
        }

        for object in objects {
            if let coreDataTrackerCategory = object as? TrackerCategoryCoreData,
               let trackers = coreDataTrackerCategory.trackers as? Set<TrackerCoreData>,
               let coreDataTracker = trackers.first(where: { $0.trackerID == trackerID }),
               let category = try? makeCategories(from: coreDataTrackerCategory) {

                return category.title
            }
        }
        return nil
    }
}

// MARK: - Error
extension TrackerCategoryStore {
    enum TrackerCategoryStoreError: Error {
        case errorTitle
        case errorCategory
        case errorCategoryModel
    }
}
