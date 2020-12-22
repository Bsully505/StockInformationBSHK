//
//  AppDelegate.swift
//  StockInformation
//
//  Created by Bryan Sullivan and Henok Ketsela on 12/15/20.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //simpleGetUrlWithParamRequest()
        // Override point for customization after application launch.
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    func simpleGetUrlWithParamRequest()
    {
        
        let headers = [
            "x-rapidapi-key": "136911ffb3msh69c6efb713e8d01p16ecf6jsnb0202d799a9f",
            "x-rapidapi-host": "yahoo-finance-low-latency.p.rapidapi.com",
            
        ]
 
        let realURL =  "https://yahoo-finance-low-latency.p.rapidapi.com/v8/finance/chart/AAPL?interval=1m&range=1d"
        let request = NSMutableURLRequest(url: NSURL(string: realURL)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 20.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                //print("Response data string:\n \(dataString)")
                
            }
            
            if (error != nil) {
                print(error as Any)
            } else {//this prints out the headers of the respnce from the api we do not need to use this data
                //let httpResponse = response as? HTTPURLResponse
                //print(httpResponse as Any)
                do {
                    let dataDictionary = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments) as! NSDictionary
                    
                    //print("Response dictionary is:\(dataDictionary)")
                    let Stock_Price = dataDictionary.allValues//(forKey: "regularMarketPrice")
                    let Stock_Ticket = dataDictionary.value(forKey: "chart")
                    print("the current stock price for \(Stock_Ticket as Any) is \(Stock_Price as Any) ")
                    
                }
                catch let error as NSError {
                    print("Error = \(error.localizedDescription)")
                    
                }
            }
            
        })
        
        dataTask.resume()
        
    }
    
}

