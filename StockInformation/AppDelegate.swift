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
        
        //GetStockValueforStockSym(stockSymbolTemp: "TSLA")
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
    func GetStockValueforStockSym(stockSymbolTemp :String ) //change the variable name after
    {
        
        let headers = [
            "x-rapidapi-key": "136911ffb3msh69c6efb713e8d01p16ecf6jsnb0202d799a9f",
            "x-rapidapi-host": "yahoo-finance-low-latency.p.rapidapi.com",
            // Henok's Key "x-rapidapi-key": "1529265bf5mshfd12832f51f908dp16ebb4jsne36b181d2338",
            
        ]
        let beginningURLString = "https://yahoo-finance-low-latency.p.rapidapi.com/v8/finance/chart/";
        let stockToken = stockSymbolTemp
        let EndURL =  "?interval=1m&range=1d"
        let realURL = beginningURLString + stockToken + EndURL
        let request = NSMutableURLRequest(url: NSURL(string: realURL)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 20.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
           // if let data = data, let dataString = String(data: data, encoding: .utf8) {
               // print("Response data string:\n \(dataString)")
                
          //  }
            
            if (error != nil) {
                print(error as Any)
            } else {
                do {
                    
                    if let dataDictionary = try JSONSerialization.jsonObject(with: data! as Data, options:[.allowFragments]) as? NSDictionary {
                        if let notchart = dataDictionary["chart"]! as? NSDictionary{
                            
                            if let results = notchart["result"] as? [[String:Any]]{//insert here
                                if let meta = results[0]["meta"] as? [String:Any]{
                                    print(meta["regularMarketPrice"]! as! Double)
                                }
                            }
                            else{
                                print("still no good")
                            }
                        }
                        else{
                            print("the NSDictionary did not work ")
                        }
                    }
                        
                    
                    
                   // let Json = try JSONDecoder().decode(Decodable.Protocol, from: data!)
                    //let dataDictionary = try JSONSerialization.jsonObject(with: data! as Data, option: .mutableContainers ,.allowFragmentation) as! [String]
                    
                    
                  /*
                 {//the reason why this is not working is due to notchart["results"] is not the datatype of a String or of String:Any so what data type is it
                     if let metas = results["meta"] as? NSDictionary{
                         print ("meta is: \(metas)");
                     }
                     else{
                     print("the else of metas")
                     }
                 }
                 else{
                     // results are not being the form of the if statement
                     print("the else of result")
                     if let errors = notchart["error"]! as? [String: Any]{
                         print("these are the errors \(errors)")
                     }
                     else{
                         //print("results and errors did not work \(notchart.index(forKey: "error"))")
                         
                     }*/
                   
                    
                    
                    
                    
                    
                       
                   
                }
                catch let error as NSError {
                    print("Error = \(error.localizedDescription)")
                    
                }
            }
            
        })
        
        dataTask.resume()
        
    }
    
}

