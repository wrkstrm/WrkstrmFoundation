//
//  AppDelegate.swift
//  Example
//
//  Created by Cristian Monterroza on 9/1/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import UIKit
import WrkstrmFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let options = TypographyController()
        let optionsNav = UINavigationController(rootViewController: options)
        let splitView = UISplitViewController()
        splitView.viewControllers = [optionsNav]

        window?.rootViewController = splitView
        window?.makeKeyAndVisible()
        return true
    }
}
