//
//  AppDelegate.swift
//  Tracker
//
//  Created by Андрей Асланов on 02.10.23.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //        // Создаем корневой контроллер для первого экрана
        //        let rootViewController = OnboardingOne()
        //        // Создаем навигационный контроллер с корневым контроллером
        //        let navigationController = UINavigationController(rootViewController: rootViewController)
        //
        //        // Настройки окна
        //        window = UIWindow(frame: UIScreen.main.bounds)
        //        window?.rootViewController = navigationController
        //        window?.makeKeyAndVisible()
        //
        //        return true
        
        /*
         let trackerViewController = TrackerViewController() // Создаем экземпляр TrackerViewController
         let navigationController = UINavigationController(rootViewController: trackerViewController) // Помещаем TrackerViewController в UINavigationController
         
         window = UIWindow(frame: UIScreen.main.bounds)
         window?.rootViewController = navigationController // Устанавливаем UINavigationController как корневой контроллер
         window?.makeKeyAndVisible()
         
         return true
         
         }
         */
        
        // Создание экземпляра TabBarController
        let tabBarController = TabBarController()
        
        // Создание UIWindow и установка TabBarController как корневого контроллера
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(
            name: "Tracker",
            sessionRole: connectingSceneSession.role
        )
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    lazy var persistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}



