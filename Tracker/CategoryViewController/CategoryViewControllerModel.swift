//
//  CategoryViewControllerModel.swift
//  Tracker
//
//  Created by Андрей Асланов on 26.10.23.
//

import UIKit

struct Category {
    let id: UUID
    let name: String
}

final class CategoryViewControllerModel {

    var trackerCategoryStore: TrackerCategoryStore

       // Инициализация с передачей экземпляра TrackerCategoryStore
       init(trackerCategoryStore: TrackerCategoryStore) {
           self.trackerCategoryStore = trackerCategoryStore
       }

       // Метод для загрузки категорий из Core Data
       func loadCategoriesFromCoreData() {
           categories = trackerCategoryStore.categories
       }


    var categories: [TrackerCategory] = [] {
        didSet {
            updateView?()
            print ("categories \(categories)")
        }
    }

    var updateView: (() -> Void)? {
        didSet {
            print("updateView установлен")
        }
    }

    func addCategory(_ category: TrackerCategory) {
        categories.append(category)
        print("Категория добавлена: \(category)")
        print("Количество категорий в массиве: \(categories.count)")
        updateView?()
    }

    var selectedCategoryIndex: Int?
}
