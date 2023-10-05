//
//  OnboardingOne.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import UIKit

class OnboardingOne: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGesture.direction = .left
        view.addGestureRecognizer(swipeGesture)
        
        // Создание фоновой картинки
        let backgroundImage = UIImageView(image: UIImage(named: "OnboardingOneBackground"))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImage)
        
        // Создание надписи на фоне
        let label = UILabel()
        label.text = "Отслеживайте только то, что хотите"
        label.textColor  = UIColor(named: "Black")
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        // Создание черной кнопки с белой надписью
        let blackButton = UIButton()
        blackButton.backgroundColor = UIColor(named: "Black")
        blackButton.setTitle("Вот это технологии!", for: .normal)
        blackButton.setTitleColor(.white, for: .normal)
        blackButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        blackButton.layer.cornerRadius = 16
        blackButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blackButton)
        
        // Page Control
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 2
        pageControl.currentPage = 0 // Начальный индекс
        pageControl.pageIndicatorTintColor = .gray // Цвет индикаторов страниц
        pageControl.currentPageIndicatorTintColor = .black // Цвет текущей страницы
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
        // Создание констрейнтов
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 432),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -304),
                        
            blackButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            blackButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            blackButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 160), // Расстояние до лейбла
            blackButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: blackButton.topAnchor, constant: -24),
            pageControl.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor),
            pageControl.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor)
        ])
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            print("Swiped left")
            // Выполняем переход на новый экран
            let nextViewController = OnboardingTwo()
            navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
}




