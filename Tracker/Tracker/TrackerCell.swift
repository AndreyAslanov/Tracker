//
//  TrackerCell.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func trackerCellDelegate(id: UUID)
}

final class TrackerCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    static let cellID = "cellID"
    weak var delegate: TrackerCellDelegate?
    var trackerRecordStore: TrackerRecordStore?
    private let filterViewController = FilterViewController()
    private let trackerViewController = TrackerViewController()
    private let analiticsService = AnalyticsService()
    var cellTapAction: (() -> Void)?
    
    // MARK: - Private Properties
    private var viewModel: TrackerCellViewModel? {
        didSet {
            updateTrackerView()
            updateLabels()
            updateDoneButton()
        }
    }
    
    private func updateTrackerView() {
        trackerView.backgroundColor = viewModel?.color
        pinImage.isHidden = !isPinned
    }
    
    private func updateLabels() {
        nameLabel.text = viewModel?.name ?? ""
        emojiLabel.text = viewModel?.emoji ?? ""
        let numberOfDays = viewModel?.counter ?? 0
        let formattedString = String.localizedStringWithFormat(NSLocalizedString("numberOfTasks", comment: ""), numberOfDays)
        counterLabel.text = formattedString
    }
    
    private func updateDoneButton() {
        doneButton.backgroundColor = viewModel?.color
        doneButton.isEnabled = viewModel?.doneButtonIsEnabled ?? false
        doneButton.layer.opacity = viewModel?.doneButtonIsEnabled ?? false == true ? 1 : 0.3
        var image: UIImage? = nil
        if let trackerIsDone = viewModel?.trackerIsDone, trackerIsDone {
            image = UIImage(systemName: "checkmark")
        } else {
            image = UIImage(systemName: "plus")
        }
        doneButton.setImage(image?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
    }
    
     lazy var trackerView: UIView = {
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
    
    private lazy var  counterLabel: UILabel = {
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
    
    private lazy var pinImage : UIImageView = {
        var view = UIImageView()
        guard let image = UIImage(named: "pin") else { return view }
        view.image = image
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        super.init(coder: coder)
    }
    
    // MARK: - Public Methods
    func configure(model: TrackerCellViewModel) {
        self.viewModel = model
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        contentView.addSubview(trackerView)
        contentView.addSubview(managementView)
        trackerView.addSubview(nameLabel)
        trackerView.addSubview(emojiView)
        trackerView.addSubview(pinImage)
        emojiView.addSubview(emojiLabel)
        managementView.addSubview(counterLabel)
        managementView.addSubview(doneButton)
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
            counterLabel.trailingAnchor.constraint(equalTo: doneButton.leadingAnchor, constant: -8),
            
            pinImage.heightAnchor.constraint(equalToConstant: 24),
            pinImage.widthAnchor.constraint(equalToConstant: 24),
            pinImage.topAnchor.constraint(equalTo: trackerView.topAnchor,constant: 12),
            pinImage.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),
        ])
    }
    
    var isPinned: Bool = false {
        didSet {
            updateTrackerView()
        }
    }
    
    @objc func doneButtonTapped() {
        cellTapAction?()
        analiticsService.report(event: "click", params: ["screen": "Main", "item": "track"])
    }
}
