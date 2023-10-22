//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import UIKit

final class CategoryViewController: UIViewController {
    
    private let topLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Категория"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(named: "White"), for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Привычки и события можно объединить по смыслу"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "Black")
        label.textAlignment = .center
        return label
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "star")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupConstraints()
        setupUI()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
//            topLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
//            topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
//            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
            
//            addCategoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addCategoryButton.widthAnchor.constraint(equalToConstant: 335),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
//            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
            
//            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            placeholderImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 346),
//            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
//            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
//            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
        ])
    }
    
    private func setupUI() {
        view.addSubview(topLabel)
        view.addSubview(addCategoryButton)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
    }
    
    @objc private func addCategoryButtonTapped() {

    }
}
