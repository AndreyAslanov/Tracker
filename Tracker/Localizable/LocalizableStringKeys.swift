//
//  LocalizableStringKeys.swift
//  Tracker
//
//  Created by Андрей Асланов on 23.11.23.
//

import Foundation

enum LocalizableStringKeys {
    static let onboardingPageFirst = "onboardingPageFirst".localised()
    static let onboardingPageSecond = "onboardingPageSecond".localised()
    static let buttonOnboarding = "buttonOnboarding".localised()
    static let trackerViewCategory = "trackerViewCategory".localised()
    static let tabBarTrackers = "tabBarTrackers".localised()
    static let searchBar = "searchBar".localised()
    static let searchBarCancel = "searchBarCancel".localised()
    
    static let statisticTabBar = "statisticTabBar".localised()
    static let statisticText = "statisticText".localised()
    static let topLabelCreator = "topLabelCreator".localised()
    static let habitButton = "habitButton".localised()
    static let eventButton = "eventButton".localised()
    static let pictureText = "pictureText".localised()
    static let newHabitLabel = "newHabitLabel".localised()
    static let nameTextFieldTracker = "nameTextFieldTracker".localised()
    static let categoryLabel = "categoryLabel".localised()
    static let scheduleLabel = "scheduleLabel".localised()
    static let emojiLabel = "emojiLabel".localised()
    static let colorLabel = "colorLabel".localised()
    static let cancelButton = "cancelButton".localised()
    static let createButton = "createButton".localised()
    static let daysLabelEveryDay = "daysLabelEveryDay".localised()
    static let newEventLabel = "newHabitLabel".localised()
    static let editHabitLabel = "editHabitLabel".localised()
    static let editEventLabel = "editEventLabel".localised()
    
    
    static let topLabelCategory = "topLabelCategory".localised()
    static let nameTextFieldCategory = "nameTextFieldCategory".localised()
    static let doneButton = "doneButton".localised()
    static let addButton = "addButton".localised()
    static let textFieldSymbolConstraintLabel = "textFieldSymbolConstraintLabel".localised()
    
    static let allTrackers = "allTrackers".localised()
    static let trackersForToday = "trackersForToday".localised()
    static let completed = "completed".localised()
    static let unfinished = "unfinished".localised()

    static let nothingFound = "nothingFound".localised()
    static let filters = "filters".localised()
    static let pin = "pin".localised()
    static let unpin = "unpin".localised()
    static let pinned = "pinned".localised()
    static let edit = "edit".localised()
    static let delete = "delete".localised()
    static let sureToDelete = "sureToDelete".localised()
    static let cancel = "cancel".localised()
    static let trackersCompleted = "trackersCompleted".localised()
    static let bestPeriod = "bestPeriod".localised()
    static let idealDays = "idealDays".localised()
    static let averageValue = "averageValue".localised()
    
    // "Расписание"
    static let monday = "monday".localised()
    static let tuesday = "tuesday".localised()
    static let wednesday = "wednesday".localised()
    static let thursday = "thursday".localised()
    static let  friday = "friday".localised()
    static let saturday = "saturday".localised()
    static let sunday = "sunday".localised()
    
    static let mon = "mon".localised()
    static let tue = "tue".localised()
    static let wed = "wed".localised()
    static let thu = "thu".localised()
    static let fri = "fri".localised()
    static let sat = "sat".localised()
    static let sun = "sun".localised()
}

extension String {
    func localised() -> String {
        NSLocalizedString(self,
                          tableName: "Localizable",
                          value: self,
                          comment: self)
    }
}
