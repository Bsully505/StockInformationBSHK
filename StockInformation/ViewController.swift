//
//  ViewController.swift
//  StockInformation
//
//  Created by Bryan Sullivan and Henok Ketsela on 12/15/20.
/*
 need a refreash button which will call a update
 */
//

import UIKit


class ViewController: UIViewController {
    
    
    @IBOutlet var tableView: UITableView!
    
    var stockSymbols = [String]()
    var currentPriceView: Double = 1.5
    let debugmodeFlag: Bool = true     //allows to togle getting real api requests
    
    
    override func viewDidLoad() {
        //GetStockInfoforStockSym(stockSymbolTemp: "Tsla")
        super.viewDidLoad()
        self.title = "Stocks"
        
        tableView.delegate = self
        tableView.dataSource = self
        if !UserDefaults().bool(forKey: "setup"){
            UserDefaults().set(true, forKey: "setup")
            UserDefaults().set(0, forKey: "count")
        }
        
        let defaults = UserDefaults.standard
        //self.MasterReset() //only used when wanting to erase all data on the phone
        self.UpdateStocks()
        // Do any additional setup after loading the view.
    }
    
    func MasterReset(){
        let defaults = UserDefaults.standard
        deleteStocks()
        defaults.setValue(0,forKey: "count");
        
        
        
    }
    func deleteStocks(){
        stockSymbols.removeAll()
        let defaults = UserDefaults.standard
        guard let count = defaults.value(forKey: "count") as? Int else{
            return
        }
        for x in 0..<count{
            defaults.setValue(nil, forKey: "stock_\(x+1)")
            
        }
        tableView.reloadData()
    }
    func UpdateStocks(){
        // perform (#selector(authenticate), with: nil, afterDelay: 100)
        stockSymbols.removeAll()
        let defaults = UserDefaults.standard
        guard let count = defaults.value(forKey: "count") as? Int else{
            return
        }
        for x in 0..<count{
            if let stock = defaults.value(forKey: "stock_\(x+1)") as? String{
                //print("at position \(x) we have \(stock)")
                
                stockSymbols.append(stock)
            }
        }
        tableView.reloadData()
        
    }
    @IBAction func refreshPortfolioStocks(){
        self.UpdateStocks()
    }
    @IBAction func didTouchApp(){
        let vc = storyboard?.instantiateViewController(identifier: "Entry") as! EntryViewController
        vc.title = "new Stock"
        vc.stockSym1 = stockSymbols
        vc.update = {
            DispatchQueue.main.async {
                self.UpdateStocks()
            }
            
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
}
extension ViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        let vc = storyboard?.instantiateViewController(identifier: "StockSymbol") as! StockViewController
        
        
        vc.title = "Stock Information"
        vc.stockSym = stockSymbols[indexPath.row]
        vc.curPos = indexPath.row as Int
        vc.CurPrice = self.GetStockValueforStockSym(stockSymbolTemp: vc.stockSym)
        // vc.CounterLabel.text = String( UserDefaults().value(forKey: "\(vc.stockSym)_Count"))
        vc.update = {
            DispatchQueue.main.async {
                self.UpdateStocks()
            }
            
        }
        
        vc.UpdateLabel = {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7){
                vc.label.text = ("The current stock price for " + vc.stockSym + " is $" + String(vc.CurPrice!))
                print("curprice is currently \(vc.CurPrice)")
            }
            
        }
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
class MyCell: UITableViewCell {
    
    @IBOutlet weak var label1: UILabel!
    
