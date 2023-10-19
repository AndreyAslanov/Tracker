//
//  TrackerCell.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    static let cellID = "cellID"
    var doneCompletion: (() -> Void)?
    
    // MARK: - UI Elements
    private lazy var trackerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var  emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var emojiView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.backgroundColor = .white.withAlphaComponent(0.3)
        return view
    }()
    
    private lazy var managementView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(systemName: "plus")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.layer.cornerRadius = 17
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    func configure(model: TrackerCellViewModel) {
        trackerView.backgroundColor = model.color
        nameLabel.text = model.name
        emojiLabel.text = model.emoji
        counterLabel.text = "\(model.counter ) \(model.counter.days() )"
        doneButton.backgroundColor = model.color
        doneButton.isEnabled = model.doneButtonIsEnabled
        doneButton.layer.opacity = model.doneButtonIsEnabled == true ? 1 : 0.3
        setupCheckButton(to: model.trackerIsDone)
    }
    
    func setupCheckButton(to state: Bool) {
        let image = UIImage(
            systemName: state ? "checkmark" : "plus"
        )?.withTintColor(
            .white,
            renderingMode: .alwaysOriginal
        )
        doneButton.setImage(image, for: .normal)
    }
    
    private func setupViews() {
        contentView.addSubview(trackerView)
        contentView.addSubview(managementView)
        trackerView.addSubview(nameLabel)
        trackerView.addSubview(emojiView)
        emojiView.addSubview(emojiLabel)
        managementView.addSubview(counterLabel)
        managementView.addSubview(doneButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            trackerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerView.heightAnchor.constraint(equalToConstant: 90),
            
            managementView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            managementView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            managementView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            managementView.heightAnchor.constraint(equalToConstant: 58),
            
            nameLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: -12),
            
            emojiView.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 12),
            emojiView.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            emojiView.heightAnchor.constraint(equalToConstant: 24),
            emojiView.widthAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor),
            
            doneButton.topAnchor.constraint(equalTo: managementView.topAnchor, constant: 8),
            doneButton.trailingAnchor.constraint(equalTo: managementView.trailingAnchor, constant: -12),
            doneButton.heightAnchor.constraint(equalToConstant: 34),
            doneButton.widthAnchor.constraint(equalToConstant: 34),
            
            counterLabel.leadingAnchor.constraint(equalTo: managementView.leadingAnchor, constant: 12),
            counterLabel.topAnchor.constraint(equalTo: managementView.topAnchor, constant: 16),
            counterLabel.trailingAnchor.constraint(equalTo: doneButton.leadingAnchor, constant: -8)
        ])
    }
    
    @objc func doneButtonTapped() {
        doneCompletion?()
    }
}

// MARK: - Extension
extension UInt {
    func days() -> String {
        let secondDigitFromEnd = (self / 10) % 10
        let lastDigit = self % 10
        if secondDigitFromEnd == 1 || 5...9 ~= lastDigit || lastDigit == 0 {
            return "дней"
        } else if lastDigit == 1 {
            return "день"
        } else if 2...4 ~= lastDigit   {
            return "дня"
        }
        return ""
    }
}
