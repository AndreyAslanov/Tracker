//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Андрей Асланов on 21.11.23.
//

import UIKit

class OnboardingPageViewController: UIViewController {
    
    struct Button {
        let title: String
        let action: () -> Void
    }
    
    // MARK: - Properties
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private var buttonAction: (() -> Void)?
    
    // MARK: - Initialization
    init(image: UIImage?, title: String, button: Button, pageCount: Int) {
        super.init(nibName: nil, bundle: nil)
        self.imageView.image = image
        self.titleLabel.text = title
        setupButton(button: button)
        self.button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Private Methods
    private func setupButton(button: Button) {
        self.button.setTitle(button.title, for: .normal)
        self.buttonAction = button.action
    }
    
    private func setupUI() {
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Button Action
    @objc private func buttonTapped() {
        buttonAction?()
    }
}
