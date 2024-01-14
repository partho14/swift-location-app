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
    var todayDate = Date()
    var toDate = ""

    var mainViewController: MainViewController?
    var currentNavicon: UINavigationController?
    var googleMaapDataSync: ApiLocationDataSync = ApiLocationDataSync.sharedInstance
    
    let prefs = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.toDate = (prefs.value(forKey: "toDate") != nil) ? prefs.value(forKey: "toDate") as! String : ""
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let todayDateString = dateFormatter.string(from: self.todayDate)
        
        if(self.toDate == todayDateString){
            print("true")
        }else{
            print("false")
            prefs.setValue(todayDateString, forKey: "toDate")
            prefs.removeObject(forKey: "locationLatLong")
        }
        

        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        self.mainViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController
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

