//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import UIKit

protocol TrackerViewControllerDelegate: AnyObject {
    func createTracker(_ tracker: Tracker?, titleCategory: String?)
}

final class TrackerViewController: UIViewController {

    // MARK: - Properties
    var currentDate: Date = Date()
    var id: UUID?
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var trackersId = Set<UUID>()
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let filterViewController = FilterViewController()
    
    private let scheduleMarshalling = ScheduleMarshalling()
    private let uiColorMarshalling = UIColorMarshalling()
    private var currentFilter: String = LocalizableStringKeys.allTrackers
    
    var trackerCategoryMap: [UUID: Int] = [:]
    
    private let colors = Colors()
    private let analiticsService = AnalyticsService()
    
    // MARK: - UI Elements
    private lazy var addTrackerButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem()
        barButtonItem.image = UIImage(systemName: "plus")
        barButtonItem.tintColor = colors.labelTextColor
        barButtonItem.action = #selector(addTrackerButtonTapped)
        barButtonItem.target = self
        return barButtonItem
    }()
    
     var createDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.subviews[0].backgroundColor = Colors.backgroundLight
        datePicker.subviews[0].layer.cornerRadius = 8
        datePicker.overrideUserInterfaceStyle = .light
        let currentLocale = Locale.current
        let calendar = Calendar(identifier: .gregorian)
        
        if currentLocale.languageCode == "ru" {
            datePicker.locale = Locale(identifier: "ru_RU")
            datePicker.calendar = calendar
            datePicker.calendar.firstWeekday = 2
        } else {
            datePicker.calendar = calendar
            datePicker.calendar.firstWeekday = 1
        }
        return datePicker
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: LocalizableStringKeys.searchBar, attributes: Colors().searchControllerTextFieldPlaceholderAttributes())
        searchController.searchBar.setValue(LocalizableStringKeys.searchBarCancel, forKey: "cancelButtonText")
        searchController.delegate = self
        return searchController
    }()
    
    let trackerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private lazy var pictureStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.isHidden = true
        return stackView
    }()
    
    private lazy var pictureImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.image = UIImage(named: "star")
        imageView.contentMode = .center
        return imageView
    }()
    
    private lazy var pictureText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = colors.labelTextColor
        label.text = LocalizableStringKeys.pictureText
        return label
    }()
    
    private lazy var pictureSearchView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.isHidden = true
        return stackView
    }()
    
    private lazy var searchPicture: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.image = UIImage(named: "nothing")
        imageView.contentMode = .center
        return imageView
    }()
    
    private lazy var searchText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = colors.labelTextColor
        label.text = LocalizableStringKeys.nothingFound
        return label
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(LocalizableStringKeys.filters, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colors.viewBackgroundColor
        
        setupUI()
        setupConstraints()

        trackerStore.delegate = self
        trackerStore.dataSource = trackerStore
        
        updateCompletedTrackers()
        if currentFilter == "Все трекеры" {
            applyFilters()
        }

        trackerCollectionView.reloadData()
        
        filterDataByDate()
        createDatePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        updateFilterButtonVisibility()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analiticsService.report(event: "open", params: ["screen": "Main"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analiticsService.report(event: "close", params: ["screen": "Main"])
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        pictureStackView.addArrangedSubview(pictureImageView)
        pictureStackView.addArrangedSubview(pictureText)
        pictureSearchView.addArrangedSubview(searchPicture)
        pictureSearchView.addArrangedSubview(searchText)
        
        view.addSubview(trackerCollectionView)
        view.addSubview(pictureStackView)
        view.addSubview(pictureSearchView)
        view.addSubview(filterButton)
        view.addSubview(createDatePicker)

        trackerCollectionView.delegate = self
        trackerCollectionView.dataSource = self
        trackerCollectionView.backgroundColor = colors.collectionViewBackgroundColor
        trackerCollectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.cellID)
        trackerCollectionView.register(TrackerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerHeader.header)
        trackerCollectionView.showsVerticalScrollIndicator = false
        trackerCollectionView.showsHorizontalScrollIndicator = false
        
        navigationController?.navigationBar.barTintColor = colors.navigationBarTintColor
        navigationItem.title = LocalizableStringKeys.tabBarTrackers
        navigationItem.searchController = searchController
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationController?.navigationBar.topItem?.leftBarButtonItem = addTrackerButton
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(customView: createDatePicker)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            pictureStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            pictureStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            pictureSearchView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            pictureSearchView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            trackerCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
        ])
        trackerCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 66, right: 0)
        trackerCollectionView.scrollIndicatorInsets = trackerCollectionView.contentInset
    }
    
    // MARK: - Data Filtering
    func filters() {
        if let filterText = searchController.searchBar.searchTextField.text?.lowercased(), filterText.count > 0 {
            trackerStore.updateNameFilter(nameFilter: filterText)
            filterButton.isHidden = true
            pictureSearchView.isHidden = trackerStore.numberOfSections() > 0 && trackerStore.numberOfRows(at: 0) > 0
            pictureStackView.isHidden = true
        } else {
            trackerStore.updateNameFilter(nameFilter: nil)
            filterButton.isHidden = false
            filterDataByDate()
            pictureSearchView.isHidden = true
        }
        trackerCollectionView.reloadData()
    }

    private func filterDataByDate() {
        let calendar = Calendar.current
        currentDate = createDatePicker.date
        trackerStore.updateDayOfWeekPredicate(for: currentDate)
        trackerStore.applyCurrentPredicates()

        if trackerStore.numberOfSections() == 0 {
            pictureStackView.isHidden = false
        } else {
            pictureStackView.isHidden = true
        }

        trackerCollectionView.reloadData()
    }
    
     func applyFilters() {
        filters()
        switch currentFilter {
        case "Все трекеры":
            placeholderForAllTrackers()
            print("все трекеры по дефолту")
            break
        case "Трекеры на сегодня":
            createDatePicker.date = Date().withoutTime() ?? Date()
            trackerStore.filterForToday()
            filterDataByDate()
            placeholderForOtherTrackers()
            FilterViewController.selectedFilterIndex = 0
            currentFilter = LocalizableStringKeys.allTrackers
        case "Завершенные":
            trackerStore.filterCompleted(for: createDatePicker.date.withoutTime() ?? Date())
            placeholderForOtherTrackers()
        case "Не завершенные":
            trackerStore.filterNotCompleted(for: createDatePicker.date.withoutTime() ?? Date())
            placeholderForOtherTrackers()
        default:
            break
        }
        trackerCollectionView.reloadData()
    }
    
    var areFiltersApplied: Bool {
        switch currentFilter {
        case "Все трекеры", "Трекеры на сегодня", "Завершенные", "Не завершенные":
            return true
        default:
            return false
        }
    }
    
    private func createCustomActions(id: UUID) -> [UIAction] {
        guard let tracker = trackerStore.getTracker(with: id) else {
            return []
        }
        let isPinned = isTrackerPinned(tracker)

        let pinActionTitle = isPinned ? LocalizableStringKeys.unpin : LocalizableStringKeys.pin          
        let pinAction = UIAction(
            title: pinActionTitle,
            image: nil,
            identifier: nil,
            discoverabilityTitle: nil,
            state: .off) { [weak self] action in
                guard let self else { return }

                self.trackerStore.setIsPinned(for: tracker)
                self.trackerCollectionView.reloadData()
            }

        let editAction = UIAction(title: LocalizableStringKeys.edit) { [weak self] _ in
            if tracker.isPinned {
                // Если трекер закреплен, используем trackerCategory
                if let trackerCategory = self?.trackerCategoryStore.getCategoryTitleByTrackerID(id) {
                    print("trackerCategory: \(trackerCategory)")
                    self?.editTracker(id, category: trackerCategory)
                }
            } else {
                // Если трекер не закреплен, используем mainCategory
                if let mainCategory = self?.trackerStore.getMainCategoryByTrackerID(id) {
                    print("mainCategory: \(mainCategory)")
                    self?.editTracker(id, category: mainCategory)
                }
            }

            self?.analiticsService.report(event: "click", params: ["screen": "Main", "item": "edit"])
        }

        let deleteAction = UIAction(title: LocalizableStringKeys.delete, image: nil, attributes: .destructive) { [ weak self ] _ in
            print("айди трекера при удалении: \(id)")
            self?.showDeleteConfirmation(id: id)
            self?.analiticsService.report(event: "click", params: ["screen": "Main", "item": "delete"])
        }

        return [pinAction, editAction, deleteAction]
    }
    
    private func showDeleteConfirmation(id: UUID) {
        let alertController = UIAlertController(
            title: LocalizableStringKeys.sureToDelete,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: LocalizableStringKeys.delete, style: .destructive) { [weak self] _ in
            self?.deleteTracker(id)
        }
        
        let cancelAction = UIAlertAction(title: LocalizableStringKeys.cancel, style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    private func deleteTracker(_ id: UUID) {
        trackerStore.deleteTracker(with: id)
        didUpdate()
        updateFilterButtonVisibility()
        trackerCollectionView.reloadData()
    }
    
    private func editTracker(_ id: UUID, category: String?) {
        if let tracker = trackerStore.getTracker(with: id) {
            var recordsString = ""

            if let trackerRecords = trackerRecordStore.trackerRecords {
                let numberOfDays = trackerRecords
                    .filter { $0.id == id }
                    .count

                recordsString = String.localizedStringWithFormat(
                    NSLocalizedString("numberOfTasks", comment: ""),
                    numberOfDays
                )
            }

            let viewController: UIViewController
            if Set(WeekDay.allCases).isSubset(of: tracker.mySchedule) {
                let newEventVC = NewEventViewController(tracker: tracker, category: category)
                newEventVC.recordsLabel.text = recordsString
                newEventVC.updateUIForCurrentMode()
                viewController = newEventVC
            } else {
                let newHabitVC = NewHabitViewController(tracker: tracker, category: category)
                newHabitVC.recordsLabel.text = recordsString
                newHabitVC.updateUIForCurrentMode()
                viewController = newHabitVC
            }

            present(viewController, animated: true, completion: nil)
        }
    }
    
    private func updateCompletedTrackers() {
        if let completedTrackers = trackerRecordStore.trackerRecords {
            self.completedTrackers = completedTrackers
            print("Loaded \(completedTrackers.count) completed trackers from Core Data.")
        } else {
            self.completedTrackers = []
            print("No completed trackers loaded from Core Data.")
        }
    }
    
    private func placeholderForAllTrackers() {
        let isHidden = trackerStore.numberOfSections() == 0 && searchController.searchBar.searchTextField.text != ""
        pictureSearchView.isHidden = !isHidden
        if pictureStackView.isHidden == false {
            pictureSearchView.isHidden = true
        }
        updateFilterButtonVisibility()
        trackerCollectionView.reloadData()
    }
    
    private func placeholderForOtherTrackers() {
        if trackerStore.numberOfSections() > 0 && trackerStore.numberOfRows(at: 0) > 0 {
            pictureSearchView.isHidden = true
            pictureStackView.isHidden = true
        } else {
            pictureSearchView.isHidden = false
            pictureStackView.isHidden = true
        }
        filterButton.isHidden = !areFiltersApplied
        
        trackerCollectionView.reloadData()
    }
    
    private func updateFilterButtonVisibility() {
        let shouldShowFilterButton = trackerStore.numberOfSections() > 0
        filterButton.isHidden = !shouldShowFilterButton
        trackerCollectionView.reloadData()
    }
    
    // MARK: - User Actions
    @objc private func datePickerChanged(sender: UIDatePicker) {
        if let currentDate = createDatePicker.date.withoutTime() {
            self.currentDate = currentDate
            trackerStore.updateDayOfWeekPredicate(for: currentDate)
            filters()
            applyFilters()
            trackerCollectionView.reloadData()
        }
    }
    
    @objc private func addTrackerButtonTapped() {
        trackerCollectionView.reloadData()
        let trackerCreator = TrackerCreatorViewController(delegate: self)
        trackerCreator.delegate = self
        trackerCreator.categories = categories
        trackerCreator.trackerStore = trackerStore
        let navigationController = UINavigationController(rootViewController: trackerCreator)
        present(navigationController, animated: true)
        analiticsService.report(event: "click", params: ["screen": "Main", "item": "add_track"])
    }
    
    @objc private func filterButtonTapped() {
        let filterViewController = FilterViewController()
        filterViewController.delegate = self
        filterViewController.filters = ["Все трекеры", "Трекеры на сегодня", "Завершенные", "Не завершенные"]

        let navigationController = UINavigationController(rootViewController: filterViewController)
        present(navigationController, animated: true, completion: nil)
        analiticsService.report(event: "click", params: ["screen": "Main", "item": "filter"])
    }
    
    @objc func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            if let blurEffectView = sender.view?.subviews.compactMap({ $0 as? UIVisualEffectView }).first {
                UIView.animate(withDuration: 0.3) {
                    blurEffectView.isHidden = false
                }
            }
        } else if sender.state == .ended || sender.state == .cancelled {
            if let blurEffectView = sender.view?.subviews.compactMap({ $0 as? UIVisualEffectView }).first {
                UIView.animate(withDuration: 0.3) {
                    blurEffectView.isHidden = true
                }
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Extensions
extension TrackerViewController: TrackerCreatorDelegate {
    func newTrackerCreated(_ tracker: Tracker, category: String?) {
        trackerCollectionView.reloadData()
        let newCategory = TrackerCategory(title: category ?? "Категория1", trackers: [tracker])
        categories.append(newCategory)
        filters()
        trackerCollectionView.reloadData()
        dismiss(animated: true, completion: nil)
        updateFilterButtonVisibility()
        filterDataByDate()
        applyFilters()
        print("category: \(category ?? "Категория1")")
    }
}
// MARK: - Collection
extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerStore.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackerStore.numberOfRows(at: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.cellID, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }

        if let tracker = trackerStore.dataForCell(at: indexPath) {
            let resCompare = Calendar.current.compare(Date().withoutTime()!, to: currentDate, toGranularity: .day)
            let trackerRecordForDate = completedTrackers.first { $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
            let isTrackerDone = trackerRecordForDate != nil
            
            let model = TrackerCellViewModel(
                name: tracker.name,
                emoji: tracker.emoji,
                color: tracker.color,
                trackerIsDone: isTrackerDone,
                doneButtonIsEnabled: resCompare == .orderedSame || resCompare == .orderedDescending,
                counter: UInt(completedTrackers.filter { $0.id == tracker.id }.count),
                id: tracker.id
            )
            
            cell.configure(model: model)
            cell.isPinned = isTrackerPinned(tracker)
            cell.cellTapAction = { [weak self] in
                self?.trackerCellDelegate(id: tracker.id)
            }
            
            let trackerViewInteraction = UIContextMenuInteraction(delegate: self)
            cell.trackerView.addInteraction(trackerViewInteraction)
            
            // Добавим анимацию размытия
            let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
            blurEffectView.frame = cell.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.isHidden = true
            blurEffectView.isUserInteractionEnabled = false
            cell.trackerView.addSubview(blurEffectView)

            // Запускаем анимацию размытия при долгом нажатии
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
            longPressGestureRecognizer.minimumPressDuration = 0.5 // Длительность
            cell.trackerView.addGestureRecognizer(longPressGestureRecognizer)
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerHeader.header, for: indexPath) as? TrackerHeader
        else {
            return UICollectionReusableView()
        }
        
        let sectionTitle = trackerStore.titleForSection(section: indexPath.section)
        view.configure(headerText: sectionTitle)
        
        return view
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 9) / 2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
}

// MARK: - TrackerCellDelegate
extension TrackerViewController: TrackerCellDelegate {
    func trackerCellDelegate(id: UUID) {
        if let date = createDatePicker.date.withoutTime() {
            let record = TrackerRecord(id: id, date: date)
            if completedTrackers.contains(record) {
                trackerRecordStore.deleteTrackerRecord(record)
            } else {
                trackerStore.updateTracker(value: record)
            }
            applyFilters()
        } else {
            return
        }
    }
}

extension TrackerViewController {
    func executionСontrol(id: UUID) { // кажется id не нужен, проверить!
        let rec = TrackerRecord(
            id: id,
            date: createDatePicker.date.withoutTime()!
        )
        if completedTrackers.contains(rec) {
            trackerRecordStore.deleteTrackerRecord(rec)
        } else {
            trackerStore.updateTracker(value: rec)
        }
    }

}

extension TrackerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filters()
    }
}

