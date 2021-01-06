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
    @IBOutlet var StockInfo: UILabel!
    
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
       

        let set = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ")
        if (StockSym.rangeOfCharacter(from: set.inverted) != nil) {
            print("it comes here")
            StockInfo.textColor = UIColor.red
            StockInfo.text = "please only include letters, your input includes either whitespace or punctuation"
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
                    UserDefaults().setValue(0.0,forKey: "\(StockSym.uppercased())_AvgPrice")
                    update?()
                    navigationController?.popViewController(animated: true)
                }
                else{
                    print("ERROR CODE: \(errorHandelerVal)")
                    //error handeling
                    if errorHandelerVal == -1.0{
                        label.text = "The Stock Symbol that you have enterned is not a real Symbol please make sure you spelled the stock symbol correctly"
                    }
                    if errorHandelerVal == -1.8{
                        label.text = "The Stock Symbol that you have enterned is not a real Symbol please make sure you spelled the stock symbol correctly"
                    }
                    if errorHandelerVal == -1.6{
                        print("error of non letters")
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
    
    @IBAction func TestStock(){//this is where you call the funtion and update the label
        self.view.endEditing(true)
        StockInfo.textColor = UIColor.systemGreen
        let StockSymbol = field.text!
        let set = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ")
        if (StockSymbol.rangeOfCharacter(from: set.inverted) != nil) {
            StockInfo.textColor = UIColor.red
            StockInfo.text = "please only include letters, your input includes either whitespace or punctuation"
            
        }
        else{
            let StockID = ViewController().GetStockInfoforStockSym(stockSymbolTemp: StockSymbol)
            if StockID.count == 7 {
                StockInfo.text = " Company Name: \(StockID[0]) \n Currency: \(StockID[1]) \n Prev Closing Price: \(StockID[6]) \n 52 WK High/Low: \(StockID[2])/\(StockID[3]) \n Day High/Low: \(StockID[4])/\(StockID[5]) "
            } else {
                StockInfo.textColor = UIColor.red
                StockInfo.text = " \(StockID[0])"
            }
        }
    }
    
    func GetStockValueforStockSym(stockSymbolTemp :String) -> Double//change the variable name after
    {
        if(debugmodeFlag){
            let x = Double.random(in: 5.0...1000.0)
            return Double(round(x*100)/100)
        }
        

            let set = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ")
            if (stockSymbolTemp.rangeOfCharacter(from: set.inverted) != nil) {
                return -1.6
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
//    func InputTester(input: String)-> Bool{
//
//        let set = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ")
//        if !(input.rangeOfCharacter(from: set.inverted) != nil) {
//            return true
//        }
//        else{
//        return false
//        }
//    }
    
}
