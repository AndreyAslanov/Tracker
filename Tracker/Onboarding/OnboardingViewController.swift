//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Андрей Асланов on 24.10.23.
//

import UIKit

class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    lazy var pages: [UIViewController] = {
        let one = UIViewController()
        let onboardingOneImageView = UIImageView(image: UIImage(named: "OnboardingOneBackground"))
        onboardingOneImageView.contentMode = .scaleAspectFill
        one.view.addSubview(onboardingOneImageView)
        setupImageConstraints(imageView: onboardingOneImageView, in: one)
        
        let two = UIViewController()
        let onboardingTwoImageView = UIImageView(image: UIImage(named: "OnboardingTwoBackground"))
        onboardingTwoImageView.contentMode = .scaleAspectFill
        two.view.addSubview(onboardingTwoImageView)
        setupImageConstraints(imageView: onboardingTwoImageView, in: two)
        
        return [one, two]
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .gray
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private let oneLabel: UILabel = {
        let label = UILabel()
        label.text = "Отслеживайте только то, что хотите"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let twoLabel: UILabel = {
        let label = UILabel()
        label.text = "Даже если это не литры воды и йога"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let blackButton: UIButton = {
        let blackButton = UIButton()
        blackButton.backgroundColor = .black
        blackButton.setTitle("Вот это технологии!", for: .normal)
        blackButton.setTitleColor(.white, for: .normal)
        blackButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        blackButton.layer.cornerRadius = 16
        blackButton.addTarget(self, action: #selector(blackButtonTapped), for: .touchUpInside)
        blackButton.translatesAutoresizingMaskIntoConstraints = false
        return blackButton
    }()
    
    init() {
           super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
       }
       
       required init?(coder: NSCoder) {
           super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        addUI()
        onboardingConstraints()
    }
    
    private func addUI() {
        view.addSubview(pageControl)
        view.addSubview(oneLabel)
        view.addSubview(twoLabel)
        view.addSubview(blackButton)
    }
    
    private func setupImageConstraints(imageView: UIImageView, in container: UIViewController) {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: container.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: container.view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.view.bottomAnchor),
        ])
    }
    
    private func onboardingConstraints() {
        NSLayoutConstraint.activate([
            oneLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            oneLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            oneLabel.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -130),
            
            twoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            twoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            twoLabel.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -130),
            
            blackButton.widthAnchor.constraint(equalToConstant: 335),
            blackButton.heightAnchor.constraint(equalToConstant: 60),
            blackButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            blackButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            blackButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -103),
            
            pageControl.centerXAnchor.constraint(equalTo: blackButton.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: blackButton.topAnchor, constant: -24),
        ])
        showLabelAtIndex(pageControl.currentPage)
    }
    
    private func showLabelAtIndex(_ index: Int) {
        if index == 0 {
            oneLabel.isHidden = false
            twoLabel.isHidden = true
        } else if index == 1 {
            oneLabel.isHidden = true
            twoLabel.isHidden = false
        }
    }
    
    @objc private func blackButtonTapped() {
        let tabBarController = TabBarController()
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            UIView.transition(with: window, duration: 0.2, options: .transitionCrossDissolve, animations: {
                window.rootViewController = tabBarController
            }, completion: nil)
            UserDefaults.standard.set(true, forKey: "onboardingShown")
        }
    }
    
    // MARK: - UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return nil
        }
        
        return pages[nextIndex]
    }
    
    // MARK: - UIPageViewControllerDelegate
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
            showLabelAtIndex(currentIndex)
        }
    }
}
