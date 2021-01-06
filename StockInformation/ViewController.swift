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
    
    var stockSymbols = [String]() //an array which contains all of our stocks symbols which are in our table
    let debugmodeFlag: Bool = true     //allows to togle getting real api requests
    
    
    override func viewDidLoad() {//additional setup after the view loads
        super.viewDidLoad()
        self.title = "Stocks"
        tableView.delegate = self
        tableView.dataSource = self
        if !UserDefaults().bool(forKey: "setup"){
            UserDefaults().set(true, forKey: "setup")
            UserDefaults().set(0, forKey: "count")
        }
        self.UpdateStocks()
        //self.MasterReset() //only used when wanting to erase all data on the phone
    }
    
    func MasterReset(){//resets all stocks and count to act a new user
        let defaults = UserDefaults.standard
        deleteStocks()
        defaults.setValue(0,forKey: "count");
    }
    
    func deleteStocks(){//deletes all stocks
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
    func UpdateStocks(){//updates stocks on tableview
        stockSymbols.removeAll()
        let defaults = UserDefaults.standard
        guard let count = defaults.value(forKey: "count") as? Int else{
            return
        }
        for x in 0..<count{
            if let stock = defaults.value(forKey: "stock_\(x+1)") as? String{
                stockSymbols.append(stock)
            }
        }
        tableView.reloadData()
        
    }
    @IBAction func refreshPortfolioStocks(){//refreshes the cost of each stock for current time
        self.UpdateStocks()
    }
    @IBAction func didTouchApp(){//When the ADD button is pressed the screen will turn into a new screen for entry of stock symbols
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
extension ViewController: UITableViewDelegate{//inisializes the stock view controller
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = storyboard?.instantiateViewController(identifier: "StockSymbol") as! StockViewController
        vc.title = "Stock Information"
        vc.stockSym = stockSymbols[indexPath.row]
        vc.curPos = indexPath.row as Int
        vc.CurPrice = self.GetStockValueforStockSym(stockSymbolTemp: vc.stockSym)
        vc.update = {
            DispatchQueue.main.async {
                self.UpdateStocks()
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
class MyCell: UITableViewCell {//creates a custom class which will allow for multiple labels
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
}
extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stockSymbols.count;
    }
    //setting the stock Symbol and Stock Price in table viewer
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProtoCell", for : indexPath) as! MyCell
        cell.label1?.text = stockSymbols[indexPath.row]
        cell.label2?.text = String(GetStockValueforStockSym(stockSymbolTemp: cell.label1?.text ??  "BTC" ))
        return cell;
    }
    
    func GetStockValueforStockSym(stockSymbolTemp :String) -> Double//change the variable name after
    {
        if(debugmodeFlag){//used to create random values for stocks which will save calls for debugging
            let x = Double.random(in: 5.0...1000.0)
            return Double(round(x*100)/100)
        }
        var CurVal: Double = -6.2// inisialize the return variable
        
        let headers = [
            "x-rapidapi-host": "yahoo-finance-low-latency.p.rapidapi.com",
            "x-rapidapi-key": "1529265bf5mshfd12832f51f908dp16ebb4jsne36b181d2338", // Henoks Key
            //"x-rapidapi-key": "136911ffb3msh69c6efb713e8d01p16ecf6jsnb0202d799a9f", //Bryans Key
            
        ]
        let beginningURLString = "https://yahoo-finance-low-latency.p.rapidapi.com/v8/finance/chart/"
        let stockToken = stockSymbolTemp
        let EndURL =  "?interval=1m&range=1d"
        let realURL = beginningURLString + stockToken + EndURL
        let request = NSMutableURLRequest(url: NSURL(string: realURL)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20.0)
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
                                        CurVal = cpv
                                        semaphore.signal()
                                    }
                                }
                            }
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

        var CurVal: [String] = []//inisialize the return value
        
        let headers = [
            "x-rapidapi-host": "yahoo-finance-low-latency.p.rapidapi.com",
            "x-rapidapi-key": "1529265bf5mshfd12832f51f908dp16ebb4jsne36b181d2338", // Henoks Key
            //"x-rapidapi-key": "136911ffb3msh69c6efb713e8d01p16ecf6jsnb0202d799a9f", //Bryans Key
        ]
        let beginningURLString = "https://yahoo-finance-low-latency.p.rapidapi.com/v6/finance/quote?symbols=";
        let stockToken = stockSymbolTemp
        let realURL = beginningURLString + stockToken
        let request = NSMutableURLRequest(url: NSURL(string: realURL)! as URL, cachePolicy: .useProtocolCachePolicy,timeoutInterval: 20.0)
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
                                        CurVal.append(String(compName))
                                    } else {
                                        CurVal.append("NOT A STOCK SYMBOL");
                                    }
                                    
                                    if let compCurrency = results[0]["currency"] as? String{
                                        CurVal.append(compCurrency)
                                    }
                                    if let comp52high = results[0]["fiftyTwoWeekHigh"] as? Double{
                                        CurVal.append(String(comp52high))
                                    }
                                    if let comp52low = results[0]["fiftyTwoWeekLow"] as? Double{
                                        CurVal.append(String(comp52low))
                                    }
                                    if let compDayhigh = results[0]["regularMarketDayHigh"] as? Double{
                                        CurVal.append(String(compDayhigh))
                                    }
                                    if let compDaylow = results[0]["regularMarketDayLow"] as? Double{
                                        CurVal.append(String(compDaylow))
                                    }
                                    if let compPrevClose = results[0]["regularMarketPreviousClose"] as? Double{
                                        CurVal.append(String(compPrevClose))
                                    }
                                    semaphore.signal()
                                }
                                else{
                                       CurVal.append("NOT A STOCK SYMBOL");
                                } 
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
