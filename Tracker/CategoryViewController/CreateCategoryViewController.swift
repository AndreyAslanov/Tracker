//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Андрей Асланов on 26.10.23.
//

import UIKit

final class CreateCategoryViewController: UIViewController{
    
    var viewModel: CategoryViewControllerModel?
    
    private let topLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizableStringKeys.topLabelCategory
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = LocalizableStringKeys.nameTextFieldCategory
        textField.clearButtonMode = .always
//        textField.backgroundColor = UIColor(named: "Background [day]")
        textField.backgroundColor = .darkBackground
        textField.layer.cornerRadius = 16
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        textField.returnKeyType = .done
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return textField
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "Gray")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        navigationItem.hidesBackButton = true
    }
    
    private func setupUI() {
        view.addSubview(topLabel)
        view.addSubview(addButton)
        view.addSubview(nameTextField)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            topLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            
            nameTextField.leadingAnchor.constraint(equalTo:  view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo:  view.trailingAnchor, constant: -16),
            nameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 102),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
        ])
    }
    
    @objc func textFieldDidChange() {
        if let text = nameTextField.text, !text.isEmpty {
            addButton.backgroundColor = .black
            addButton.setTitleColor(.white, for: .normal)
            addButton.isEnabled = true
        } else {
            addButton.backgroundColor = UIColor(named: "Gray")
            addButton.setTitleColor(.white, for: .normal)
            addButton.isEnabled = false
        }
    }
    
    @objc private func addButtonTapped() {
        if let categoryName = nameTextField.text, !categoryName.isEmpty {
            do {
                let newCategory = TrackerCategory(title: categoryName, trackers: [])
                viewModel?.addCategory(newCategory)
                try TrackerCategoryStore.shared.createCategory(newCategory)
                print("Создаем категорию с именем: \(categoryName)")
                navigationController?.popViewController(animated: true)
            } catch {
                print("Ошибка при создании категории")
            }
        }
    }
}
// MARK: - UITextFieldDelegate
extension CreateCategoryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let range = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        return true
    }
     
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
}

// MARK: - Keyboard Handling
extension CreateCategoryViewController {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
