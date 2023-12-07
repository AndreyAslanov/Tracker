//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import UIKit

final class StatisticViewController: UIViewController {
    
    // MARK: - Properties
    var statisticViewModel: StatisticViewModel?
    private let trackerRecordStore = TrackerRecordStore()
    private let completedTrackersView = StatisticCell(name: LocalizableStringKeys.trackersCompleted)
    private var trackerStore = TrackerStore()
    
    private var cell1: StatisticCell?
    private var cell2: StatisticCell?
    private var cell4: StatisticCell?
    
    private var statisticLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizableStringKeys.statisticTabBar
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private let mainSpacePlaceholderStack: UIStackView = {
        let mainSpacePlaceholderStack = UIStackView()
        mainSpacePlaceholderStack.translatesAutoresizingMaskIntoConstraints = false
        mainSpacePlaceholderStack.contentMode = .scaleAspectFit
        mainSpacePlaceholderStack.layer.masksToBounds = true
        mainSpacePlaceholderStack.axis = .vertical
        mainSpacePlaceholderStack.alignment = .center
        mainSpacePlaceholderStack.spacing = 8
        return mainSpacePlaceholderStack
    }()
    
    private let statisticsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.text = LocalizableStringKeys.statisticText
        label.textAlignment = .center
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "statisticPic"))
        imageView.contentMode = .scaleAspectFit
        imageView.layer.frame = CGRect(origin: .zero, size: CGSize(width: 80, height: 80))
        return imageView
    }()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        let trackerStore = TrackerStore()
        let statisticViewModel = StatisticViewModel()
        
        trackerStore.setStatisticViewModel(statisticViewModel)
        self.trackerStore = trackerStore
        self.statisticViewModel = statisticViewModel
        
        view.addSubview(statisticLabel)
        view.addSubview(mainSpacePlaceholderStack)
        
        mainSpacePlaceholderStack.addArrangedSubview(imageView)
        mainSpacePlaceholderStack.addArrangedSubview(label)
        
        if statisticsStack.isHidden == true {
            mainSpacePlaceholderStack.isHidden = false
        }
        
        // Добавление ячеек статистики
          let cell1 = StatisticCell(number: 0, name: LocalizableStringKeys.bestPeriod)
          let cell2 = StatisticCell(number: 0, name: LocalizableStringKeys.idealDays)
          let cell4 = StatisticCell(number: 0, name: LocalizableStringKeys.averageValue)
   
        statisticsStack.addArrangedSubview(cell1)
        statisticsStack.addArrangedSubview(cell2)
        statisticsStack.addArrangedSubview(completedTrackersView)
        statisticsStack.addArrangedSubview(cell4)

        configureConstraints()
        
        statisticViewModel.onTrackersChange = { [weak self] trackers in
            guard let self = self else { return }
            self.checkContent(with: trackers)
            self.setupCompletedTrackersBlock(with: trackers.count)
            self.checkMainPlaceholderVisability()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statisticViewModel?.viewWillAppear()
    }
    
    // MARK: - Methods
    private func setupCompletedTrackersBlock(with count: Int) {
        completedTrackersView.setNumber(count)
    }
    
    private func checkMainPlaceholderVisability() {
            let isHidden = trackerRecordStore.trackerRecords?.isEmpty ?? true
            mainSpacePlaceholderStack.isHidden = !isHidden
        }

//    private func checkContent(with trackers: [TrackerRecord]) {
//        if trackers.isEmpty {
//            // Скрывать statisticsStack, когда нет трекеров
//            statisticsStack.isHidden = true
//            mainSpacePlaceholderStack.isHidden = false
//        } else {
//            // Показывать statisticsStack, когда есть трекеры
//            statisticsStack.isHidden = false
//
//            // Определять видимость ячеек внутри statisticsStack
//            cell1?.isHidden = completedTrackersView.isHidden
//            cell2?.isHidden = completedTrackersView.isHidden
//            cell4?.isHidden = completedTrackersView.isHidden
//        }
//    }
    
    private func checkContent(with trackers: [TrackerRecord]) {
        if trackers.isEmpty {
            statisticsStack.isHidden = true
            
        } else {
            statisticsStack.isHidden = false
            
        }
    }

    private func setupUI() {
        configureViews()
        configureConstraints()
    }
}

// MARK: - EXTENSIONS
// MARK: - Layout methods
private extension StatisticViewController {
    func configureViews() {
        [statisticLabel, mainSpacePlaceholderStack, statisticsStack].forEach { view.addSubview($0) }
        statisticsStack.addArrangedSubview(completedTrackersView)
       // statisticLabel.translatesAutoresizingMaskIntoConstraints = false
   //     mainSpacePlaceholderStack.translatesAutoresizingMaskIntoConstraints = false
      //  statisticsStack.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            statisticLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            statisticLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 0.1083),
            mainSpacePlaceholderStack.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 0.495),
            mainSpacePlaceholderStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statisticsStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            statisticsStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            statisticsStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
}
