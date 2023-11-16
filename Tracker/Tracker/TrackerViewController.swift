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
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var trackersId = Set<UUID>()
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    
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

        trackerStore.delegate = self
        trackerStore.dataSource = trackerStore
        
        updateCompletedTrackers()
        pictureStackView.isHidden = trackerStore.numberOfSections() > 0
        trackerCollectionView.reloadData()
        
        filterDataByDate()
        createDatePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
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
    private func filters() {
        if let filterText = searchController.searchBar.searchTextField.text?.lowercased(), filterText.count > 0 {
            trackerStore.updateNameFilter(nameFilter: filterText)
        } else {
            trackerStore.updateNameFilter(nameFilter: nil)
            filterDataByDate()
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

    func didSelectCategory(_ category: String) {
        trackerStore.updateCategoryPredicate(category: category)
        trackerStore.applyCurrentPredicates()
        trackerCollectionView.reloadData()
    }
    
    // MARK: - User Actions
    @objc private func datePickerChanged(sender: UIDatePicker) {
        if let currentDate = createDatePicker.date.withoutTime() {
            self.currentDate = currentDate
            trackerStore.updateDayOfWeekPredicate(for: currentDate)
            filters()
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

    func newTrackerCreated(_ tracker: Tracker, category: String?) {
        trackerCollectionView.reloadData()
        let newCategory = TrackerCategory(title: category ?? "Категория1", trackers: [tracker])
        categories.append(newCategory)
        filters()
        trackerCollectionView.reloadData()
        dismiss(animated: true, completion: nil)
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
            cell.doneCompletion = { [weak self] in
                self?.executionСontrol(id: tracker.id)
            }
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
