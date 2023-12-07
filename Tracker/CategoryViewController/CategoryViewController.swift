//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: TrackerCategory)
}

class CategoryViewController: UIViewController {
    
    var viewModel: CategoryViewControllerModel
    weak var delegate: CategoryViewControllerDelegate?
    static let shared = CategoryViewController.self
    
    // MARK: - Initializers
    init(viewModel: CategoryViewControllerModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let topLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var pictureStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
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
        label.numberOfLines = 2
        label.text = LocalizableStringKeys.trackerViewCategory
        label.textAlignment = .center
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.setTitle(LocalizableStringKeys.addButton, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
     let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = true
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        
        tableView.register(TrackerCategoryCell.self, forCellReuseIdentifier: "categoryCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        viewModel.loadCategoriesFromCoreData()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUIForEmptyState()
    }
    
    private func bindViewModel() {
        viewModel.updateView = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.updateUIForEmptyState()
            }
        }
    }
    
    func reload() {
        tableView.reloadData()
    }
    
    private func updateUIForEmptyState() {
        let isEmpty = viewModel.categories.isEmpty
        tableView.isHidden = isEmpty
        pictureStackView.isHidden = !isEmpty
    }
    
    private func setupUI() {
        pictureStackView.addArrangedSubview(pictureImageView)
        pictureStackView.addArrangedSubview(pictureText)
        
        view.addSubview(pictureStackView)
        view.addSubview(topLabel)
        view.addSubview(addButton)
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            pictureStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            pictureStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            topLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.widthAnchor.constraint(equalToConstant: 335),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16)
            
        ])
    }
    
    @objc private func addButtonTapped() {
        let createCategoryVC = CreateCategoryViewController()
        createCategoryVC.viewModel = self.viewModel
        navigationController?.pushViewController(createCategoryVC, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:  "categoryCell", for: indexPath) as! TrackerCategoryCell
        
        let category = viewModel.categories[indexPath.row]
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        let isSelected = indexPath.row == viewModel.selectedCategoryIndex
        
        cell.configure(with: category, isFirst: isFirstCell, isLast: isLastCell, isSelected: isSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        
        if isFirstCell && isLastCell {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 400)
        } else if isFirstCell {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLastCell {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 400)
        } else {
            cell.layer.cornerRadius = 0
            cell.layer.maskedCorners = []
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < viewModel.categories.count else {
            return
        }
        viewModel.selectedCategoryIndex = indexPath.row
        tableView.reloadData()
        let selectedCategory = viewModel.categories[indexPath.row]
        delegate?.didSelectCategory(selectedCategory)
    }
}
