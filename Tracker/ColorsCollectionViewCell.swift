//
//  ColorsCollectionViewCell.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import UIKit

class ColorsCollectionViewCell: UICollectionViewCell {
    let colorLabel = UILabel()
    let colorImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(colorLabel)
        contentView.addSubview(colorImageView)
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        colorImageView.translatesAutoresizingMaskIntoConstraints = false

        
        NSLayoutConstraint.activate([
           // colorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
          //  colorLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorImageView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 5),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
