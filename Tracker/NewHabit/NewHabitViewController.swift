//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import UIKit

protocol NewHabitViewControllerDelegate: AnyObject {
    func newTrackerCreated(_ tracker: Tracker)
}

final class NewHabitViewController: UIViewController, UITableViewDelegate {
    
    // MARK: - Properties
    private let tracker = false
    private var mySchedule: Set<WeekDay> = []
    private var trackersScheduleViewController: TrackersSheduleViewController?
    weak var delegate: NewHabitViewControllerDelegate?
    var categories: [TrackerCategory] = []
    
    private let emoji = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇" , "🎸", "🏝", "😪"]
    private let colors = ["1", "2", "3", "4", "5", "6","7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18"]
    
    // MARK: - UI Elements
    private let newHabitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Новая привычка"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Введите название трекера"
        textField.clearButtonMode = .always
        textField.backgroundColor = UIColor(named: "Background [day]")
        textField.layer.cornerRadius = 16
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        textField.returnKeyType = .done
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return textField
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        tableView.rowHeight = 75
        tableView.backgroundColor = .white
        tableView.layer.cornerRadius = 16
        return tableView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(named: "Red"), for: .normal)
        button.backgroundColor = .clear
        button.layer.borderColor = UIColor(named: "Red")?.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "Gray")
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.isEnabled = true
        return button
    }()
    
    private let textFieldSymbolConstraintLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scheduleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()

    var colorsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let colorsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return colorsCollectionView
    }()
    
    let emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
   private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.backgroundColor = .white
       
        return scrollView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupHabitUI()
        setupHabitConstraints()
        
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textFieldSymbolConstraintLabel.isHidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        collectionView.allowsMultipleSelection = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        colorsCollectionView.dataSource = self
        colorsCollectionView.register(ColorsCollectionViewCell.self, forCellWithReuseIdentifier: "colorCell")
        colorsCollectionView.allowsMultipleSelection = false
        colorsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGuesture = UITapGestureRecognizer(target: self, action: #selector (dismissKeyboard))
        tapGuesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGuesture)
    }
    
    // MARK: - UI Setup
    private func setupHabitUI() {
        scrollView.addSubview(nameTextField)
        scrollView.addSubview(tableView)
        scrollView.addSubview(cancelButton)
        scrollView.addSubview(createButton)
        scrollView.addSubview(textFieldSymbolConstraintLabel)
        scrollView.addSubview(collectionView)
        scrollView.addSubview(colorsCollectionView)
        scrollView.addSubview(emojiLabel)
        scrollView.addSubview(colorLabel)
        view.addSubview(scrollView)
        view.addSubview(newHabitLabel)
    }
    
    private func setupHabitConstraints() {
        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: newHabitLabel.bottomAnchor, constant: 14),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            nameTextField.leadingAnchor.constraint(equalTo:  view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo:  view.trailingAnchor, constant: -16),
            nameTextField.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            newHabitLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            newHabitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            tableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.widthAnchor.constraint(equalToConstant: 343),
            
            cancelButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -100),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),

            createButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 16),
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            createButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            textFieldSymbolConstraintLabel.centerXAnchor.constraint(equalTo: nameTextField.centerXAnchor),
            textFieldSymbolConstraintLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            
            collectionView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 224),
            collectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 18),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -19),
            collectionView.widthAnchor.constraint(equalToConstant: 374),
            collectionView.heightAnchor.constraint(equalToConstant: 204),
        
            emojiLabel.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: -24),
            emojiLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            emojiLabel.widthAnchor.constraint(equalToConstant: 52), // Ширина 52
            emojiLabel.heightAnchor.constraint(equalToConstant: 18),
            
            colorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            colorLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            
            colorsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:19),
            colorsCollectionView.widthAnchor.constraint(equalToConstant: 374),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: 204),
            colorsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -19),
            colorsCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 16),
        ])
    }
    
    // MARK: - Days Selected
    private func updateScheduleCellSubtitle() {
        if mySchedule.isEmpty {
            daysLabel.isHidden = true
            daysLabel.text = nil
        } else {
            let allDaysSelected = mySchedule.count == WeekDay.allCases.count
            if allDaysSelected {
                daysLabel.isHidden = false
                daysLabel.text = "Каждый день"
            } else {
                let selectedDays = mySchedule
                    .sorted(by: { $0.rawValue < $1.rawValue })
                    .map { WeekDay.shortName(for: $0.rawValue) }
                daysLabel.isHidden = false
                daysLabel.text = selectedDays.joined(separator: ", ")
            }
        }
    }
    
    // MARK: - Buttons and TextField
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func createButtonTapped() {
        print("createButtonTapped() вызван")
        
        guard let name = nameTextField.text, !name.isEmpty else {
            return
        }
        guard !mySchedule.isEmpty else {
            return
        }
        let newTracker = Tracker(id: UUID(),
                                 name: name,
                                 color: .red,
                                 emoji: "🍔",
                                 mySchedule: mySchedule)
       
        delegate?.newTrackerCreated(newTracker)
    }
    
    @objc private func textFieldDidChange() {
        if let text = nameTextField.text, text.count >= 38 {
            textFieldSymbolConstraintLabel.isHidden = false
        } else {
            textFieldSymbolConstraintLabel.isHidden = true
        }
    }
}

