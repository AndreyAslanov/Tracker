//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Андрей Асланов on 24.10.23.
//

import UIKit
 
 final class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
     
     // MARK: - Properties
     lazy var pages: [UIViewController] = {
         let pageCount = 2
         
         let one = OnboardingPageViewController.Button(
             title: LocalizableStringKeys.buttonOnboarding,
             action: { [weak self] in self?.customButtonTapped() }
         )
         
         let two = OnboardingPageViewController.Button(
             title: LocalizableStringKeys.buttonOnboarding,
             action: { [weak self] in self?.customButtonTapped() }
         )
         
         return [
             OnboardingPageViewController(image: UIImage(named: "OnboardingOneBackground"), title: LocalizableStringKeys.onboardingPageFirst, button: one, pageCount: pageCount),
             OnboardingPageViewController(image: UIImage(named: "OnboardingTwoBackground"), title: LocalizableStringKeys.onboardingPageSecond, button: two, pageCount: pageCount)
         ]
     }()
     
     private lazy var pageControl: UIPageControl = {
         let pageControl = UIPageControl()
         pageControl.translatesAutoresizingMaskIntoConstraints = false
         pageControl.numberOfPages = pages.count
         pageControl.currentPage = 0
         pageControl.currentPageIndicatorTintColor = .black
         pageControl.pageIndicatorTintColor = .gray
         return pageControl
     }()
     
     // MARK: - Initialization
     init() {
         super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
     }
     
     required init?(coder: NSCoder) {
         super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
     }
     
     // MARK: - View Lifecycle
     override func viewDidLoad() {
         super.viewDidLoad()
         dataSource = self
         delegate = self
         
         if let first = pages.first {
             setViewControllers([first], direction: .forward, animated: true, completion: nil)
         }
         pageControlConstraints()
     }
     
     // MARK: - Private Methods
     private func setupImageConstraints(imageView: UIImageView, in container: UIViewController) {
         imageView.translatesAutoresizingMaskIntoConstraints = false
         NSLayoutConstraint.activate([
             imageView.leadingAnchor.constraint(equalTo: container.view.leadingAnchor),
             imageView.trailingAnchor.constraint(equalTo: container.view.trailingAnchor),
             imageView.topAnchor.constraint(equalTo: container.view.topAnchor),
             imageView.bottomAnchor.constraint(equalTo: container.view.bottomAnchor),
         ])
     }
     
     private func pageControlConstraints() {
         view.addSubview(pageControl)
         NSLayoutConstraint.activate([
             pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -168),
         ])
     }
     
     @objc private func customButtonTapped() {
         let tabBarController = TabBarController()
         
         if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
            let window = sceneDelegate.window {
             UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                 window.rootViewController = tabBarController
             }, completion: nil)
             UserDefaults.standard.set(true, forKey: "onboardingShow")
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
         }
     }
 }