extension TrackerViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        filterDataByDate()
    }
}

extension TrackerViewController: TrackerStoreDelegate {
    func didUpdate() {
        updateCompletedTrackers()
        filterDataByDate()
        trackerCollectionView.reloadData()
        pictureStackView.isHidden = trackerStore.numberOfSections() > 0
    }
}

extension Date {
    func withoutTime() -> Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components)
    }
}

extension TrackerViewController: TrackerViewControllerDataSource {
    func numberOfSections() -> Int {
        return trackerStore.numberOfSections()
    }
    
    func dataForCell(at indexPath: IndexPath) -> Tracker? {
        return trackerStore.dataForCell(at: indexPath)
    }

    func numberOfRows(at section: Int) -> Int {
        return trackerStore.numberOfRows(at: section)
    }

    func titleForSection(section: Int) -> String {
        return trackerStore.titleForSection(section: section)
    }
    
    func trackerStoreDidUpdate(_ trackerStore: TrackerStore) {
        trackerCollectionView.reloadData()
    }
}

extension TrackerViewController: UICollectionViewDelegate, UIContextMenuInteractionDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell,
              let tracker = trackerStore.dataForCell(at: indexPath) else {
            return nil
        }
        
        cell.trackerView.tag = indexPath.row
        
        let trackerViewInteraction = UIContextMenuInteraction(delegate: self)
        cell.trackerView.addInteraction(trackerViewInteraction)
        
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            let customActions = self.createCustomActions(id: tracker.id)
            
            return UIMenu(title: "", children: customActions)
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let locationInCollectionView = interaction.location(in: trackerCollectionView)
        guard
            let indexPath = trackerCollectionView.indexPathForItem(at: locationInCollectionView),
            let tracker = trackerStore.dataForCell(at: indexPath)
        else {
            return nil
        }
        
        return UIContextMenuConfiguration (identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            let customActions = self.createCustomActions(id: tracker.id)
            return UIMenu(title: "", children: customActions)
        }
    }
}

extension TrackerViewController: FilterViewControllerDelegate {
    func didSelectFilter(_ filters: String) {
        self.currentFilter = filters
        applyFilters()
        trackerCollectionView.reloadData()
    }
}

extension TrackerViewController {
    func isTrackerPinned(_ tracker: Tracker) -> Bool {
        return trackerStore.pinnedTrackers.contains(where:  { $0.id == tracker.id })
    }
}
