//
//  GoogleMapDataSync.swift
//  LocationTracker
//
//  Created byPartha Pratim on 28/12/23.
//

import Foundation
import UIKit

class ApiLocationDataSync: NSObject{
    
    var locationDataModel: LocationDataModel?
    var coordinateArray: [Payload] = [Payload]()
    
    var is_running : Bool = false
    var currentPage : Int = 1
    
    static let sharedInstance: ApiLocationDataSync = {
        let instance = ApiLocationDataSync()
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
                return
            }
            
            if let data = data {
                do {
                    print(self.currentPage)
                    let decoder = JSONDecoder()
                    let dataModel = try decoder.decode(LocationDataModel?.self, from: data)
                    self.coordinateArray.removeAll()
                    self.coordinateArray.append(contentsOf: (dataModel?.payload)!)
                    DispatchQueue.main.async(execute: {
                        if let topController = appDelegate.mainViewController {
                            if (topController.isKind(of: MainViewController.self)){
                                (topController).coordinateArray = self.coordinateArray
                                (topController).reloadData()
                                return
                            }
                        }
                    })
                } catch {
                    DispatchQueue.main.async(execute: {
                        if let topController = appDelegate.mainViewController {
                            if (topController.isKind(of: MainViewController.self)){
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