    @IBOutlet weak var label2: UILabel!
    
    
    
}
extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stockSymbols.count;
    }
    //this function is called when adding a new cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProtoCell", for : indexPath) as! MyCell
        cell.label1?.text = stockSymbols[indexPath.row]
        cell.label2?.text = String(GetStockValueforStockSym(stockSymbolTemp: cell.label1?.text ??  "BTC" ))
        
        return cell;
    }
    
    
    
    func GetStockValueforStockSym(stockSymbolTemp :String, VC: StockViewController ) -> Double//change the variable name after
    {
        var CurVal: Double = self.currentPriceView// has the value of the previous stock
        
        let headers = [
            "x-rapidapi-key": "1529265bf5mshfd12832f51f908dp16ebb4jsne36b181d2338",
            //Bryans API KEY"x-rapidapi-key": "136911ffb3msh69c6efb713e8d01p16ecf6jsnb0202d799a9f",
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
                                        self.currentPriceView = cpv
                                        print("The curVal value is changed to \(self.currentPriceView)")
                                        VC.UpdateLabel?()
                                        
                                        
                                    } else {
                                        self.currentPriceView = -1.0
                                        VC.UpdateLabel?()
                                    }
                                }
                            }
                            else{
                                //this is where the function goes when the ticket is not an actual stock symbol aka url no good 
                                print("still no good")
                            }
                        }
                        else{
                            print("the NSDictionary did not work ")
                        }
                    }
                    
                }
                catch let error as NSError {
                    print("Error = \(error.localizedDescription)")
                    
                }
            }
            
        })
        
        dataTask.resume()
        return CurVal
        
    }
    
    func GetStockValueforStockSym(stockSymbolTemp :String) -> Double//change the variable name after
    {
        if(debugmodeFlag){
            return Double.random(in: 5.0...1000.0)
        }
        var CurVal: Double = -6.2// has the value of the previous stock
        
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
                                        self.currentPriceView = -1.0
                                        
                                    }
                                }
                            }
                            else{
                                //this is where the function goes when the ticket is not an actual stock symbol aka url no good
                                print("still no good")
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
    func GetStockInfoforStockSym(stockSymbolTemp :String) -> [String]//change the variable name after
    {
        //        if(debugmodeFlag){
        //            return Double.random(in: 5.0...1000.0)
        //        }
        var CurVal: [String] = []// has the value of the previous stock
        
        let headers = [
            "x-rapidapi-key": "1529265bf5mshfd12832f51f908dp16ebb4jsne36b181d2338",
            //Bryans Key "x-rapidapi-key": "136911ffb3msh69c6efb713e8d01p16ecf6jsnb0202d799a9f",
            "x-rapidapi-host": "yahoo-finance-low-latency.p.rapidapi.com",
            
        ]
        let beginningURLString = "https://yahoo-finance-low-latency.p.rapidapi.com/v6/finance/quote?symbols=";
        let stockToken = stockSymbolTemp
        // let EndURL =  "?interval=1m&range=1d"
        let realURL = beginningURLString + stockToken //+ EndURL
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
                        if let notchart = dataDictionary["quoteResponse"] as? NSDictionary{
                            if let results = notchart["result"] as? [[String:Any]]{//insert here
                                print(results)
                                if !results.isEmpty {
                                    if let compName = results[0]["longName"] as? String{
                                        //if let cpv = (result["regularMarketPrice"] as? Double){
                                        //self.currentPriceView = cpv
                                        print("company Name is \(compName)")
                                        CurVal.append(String(compName))
                                        
                                        
                                        
                                        //                                    } else {
                                        //                                        self.currentPriceView = -1.0
                                        //
                                        //                                    }
                                    } else {
                                        CurVal.append("NOT A STOCK SYMBOL");
                                        print("Company name not working")
                                    }
                                    
                                    if let compCurrency = results[0]["currency"] as? String{
                                        print("company currency is \(compCurrency)")
                                        CurVal.append(compCurrency)
                                        //semaphore.signal()
                                    }
                                    if let comp52high = results[0]["fiftyTwoWeekHigh"] as? Double{
                                        print("company 52 week high is \(comp52high)")
                                        //semaphore.signal()
                                        CurVal.append(String(comp52high))
                                    }
                                    if let comp52low = results[0]["fiftyTwoWeekLow"] as? Double{
                                        print("company 52 week low is \(comp52low)")
                                        CurVal.append(String(comp52low))
                                        
                                        //semaphore.signal()
                                    }
                                    if let compDayhigh = results[0]["regularMarketDayHigh"] as? Double{
                                        print("company day high is \(compDayhigh)")
                                        //semaphore.signal()
                                        CurVal.append(String(compDayhigh))
                                        
                                    }
                                    if let compDaylow = results[0]["regularMarketDayLow"] as? Double{
                                        print("company day low is \(compDaylow)")
                                        CurVal.append(String(compDaylow))
                                        //semaphore.signal()
                                    }
                                    if let compPrevClose = results[0]["regularMarketPreviousClose"] as? Double{
                                        print("company Previous Closing price is \(compPrevClose)")
                                        //semaphore.signal()
                                        CurVal.append(String(compPrevClose))
                                        
                                    }
                                    semaphore.signal()
                                }
                                else{
                                    //this is where the function goes when the ticket is not an actual stock symbol aka url no good
                                    print("still no good")
                                       CurVal.append("NOT A STOCK SYMBOL");
                                        print("NOT A STOCK SYMBOL ")
                                   
                                } 
                            }
                            else{
                                print("the NSDictionary did not work ")
                            }
                        } else {
                            CurVal.append("Stock Doesn't exist please check the spelling")
                        }
                        semaphore.signal()
                        
                    }
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
