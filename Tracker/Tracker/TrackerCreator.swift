//
//  TrackerCreator.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import UIKit

protocol TrackerCreatorDelegate: AnyObject {
//    func didSelectTrackerType(_ type: String)
    func newTrackerCreated(_ tracker: Tracker, category: String?)
}

final class TrackerCreatorViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: TrackerCreatorDelegate?
    var categories: [TrackerCategory] = []
    var trackerStore: TrackerStore?
    var editingTrackerId: UUID?
    
    // MARK: - UI Elements
    private let topLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizableStringKeys.topLabelCreator
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(LocalizableStringKeys.habitButton, for: .normal)
        button.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let eventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(LocalizableStringKeys.eventButton, for: .normal)
        button.addTarget(self, action: #selector(eventButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    // MARK: - Initialization
    init(delegate: TrackerCreatorDelegate?) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupCreatorUI()
        setupConstraints()
    }
    
    // MARK: - UI Setup
    private func setupCreatorUI() {
        view.addSubview(habitButton)
        view.addSubview(eventButton)
        view.addSubview(topLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            topLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            habitButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            
            eventButton.leadingAnchor.constraint(equalTo: habitButton.leadingAnchor),
            eventButton.trailingAnchor.constraint(equalTo: habitButton.trailingAnchor),
            eventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            eventButton.heightAnchor.constraint(equalTo: habitButton.heightAnchor),
            
        ])
    }
    
// MARK: - Buttons
    @objc private func habitButtonTapped() {
//        delegate?.didSelectTrackerType("Привычка")
        let newHabitViewController = NewHabitViewController()
        newHabitViewController.delegate = self
        newHabitViewController.categories = categories
        addChild(newHabitViewController)
        view.addSubview(newHabitViewController.view)
        newHabitViewController.didMove(toParent: self)
    }
    
    @objc private func eventButtonTapped() {
//        delegate?.didSelectTrackerType("Нерегулярное событие")
        
        let newEventViewController = NewEventViewController()
        newEventViewController.delegate = self
        newEventViewController.categories = categories
        addChild(newEventViewController)
        view.addSubview(newEventViewController.view)
        newEventViewController.didMove(toParent: self)
    }
}

// MARK: - Extensions
extension TrackerCreatorViewController: NewHabitViewControllerDelegate {
    func newTrackerCreated(_ tracker: Tracker, category: String?) {
        delegate?.newTrackerCreated(tracker, category: category)
    }
}

extension TrackerCreatorViewController: NewEventViewControllerDelegate {
    func newEventTrackerCreated(_ tracker: Tracker, category: String?) {
        delegate?.newTrackerCreated(tracker, category: category)
    }
}
