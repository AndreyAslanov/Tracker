//
//  ColorsCollectionViewCell.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import UIKit

final class ColorsCollectionViewCell: UICollectionViewCell {
    let colorLabel = UILabel()
    let colorImageView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private let selectedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 3
        view.isHidden = true
        return view
    }()
    
    var needShowSelected = false {
        didSet {
            if needShowSelected {
                selectedView.layer.borderColor = colorImageView.backgroundColor?.withAlphaComponent(0.3).cgColor
                selectedView.isHidden = false
            } else {
                selectedView.isHidden = true
            }
        }
    }

    override init(frame: CGRect) {
        needShowSelected = false
        super.init(frame: frame)
        layer.borderColor = nil

        contentView.addSubview(selectedView)
        contentView.addSubview(colorImageView)
        colorImageView.translatesAutoresizingMaskIntoConstraints = false

        self.layer.borderColor = nil

        NSLayoutConstraint.activate([
            colorImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorImageView.heightAnchor.constraint(equalToConstant: 40),
            colorImageView.widthAnchor.constraint(equalToConstant: 40),
            
            selectedView.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            selectedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        needShowSelected = false
    }
}
