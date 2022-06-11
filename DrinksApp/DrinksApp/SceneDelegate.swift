//
//  SceneDelegate.swift
//  DrinksApp
//
//  Created by Paulo Sergio da Silva Rodrigues on 07/06/22.
//

import UIKit
import DrinksCore

func remoteGetDrinks() async throws -> [Drink] {
    let httpClient = URLSessionHTTPClient()
    let url = URL(string: "https://pssr.dev/drinks.json")!
    let remoteDrinksLoader = RemoteDrinksLoader(url: url, httpClient: httpClient)

    return try await remoteDrinksLoader.load()
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        configureView()
    }

    func configureView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navController = storyboard.instantiateInitialViewController() as! UINavigationController
        let drinksViewController = navController.topViewController as! DrinksViewController
        drinksViewController.getDrinks = remoteGetDrinks

        window?.rootViewController = navController
    }


}

