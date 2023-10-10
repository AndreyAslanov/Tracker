//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import UIKit

final class TrackerViewController: UIViewController {

    // MARK: - Properties
    var currentDate: Date = Date()
    
    private var visibleCategories: [TrackerCategory] = []
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var trackersId = Set<UUID>()
    private let trackerStore = TrackerStore()
    
    // MARK: - UI Elements
    private lazy var addTrackerButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem()
        barButtonItem.image = UIImage(systemName: "plus")
        barButtonItem.action = #selector(addTrackerButtonTapped)
        barButtonItem.tintColor = .black
        barButtonItem.target = self
        return barButtonItem
    }()
    
    private var createDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar = Calendar(identifier: .gregorian)
        datePicker.calendar.firstWeekday = 2
        return datePicker
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.setValue("Отменить", forKey: "cancelButtonText")
        searchController.delegate = self
        return searchController
    }()
    
    private let trackerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
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
        label.textColor = .black
        label.text = "Что будем отслеживать?"
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        setupUI()
        setupConstraints()
        
        let trackerStore = TrackerStore()
        categories = trackerStore.trackers.map { TrackerCategory(title: "Категория", trackers: [$0])}
        
        visibleCategories = categories
        
        let trackerRecordStore = TrackerRecordStore.shared
        completedTrackers = trackerRecordStore.trackerRecords
//        trackerCollectionView.reloadData()
        print("Loaded \(completedTrackers.count) completed trackers from Core Data.")
//        updateVisibleCategories()
        trackerCollectionView.reloadData()
        
        pictureStackView.isHidden = !visibleCategories.isEmpty
        trackerCollectionView.reloadData()
        
        TrackerManager.shared.clearCompletedTrackers()
        filterDataByDate()
        createDatePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        pictureStackView.addArrangedSubview(pictureImageView)
        pictureStackView.addArrangedSubview(pictureText)
        
        view.addSubview(pictureStackView)
        view.addSubview(trackerCollectionView)
        view.bringSubviewToFront(pictureStackView)
        
        trackerCollectionView.delegate = self
        trackerCollectionView.dataSource = self
        trackerCollectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.cellID)
        trackerCollectionView.register(TrackerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerHeader.header)
        trackerCollectionView.showsVerticalScrollIndicator = false
        trackerCollectionView.showsHorizontalScrollIndicator = false
        
        navigationItem.title = "Трекеры"
        navigationItem.searchController = searchController
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationController?.navigationBar.topItem?.leftBarButtonItem = addTrackerButton
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(customView: createDatePicker)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            pictureStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            pictureStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            trackerCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    // MARK: - Data Filtering
    private func filterDataByDate() {
        let calendar = Calendar.current
        let filterWeekDay = (calendar.component(.weekday, from: currentDate) + 5) % 7
        filterData { tracker in
            tracker.mySchedule.isEmpty || tracker.mySchedule.contains { weekDay in
                return weekDay.rawValue == filterWeekDay
            }
        }
    }
    
    private func filterData(filteringСondition:(Tracker)->(Bool)) {
        visibleCategories = categories.map { trackerCategory in
            TrackerCategory(title: trackerCategory.title,
                            trackers: trackerCategory.trackers.filter { filteringСondition($0) })
        }.filter { $0.trackers.count > 0 }
        pictureStackView.isHidden = !visibleCategories.isEmpty
    }
    
    private func filters() {
        if let filterText = searchController.searchBar.searchTextField.text?.lowercased(), filterText.count > 0 {
            filterData { tracker in
                tracker.name.lowercased().hasPrefix(filterText)
            }
        } else {
            filterDataByDate()
        }
        trackerCollectionView.reloadData()
    }
    
    // MARK: - User Actions
    @objc private func datePickerChanged(sender: UIDatePicker) {
        currentDate = createDatePicker.date
        filters()
    }
    
    @objc private func addTrackerButtonTapped() {
        trackerCollectionView.reloadData()
        let trackerCreator = TrackerCreatorViewController(delegate: self)
        trackerCreator.delegate = self
        trackerCreator.categories = categories
        trackerCreator.trackerStore = trackerStore
        let navigationController = UINavigationController(rootViewController: trackerCreator)
        present(navigationController, animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Extensions

extension TrackerViewController: TrackerCreatorDelegate {
    
    func didSelectTrackerType(_ type: String) {
        print("Selected tracker type: \(type)")
    }
    
    func newTrackerCreated(_ tracker: Tracker) {
        let newCategory = TrackerCategory(
            title: "Новая категория",
            trackers: [tracker]
        )
        
        categories.append(newCategory)
        filters()
        trackerCollectionView.reloadData()
        dismiss(animated: true, completion: nil)
    }
}

extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.cellID, for: indexPath) as? TrackerCell
        else {
            return UICollectionViewCell()
        }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let resCompare = Calendar.current.compare(Date(), to: currentDate, toGranularity: .day)
        let completionCount = TrackerManager.shared.getCompletionCount(for: tracker.id)
        let isTrackerDone = TrackerManager.shared.isTrackerCompleted(trackerId: tracker.id, date: currentDate)

        let model = TrackerCellViewModel(name: tracker.name,
                                         emoji: tracker.emoji,
                                         color: tracker.color,
                                         trackerIsDone: isTrackerDone,
                                         doneButtonIsEnabled: resCompare == .orderedSame || resCompare == .orderedDescending,
                                         counter: UInt(completionCount),
                                         id: tracker.id)
        cell.configure(model: model)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerHeader.header, for: indexPath) as? TrackerHeader
        else {
            return UICollectionReusableView()
        }
        view.configure(headerText: visibleCategories[indexPath.section].title)
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

extension TrackerViewController: TrackerCellDelegate {
    
    func executionСontrol(id: UUID) {
        let currentDate = createDatePicker.date
        let trackerIsDone = TrackerManager.shared.isTrackerCompleted(trackerId: id, date: currentDate)
        
        if trackerIsDone {
            TrackerManager.shared.decreaseCompletionCount(trackerId: id, date: currentDate)
        } else {
            TrackerManager.shared.markTrackerAsCompleted(trackerId: id, date: currentDate)
        }
        
        trackerCollectionView.reloadData()
    }
    
    private func addExecutionTracker(id: UUID) {
        let recordTracker = TrackerRecord(id: id, date: currentDate)
        completedTrackers.append(recordTracker)
        trackersId.insert(id)
        trackerCollectionView.reloadData()
    }
    
    private func removeExecutionTracker(id: UUID) {
        completedTrackers.removeAll { $0.id == id && $0.date == currentDate}
        trackersId.remove(id)
        trackerCollectionView.reloadData()
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

