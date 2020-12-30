//
//  EntryViewController.swift
//  StockInformation
//
//  Created by Bryan Sullivan and Henok Ketsela on 12/18/20.
//

import UIKit

class EntryViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var field: UITextField! //This is the way the user inputs the added stock symbol
    @IBOutlet weak var label: UILabel!
    
    var update :(() -> Void)?
    var stockSym1 =  [String]()
    let debugmodeFlag = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        field.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(SaveStock))
        // Do any additional setup after loading the view.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //this is where we can add a check for User input which would allow us to call the current string in the text field and then place some data into a label underneath the textbox with the company name not the symbol
        print("StockSymArray: \(stockSym1)")
        
        
        if stockSym1.contains(field.text!){
        print("should return");
        }
        SaveStock()
        return true
    }

    @objc func SaveStock(){
        guard let StockSym = field.text, !StockSym.isEmpty else{
            return
        }
        guard let count = UserDefaults().value(forKey: "count") as? Int else{
            return
        }
        if !stockSym1.contains(field.text!.uppercased()){
            let errorHandelerVal = GetStockValueforStockSym(stockSymbolTemp: field.text!.uppercased())
            if !(errorHandelerVal < 0.0){
                let newcount = count+1;
                UserDefaults().setValue(newcount, forKey: "count")
                UserDefaults().setValue(StockSym.uppercased(), forKey:"stock_\(newcount)")
                UserDefaults().setValue(0.0, forKey:"\(StockSym.uppercased())_Count")
                update?()
                navigationController?.popViewController(animated: true)
            }
            else{
                print("ERROR CODE: \(errorHandelerVal)")
                //error handeling
                if errorHandelerVal == -1.8{
                    label.text = "The Stock Symbol that you have enterned is not a real Symbol please make sure you spelled the stock symbol correctly"
                }
                
            }
    }
        else{
            //this is where we can code up a label which would include text stating that no duplicate code can be made.
            if label.text == "result" {     // you should probably force everything to lowercase, to avoid wrong test
                      label.text = "Correct"
                } else {
                      label.text = "Please do not include duplicates, \(StockSym) is \n already in your portfolio"
                
                }
            //create user input test case which states if the stock symbol exists 
            
        }
    

    }
    
    func GetStockValueforStockSym(stockSymbolTemp :String) -> Double//change the variable name after
    {
        if(debugmodeFlag){
            return Double.random(in: 5.0...1000.0)
        }
        var CurVal: Double = -6.2// use for error handeling or getting the proper value
        
        let headers = [
            "x-rapidapi-key": "1529265bf5mshfd12832f51f908dp16ebb4jsne36b181d2338",
            //Bryans Key "x-rapidapi-key": "136911ffb3msh69c6efb713e8d01p16ecf6jsnb0202d799a9f",
            "x-rapidapi-host": "yahoo-finance-low-latency.p.rapidapi.com",
            
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
        
        let semaphore = DispatchSemaphore(value: 0)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if (error != nil) {
                print(error as Any)
            } else {
                do {
                    
                    if let dataDictionary = try JSONSerialization.jsonObject(with: data! as Data, options:[.allowFragments]) as? NSDictionary {
                        if let notchart = dataDictionary["chart"]! as? NSDictionary{
                            if let results = notchart["result"] as? [[String:Any]]{//insert here
                                if let meta = results[0]["meta"] as? [String:Any]{
                                    if let cpv = (meta["regularMarketPrice"] as? Double){
                                        //self.currentPriceView = cpv
                                        print("The curVal value is changed to \(cpv)")
                                        CurVal = cpv
                                        semaphore.signal()
                                        
                                                                                
                                    } else {
                                        CurVal = -1.0 //for bitcoin and such which we do not have the data for. More research is required.
                                       
                                    }
                                }
                            }
                            else{
                                //this is where the function goes when the ticket is not an actual stock symbol aka url no good
                                print("still no good")
                                CurVal = -1.8
                            }
                        }
                        else{
                            print("the NSDictionary did not work ")
                        }
                    }
                    semaphore.signal()
                    
                }
                catch let error as NSError {
                    print("Error = \(error.localizedDescription)")
                    
                }
            }
            
        })
        
        dataTask.resume()
        semaphore.wait()
        return CurVal
        
    }

}
