//
//  GoogleMapDataSync.swift
//  LocationTracker
//
//  Created by Annanovas IT on 28/12/23.
//

import Foundation
import UIKit

class GoogleMapDataSync: NSObject{
    
    var locationDataModel: LocationDataModel?
    
    var is_running : Bool = false
    var currentPage : Int = 1
    
    static let sharedInstance: GoogleMapDataSync = {
        let instance = GoogleMapDataSync()
        return instance
    }()
    
    override init() {
        super.init()
        is_running = false
    }
    
    func fetchData() {
        
        let urlComponents = URLComponents(string: appDelegate.baseUrl)!
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                LoadingIndicatorView.hide()
                return
            }
            
            if let data = data {
                do {
                    print(self.currentPage)
                    let decoder = JSONDecoder()
                    print(data.description)
                    DispatchQueue.main.async(execute: {
                        if let topController = appDelegate.mainViewController {
                            if (topController.isKind(of: GoogleMapViewController.self)){
                                (topController).reloadData()
                                return
                            }
                        }
                    })
                } catch {
                    DispatchQueue.main.async(execute: {
                        if let topController = appDelegate.mainViewController {
                            if (topController.isKind(of: GoogleMapViewController.self)){
                                (topController).reloadData()
                                return
                            }
                        }
                    })
                }
            }
        }
        task.resume()
        
    }
}
