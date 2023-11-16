//
//  NewEventViewController.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import UIKit

protocol NewEventViewControllerDelegate: AnyObject {
    func newEventTrackerCreated(_ tracker: Tracker, category: String?)
}

class NewEventViewController: UIViewController, UITableViewDelegate  {
    // MARK: - Public Properties
    var categories: [TrackerCategory] = []
    weak var delegate: NewEventViewControllerDelegate?
    
    // MARK: - Private Properties
    private var mySchedule: Set<WeekDay> = []
    private var trackersScheduleViewController: TrackersSheduleViewController?
    private let trackerCategoryStore = TrackerCategoryStore()
    private let tracker = false
    private var selectedEmoji: Int?
    private var selectedColor: Int?
    var categoriesViewModel: CategoryViewControllerModel!
    var selectedCategory: String?
    
    private let emoji = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇" , "🎸", "🏝", "😪"]
    private let colors: [UIColor] = [
        UIColor(named: "1") ?? #colorLiteral(red: 1, green: 0.3956416845, blue: 0.3553284407, alpha: 1),
        UIColor(named: "2") ?? #colorLiteral(red: 1, green: 0.606235683, blue: 0.1476774216, alpha: 1),
        UIColor(named: "3") ?? #colorLiteral(red: 0, green: 0.5718221664, blue: 0.9856571555, alpha: 1),
        UIColor(named: "4") ?? #colorLiteral(red: 0.5111960173, green: 0.3877502382, blue: 0.9980657697, alpha: 1),
        UIColor(named: "5") ?? #colorLiteral(red: 0.216876775, green: 0.8317107558, blue: 0.4868133068, alpha: 1),
        UIColor(named: "6") ?? #colorLiteral(red: 0.9293015599, green: 0.5319302678, blue: 0.8638190627, alpha: 1),
        UIColor(named: "7") ?? #colorLiteral(red: 0.9840622544, green: 0.8660314083, blue: 0.8633159399, alpha: 1),
        UIColor(named: "8") ?? #colorLiteral(red: 0.2413934469, green: 0.7193134427, blue: 0.9979558587, alpha: 1),
        UIColor(named: "9") ?? #colorLiteral(red: 0.3105114102, green: 0.9077441692, blue: 0.678263247, alpha: 1),
        UIColor(named: "10") ?? #colorLiteral(red: 0.270511806, green: 0.2811065316, blue: 0.559990108, alpha: 1),
        UIColor(named: "11") ?? #colorLiteral(red: 1, green: 0.4940689206, blue: 0.372153759, alpha: 1),
        UIColor(named: "12") ?? #colorLiteral(red: 1, green: 0.679395318, blue: 0.8373131156, alpha: 1),
        UIColor(named: "13") ?? #colorLiteral(red: 0.975395143, green: 0.8091526628, blue: 0.6130551696, alpha: 1),
        UIColor(named: "14") ?? #colorLiteral(red: 0.5460836887, green: 0.6587280631, blue: 0.9697209001, alpha: 1),
        UIColor(named: "15") ?? #colorLiteral(red: 0.5919097066, green: 0.3043287396, blue: 0.9573236108, alpha: 1),
        UIColor(named: "16") ?? #colorLiteral(red: 0.7400739789, green: 0.4470193386, blue: 0.8836612701, alpha: 1),
        UIColor(named: "17") ?? #colorLiteral(red: 0.6243798137, green: 0.5432854891, blue: 0.9222726226, alpha: 1),
        UIColor(named: "18") ?? #colorLiteral(red: 0.1919171214, green: 0.8337991834, blue: 0.4192006886, alpha: 1)
    ]
    private let newHabitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Новое нерегулярное событие"
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
    
    private var chosenCategory: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    var emojiCollectionView: UICollectionView = {
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
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupHabitUI()
        setupHabitConstraints()
        
        let trackerCategoryStore = TrackerCategoryStore()
        categoriesViewModel = CategoryViewControllerModel(trackerCategoryStore: trackerCategoryStore)
        
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textFieldSymbolConstraintLabel.isHidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        emojiCollectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        emojiCollectionView.allowsMultipleSelection = false
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        colorsCollectionView.dataSource = self
        colorsCollectionView.delegate = self
        colorsCollectionView.register(ColorsCollectionViewCell.self, forCellWithReuseIdentifier: "colorCell")
        colorsCollectionView.allowsMultipleSelection = false
        colorsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Private Methods
    private func setupHabitUI() {
        scrollView.addSubview(nameTextField)
        scrollView.addSubview(tableView)
        view.addSubview(newHabitLabel)
        scrollView.addSubview(cancelButton)
        scrollView.addSubview(createButton)
        scrollView.addSubview(textFieldSymbolConstraintLabel)
        scrollView.addSubview(emojiCollectionView)
        scrollView.addSubview(colorsCollectionView)
        scrollView.addSubview(emojiLabel)
        scrollView.addSubview(colorLabel)
        view.addSubview(scrollView)
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
            
            emojiCollectionView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 149),
            emojiCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 18),
            emojiCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -19),
            emojiCollectionView.widthAnchor.constraint(equalToConstant: 374),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            emojiLabel.topAnchor.constraint(equalTo: emojiCollectionView.topAnchor, constant: -24),
            emojiLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            emojiLabel.widthAnchor.constraint(equalToConstant: 52),
            emojiLabel.heightAnchor.constraint(equalToConstant: 18),
            
            colorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            
            colorsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:19),
            colorsCollectionView.widthAnchor.constraint(equalToConstant: 374),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: 204),
            colorsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -19),
            colorsCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 16),
        ])
    }
    
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
    
    private func updateCategoryCellSubtitle() {
        if let selectedCategory = selectedCategory {
            chosenCategory.isHidden = false
            categoryLabel.isHidden = false
            chosenCategory.text = selectedCategory
        } else {
            chosenCategory.isHidden = true
            categoryLabel.isHidden = true
            chosenCategory.text = nil
            categoryLabel.text = nil
        }
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func createButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        let mySchedule: Set<WeekDay> = Set([.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday])

        guard let selectedEmoji = selectedEmoji, selectedEmoji >= 0, selectedEmoji < emoji.count else { return }
        guard let selectedColor = selectedColor, selectedColor >= 0, selectedColor < colors.count else { return }

        let emojiInTracker = emoji [selectedEmoji]
        let colorInTracker = colors [selectedColor]

        let newTracker = Tracker(id: UUID(),
                                 name: name,
                                 color: colorInTracker,
                                 emoji: emojiInTracker,
                                 mySchedule: mySchedule, records: [])

        do {
               try trackerCategoryStore.createTrackerWithCategory(tracker: newTracker, with: selectedCategory ?? "")
           } catch {
               print("Error creating tracker with category: \(error)")
           }
        
        delegate?.newEventTrackerCreated(newTracker, category: selectedCategory) // Передача трекера и категории
        createButton.backgroundColor = .black
    }
    
    @objc private func textFieldDidChange() {
        if let text = nameTextField.text, !text.isEmpty {
            createButton.backgroundColor = .black
        } else {
            createButton.backgroundColor = UIColor(named: "Gray")
        }
        
        if let text = nameTextField.text, text.count >= 38 {
            textFieldSymbolConstraintLabel.isHidden = false
        } else {
            textFieldSymbolConstraintLabel.isHidden = true
        }
    }
}

