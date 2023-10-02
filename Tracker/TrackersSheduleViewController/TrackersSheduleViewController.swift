//
//  TrackersSheduleViewController.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import UIKit

protocol TrackerScheduleViewControllerDelegate: AnyObject {
    func selectDays(in schedule: Set<WeekDay>)
}

final class TrackersSheduleViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: TrackerScheduleViewControllerDelegate?
    var mySchedule: Set<WeekDay> = []
    
    // MARK: - UI Elemets
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Расписание"
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        tableView.rowHeight = 75
        tableView.backgroundColor = .white
        tableView.allowsSelection = false
        tableView.layer.cornerRadius = 16
        return tableView
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    init(delegate: TrackerScheduleViewControllerDelegate?, schedule: Set<WeekDay>) {
        self.delegate = delegate
        self.mySchedule = schedule
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupSheduleConstraints()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(doneButton)

        view.backgroundColor = .white
        tableView.dataSource = self
        tableView.register(TrackerScheduleTableView.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupSheduleConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 47)
        ])
    }
    
    // MARK: - Button
    @objc private func doneButtonTapped() {
        print("Кнопка 'Готово' нажата")
        delegate?.selectDays(in: mySchedule)
        dismiss(animated: true)
    }
}

// MARK: - Extensions
extension TrackersSheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TrackerScheduleTableView {
            cell.textLabel?.text = WeekDay.weekDay(for: indexPath.row)
            cell.delegate = self
            if let day = WeekDay(rawValue: indexPath.row) {
                cell.configure(at: indexPath.row, isOn: mySchedule.contains(day))
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
}
  
extension TrackersSheduleViewController: TrackersScheduleTableViewDelegate {
    func switchValueChanged(_ isOn: Bool, at row: Int) {
        if let day = WeekDay(rawValue: row) {
            if isOn {
                mySchedule.insert(day)
            } else {
                mySchedule.remove(day)
            }
            print("Updated mySchedule in TrackersSheduleViewController: \(mySchedule)")
        }
    }
}


