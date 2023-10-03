//
//  ColorsCollectionViewCell.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import UIKit

class ColorsCollectionViewCell: UICollectionViewCell {
    let colorLabel = UILabel()
    let colorImageView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                let selectedBackgroundView = UIView()
                selectedBackgroundView.backgroundColor = .clear // Цвет фона
                selectedBackgroundView.layer.cornerRadius = 8 // скругление
                selectedBackgroundView.layer.borderWidth = 3 // Ширина границы
                let borderColor = colorImageView.backgroundColor?.withAlphaComponent(0.3).cgColor //граница
                selectedBackgroundView.layer.borderColor = borderColor
                self.selectedBackgroundView = selectedBackgroundView
            } else {
                self.selectedBackgroundView = nil
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(colorLabel)
        contentView.addSubview(colorImageView)
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        colorImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.layer.borderColor = nil
        
        NSLayoutConstraint.activate([
            // colorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            //  colorLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            // colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            //   colorImageView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 5), // хз
            colorImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorImageView.heightAnchor.constraint(equalToConstant: 40),
            colorImageView.widthAnchor.constraint(equalToConstant: 40)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
