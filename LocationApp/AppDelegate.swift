//
//  AppDelegate.swift
//  LocationTracker
//
//  Created by Partha Pratim on 28/12/23.
//

import UIKit

let appDelegate = UIApplication.shared.delegate as! AppDelegate

extension UIWindow {
    
    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: rootViewController)
        }
        return nil
    }
    
    class func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        
        if vc.isKind(of: UINavigationController.self) {
            let navigationController = vc as! UINavigationController
            return UIWindow.getVisibleViewControllerFrom( vc: navigationController.visibleViewController!)
            
        } else if vc.isKind(of: UITabBarController.self) {
            
            let tabBarController = vc as! UITabBarController
            return UIWindow.getVisibleViewControllerFrom(vc: tabBarController.selectedViewController!)
            
        } else {
            
            if let presentedViewController = vc.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(vc: presentedViewController.presentedViewController!)
                
            } else {
                return vc;
            }
        }
    }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let baseUrl = "https://businessautomata.com/inside-info/api/get/predefined/locations"

    var window: UIWindow?
    
    var mainViewController: GoogleMapViewController?
    var currentNavicon: UINavigationController?
    var googleMaapDataSync: GoogleMapDataSync = GoogleMapDataSync.sharedInstance

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        self.mainViewController = storyBoard.instantiateViewController(withIdentifier: "GoogleMapViewController") as? GoogleMapViewController
        let navCon = UINavigationController.init(rootViewController: mainViewController!)
        navCon.navigationBar.isHidden = true
        navCon.toolbar.isHidden = true
        self.window?.rootViewController = navCon
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()

        return true
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // make your function call
     }
}