// MARK: - Extensions
extension NewHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell.layer.masksToBounds = true
            
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Категория"
                cell.backgroundColor = UIColor(named: "Background [day]")
                cell.layer.cornerRadius = 16
                cell.layer.maskedCorners = tracker ?
                [.layerMinXMinYCorner, .layerMaxXMinYCorner] :
                [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                
                if !tracker {
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                }
                cell.accessoryType = .disclosureIndicator
                
            case 1:
                cell.backgroundColor = UIColor(named: "Background [day]")
                cell.layer.cornerRadius = 16
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 400)
                cell.accessoryType = .disclosureIndicator
                
                cell.contentView.addSubview(scheduleLabel)
                
                let calendar = Calendar.current
                let currentDay = calendar.component(.weekday, from: Date())
                cell.contentView.addSubview(daysLabel)
                
                let scheduleLabelTopConstraint = scheduleLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10)
                let scheduleLabelLeadingConstraint = scheduleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20)
                let daysLabelTopConstraint = daysLabel.topAnchor.constraint(equalTo: scheduleLabel.bottomAnchor, constant: 10)
                let daysLabelLeadingConstraint = daysLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20)
                let daysLabelBottomConstraint = daysLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10)
                
                if mySchedule.isEmpty {
                    daysLabel.isHidden = true
                    scheduleLabelTopConstraint.constant = 10
                    scheduleLabelLeadingConstraint.isActive = true
                    scheduleLabel.textAlignment = .left
                } else {
                    daysLabel.isHidden = false
                    scheduleLabelTopConstraint.constant = 0
                    scheduleLabelLeadingConstraint.isActive = false
                    scheduleLabel.textAlignment = .left
                }
                
                NSLayoutConstraint.activate([scheduleLabelTopConstraint, scheduleLabelLeadingConstraint, daysLabelTopConstraint, daysLabelLeadingConstraint, daysLabelBottomConstraint])
                
            default:
                break
            }
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.contentView.backgroundColor = .clear
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
        }
        
        switch indexPath.row {
        case 0:
            let categoryVC = CategoryViewController()
            let navController = UINavigationController(rootViewController: categoryVC)
            present(navController, animated: true, completion: nil)
            
        case 1:
            createButton.isEnabled = true
            if let exitingScheduleVC = trackersScheduleViewController {
                exitingScheduleVC.mySchedule = mySchedule
                exitingScheduleVC.delegate = self
                present(exitingScheduleVC, animated: true, completion: nil)
            } else {
                let scheduleVC = TrackersSheduleViewController(delegate: self, schedule: mySchedule)
                trackersScheduleViewController = scheduleVC
                present(scheduleVC, animated: true, completion: nil)
            }
        default:
            break
        }
    }
}

extension NewHabitViewController: TrackerScheduleViewControllerDelegate {
    func selectDays(in schedule: Set<WeekDay>) {
        self.mySchedule = schedule
        updateScheduleCellSubtitle()
        dismiss(animated: true)
    }
}

extension NewHabitViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let range = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        
        if updatedText.count <= 38 {
            textFieldSymbolConstraintLabel.isHidden = true
            return true
        } else {
            textFieldSymbolConstraintLabel.isHidden = false
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textFieldSymbolConstraintLabel.isHidden = true
        return true
    }
}

extension NewHabitViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == colorsCollectionView {
            return colors.count
        } else {
            return emoji.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == colorsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as? ColorsCollectionViewCell
            cell?.colorImageView.image = UIImage(named: colors[indexPath.row])
            return cell!
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as? EmojiCollectionViewCell

            let emojiString = emoji[indexPath.row]
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 32, weight: .bold)
            ]
            let attributedEmoji = NSAttributedString(string: emojiString, attributes: attributes)
            cell?.emojiLabel.attributedText = attributedEmoji
            return cell!
        }
    }

}

extension NewHabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = 6
        let numberOfItemsPerColumn: CGFloat = 3
        let spacingBetweenCells: CGFloat = 5
        
        if collectionView == colorsCollectionView {
            let totalHorizontalSpacing = (numberOfItemsPerRow - 1) * spacingBetweenCells
            let totalVerticalSpacing = (numberOfItemsPerColumn - 1) * spacingBetweenCells
            let width = (collectionView.bounds.width - totalHorizontalSpacing) / numberOfItemsPerRow
            let height = (collectionView.bounds.height - totalVerticalSpacing) / numberOfItemsPerColumn
            return CGSize(width: width, height: height)
        } else {
            let totalSpacing = (numberOfItemsPerRow - 1) * spacingBetweenCells
            let width = (collectionView.bounds.width - totalSpacing) / numberOfItemsPerRow
            let height = width
            return CGSize(width: 52, height: 52)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == colorsCollectionView {
            return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        } else {
            return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == colorsCollectionView {
            return 5
        } else {
            return 5
        }
    }
}