// MARK: UITableViewDataSource
extension NewEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell.layer.masksToBounds = true
            
            switch indexPath.row {
            case 0:
                cell.backgroundColor = UIColor(named: "Background [day]")
                cell.layer.cornerRadius = 16
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 400)
                cell.accessoryType = .disclosureIndicator
                
                cell.contentView.addSubview(categoryLabel)
                cell.contentView.addSubview(chosenCategory)

                let categoryLabelTopConstraint = categoryLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 15)
                let categoryLabelLeadingConstraint = categoryLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16)
                let categoryLabelHeightConstraint = categoryLabel.heightAnchor.constraint(equalToConstant: 22)
                
                let chosenCategoryTopConstraint = chosenCategory.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 0)
                let chosenCategoryLeadingConstraint = chosenCategory.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16)
                let chosenCategoryBottomConstraint = chosenCategory.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -14)
                let chosenCategoryHeightConstraint = chosenCategory.heightAnchor.constraint(equalToConstant: 22)
                
                if selectedCategory == nil {
                    chosenCategory.isHidden = true
                    categoryLabelTopConstraint.constant = 0
                    categoryLabelLeadingConstraint.isActive = true
                    categoryLabel.textAlignment = .left
                } else {
                    chosenCategory.isHidden = false
                    categoryLabelTopConstraint.constant = 10
                    categoryLabelLeadingConstraint.isActive = false
                    categoryLabel.textAlignment = .left
                }
                
                NSLayoutConstraint.activate([
                    categoryLabelTopConstraint,
                    categoryLabelLeadingConstraint,
                    chosenCategoryTopConstraint,
                    chosenCategoryLeadingConstraint,
                    chosenCategoryBottomConstraint])
                
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
            categoryVC.viewModel = self.categoriesViewModel
            categoryVC.delegate = self
            let navController = UINavigationController(rootViewController: categoryVC)
            present(navController, animated: true, completion: nil)
        default:
            break
        }
    }
}

// MARK: - CategoryViewControllerDelegate
extension NewEventViewController: CategoryViewControllerDelegate {
    func didSelectCategory(_ category: TrackerCategory) {
        selectedCategory = category.title
        updateCategoryCellSubtitle()
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        dismiss(animated: true)
    }
}

// MARK: - TrackerSchedueViewControllerDelegate
extension NewEventViewController: TrackerScheduleViewControllerDelegate {
    func selectDays(in schedule: Set<WeekDay>) {
        self.mySchedule = schedule
        updateScheduleCellSubtitle()
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension NewEventViewController: UITextFieldDelegate {
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
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textFieldSymbolConstraintLabel.isHidden = true
        return true
    }
}

// MARK: - UICollectionViewDataSource
extension NewEventViewController: UICollectionViewDataSource {
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
            cell?.colorImageView.backgroundColor = colors[indexPath.row]
            
            if let selectedColor = selectedColor, indexPath.row == selectedColor {
                cell?.isSelected = true
            } else {
                cell?.isSelected = false
            }
            
            return cell!
            
        } else if collectionView == self.emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as? EmojiCollectionViewCell
            let emojiString = emoji[indexPath.row]
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 32, weight: .bold)
            ]
            let attributedEmoji = NSAttributedString(string: emojiString, attributes: attributes)
            cell?.emojiLabel.attributedText = attributedEmoji
            
            if let selectedEmoji = selectedEmoji, indexPath.row == selectedEmoji {
                cell?.backgroundColor = UIColor(named: "Light Gray")
                cell?.layer.cornerRadius = 16
            } else {
                cell?.backgroundColor = .clear
            }
            
            return cell!
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.colorsCollectionView {
            selectedColor = indexPath.row
        } else if collectionView == self.emojiCollectionView {
            
            if let previousSelectedEmoji = selectedEmoji {
                let previousIndexPath = IndexPath(row: previousSelectedEmoji, section: 0)
                if let previousCell = collectionView.cellForItem(at: previousIndexPath) as? EmojiCollectionViewCell {
                    previousCell.backgroundColor = .clear
                }
            }
            selectedEmoji = indexPath.row
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension NewEventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
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
