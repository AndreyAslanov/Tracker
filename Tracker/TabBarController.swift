//
//  TabBarController.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Создание вью-контроллеров для вкладок
        let trackerViewController = UINavigationController(rootViewController: TrackerViewController())
        let statisticViewController = UINavigationController(rootViewController: StatisticViewController())
        
        // Назначение заголовков и изображений вкладок
        trackerViewController.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "tabBarTracker"), selectedImage: nil)
        statisticViewController.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "tabBarStatistics"), selectedImage: nil)
        
        // Создание массива с вью-контроллерами
        let viewControllers = [trackerViewController, statisticViewController]
        
        // Назначение вью-контроллеров таб-бар контроллеру
        self.viewControllers = viewControllers
        
        // Добавление изображений справа и слева на каждую вкладку
        for viewController in viewControllers {
            let leftImage = UIImage(named: "leftImage")
            let rightImage = UIImage(named: "rightImage")
            
            let leftBarButtonItem = UIBarButtonItem(image: leftImage, style: .plain, target: self, action: #selector(leftBarButtonTapped))
            let rightBarButtonItem = UIBarButtonItem(image: rightImage, style: .plain, target: self, action: #selector(rightBarButtonTapped))
            
            viewController.navigationItem.leftBarButtonItem = leftBarButtonItem
            viewController.navigationItem.rightBarButtonItem = rightBarButtonItem
        }
        
        // Настройка внешнего вида таб бара
        if #available(iOS 13.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBarAppearance.backgroundColor = UIColor.white
            tabBarAppearance.shadowColor = UIColor.black

            tabBar.standardAppearance = tabBarAppearance

            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = tabBarAppearance
            }
        }
    }
    
    @objc func leftBarButtonTapped() {
        // Действие при нажатии на изображение слева
    }
    
    @objc func rightBarButtonTapped() {
        // Действие при нажатии на изображение справа
    }
}

