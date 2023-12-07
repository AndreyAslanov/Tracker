//
//  TrackerCategoryCell.swift
//  Tracker
//
//  Created by Андрей Асланов on 21.11.23.
//

import UIKit

class TrackerCategoryCell: UITableViewCell {
    
    // MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    // MARK: - Public Methods
    func configure(with category: TrackerCategory, isFirst: Bool, isLast: Bool, isSelected: Bool) {
        titleLabel.text = category.title
        
        var cornerMask: CACornerMask = []
        if isFirst && isLast {
            cornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirst {
            cornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLast {
            cornerMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        layer.cornerRadius = 16
        layer.maskedCorners = cornerMask
        accessoryType = isSelected ? .checkmark : .none
//        self.backgroundColor = UIColor(named: "Background [day]")
        self.backgroundColor = .darkBackground
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
}
