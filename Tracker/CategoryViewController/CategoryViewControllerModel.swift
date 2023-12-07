//
//  CategoryViewControllerModel.swift
//  Tracker
//
//  Created by Андрей Асланов on 26.10.23.
//

import Foundation

struct Category {
    let id: UUID
    let name: String
}

final class CategoryViewControllerModel {
    // MARK: - Private Properties
    var trackerCategoryStore: TrackerCategoryStore
    var selectedCategoryIndex: Int?
    var updateView: (() -> Void)?
    var categories: [TrackerCategory] = [] {
        didSet {
            updateView?()
        }
    }
    
    // MARK: - Initializers
    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
    }
    
    // MARK: - Public Methods
    func loadCategoriesFromCoreData() {
        categories = trackerCategoryStore.categories
    }
    
    func addCategory(_ category: TrackerCategory) {
        categories.append(category)
        updateView?()
    }
}
