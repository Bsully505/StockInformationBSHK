//
//  SceneDelegate.swift
//  StockInformation
//
//  Created by Bryan Sullivan on 12/15/20.
//

import UIKit
import Foundation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        simpleGetUrlWithParamRequest()
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    func simpleGetUrlWithParamRequest()
        {
        
        let headers = [
            "x-rapidapi-key": "136911ffb3msh69c6efb713e8d01p16ecf6jsnb0202d799a9f",
            "x-rapidapi-host": "yahoo-finance-low-latency.p.rapidapi.com"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://yahoo-finance-low-latency.p.rapidapi.com/v8/finance/chart/AAPL?comparisons=MSFT%2C%5EVIX")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print("error")
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse as Any)
            }
        })

        dataTask.resume()
        
    }
        
}
        
        /*
            let url = URL(string: "https://yahoo-finance-low-latency.p.rapidapi.com/v8/finance/chart/AAPL?interval=1d&range=1d&lang=en&rapidapi-key=136911ffb3msh69c6efb713e8d01p16ecf6jsnb0202d799a9f")!
           // let url = URL(string: "https://www.google.com/search?q=peace")!
            //let url = URL(string:"https://cloud.iexapis.com/stable/stock/APPL/quote?token=pk_9de1eaea0bd444cdbea4bde246826f92")!
            //url.httpMethod = "GET"
        
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                
                    if error != nil || data == nil {
                        print("Client error!")
                        return
                    }
                    guard let response = response as? HTTPURLResponse else {
                        print("Server error!")
                        return
                    }
                    print("The Response is : ",response)
                }
                task.resume()
        }


}
*/
