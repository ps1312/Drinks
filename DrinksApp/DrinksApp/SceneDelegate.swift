//
//  SceneDelegate.swift
//  DrinksApp
//
//  Created by Paulo Sergio da Silva Rodrigues on 07/06/22.
//

import UIKit
import DrinksCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: scene)
        configureView()
    }

    func configureView() {
        let httpClient = URLSessionHTTPClient()
        let url = URL(string: "https://pssr.dev/drinks.json")!
        let remoteDrinksLoader = RemoteDrinksLoader(url: url, httpClient: httpClient)

        let bundle = Bundle(for: DrinksViewController.self)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let navController = storyboard.instantiateInitialViewController() as! UINavigationController
        let drinksViewController = navController.topViewController as! DrinksViewController

        drinksViewController.getDrinks = { completion in
            remoteDrinksLoader.load { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
        drinksViewController.getImage = { url, completion in
            httpClient.get(from: url) { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }

        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }


}

