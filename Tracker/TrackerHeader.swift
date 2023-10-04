//
//  TrackerHeader.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import UIKit

final class TrackerHeader: UICollectionReusableView {
    static var header = "header"
    
    private var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabelViews()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        super.init(coder: coder)
    }
    
    func configure(headerText: String) {
        headerLabel.text = headerText
    }
    
    private func setupLabelViews() {
        addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),     //исправил
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
