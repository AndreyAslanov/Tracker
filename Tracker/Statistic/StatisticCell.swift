//
//  StatisticCell.swift
//  Tracker
//
//  Created by Андрей Асланов on 25.11.23.
//

import UIKit

final class StatisticCell: UIView {
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 34)
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    // MARK: - Properties
    private var number: Int {
        didSet {
            numberLabel.text = "\(number)"
        }
    }
    private var name: String {
        didSet {
            nameLabel.text = name
        }
    }
    
    // MARK: - Lifecycle
    required init(number: Int = 0, name: String) {
        self.number = number
        self.name = name
        
        super.init(frame: .zero)
        setNumber(number)
        setName(name)
        configureViews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupBorder()
    }
    
    // MARK: - Functions
    func setNumber(_ number: Int) {
        self.number = number
    }
    
    func setName(_ name: String) {
        self.name = name
    }
}

// MARK: - Layout methods
extension StatisticCell {
    
    func configureViews() {
        translatesAutoresizingMaskIntoConstraints = false
        [numberLabel, nameLabel].forEach { addSubview($0) }
    }
    
    func setupBorder() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor.red.cgColor,
            UIColor.green.cgColor,
            UIColor.blue.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 1
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer
        layer.cornerRadius = 16
        layer.masksToBounds = true
        layer.addSublayer(gradientLayer)
    }

    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            numberLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            numberLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            nameLabel.leadingAnchor.constraint(equalTo: numberLabel.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: numberLabel.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
    }
    
}
