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
    
    
    override func viewDidLoad() {
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
        let count = defaults.value(forKey: "count") as? Int as Any
        //print("the count is \(count!)")
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
        
        self.GetStockValueforStockSym(stockSymbolTemp: stockSymbols[indexPath.row], VC: vc)
        vc.title = "Stock Information"
        vc.stockSym = stockSymbols[indexPath.row]
        vc.curPos = indexPath.row as Int
        vc.CurPrice = currentPriceView
        vc.update = {
            DispatchQueue.main.async {
                self.UpdateStocks()
            }
            
        }
        
        vc.UpdateLabel = {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7){
                vc.label.text = ("The current stock price for " + vc.stockSym + " is $" + String(self.currentPriceView)) //fix needed due to not fitting in the label possible fix is resizeing in main storyboard
                // vc.label.text = (vc.stockSym + " " + String(self.currentPriceView))
                print("curprice is currently \(self.currentPriceView)")
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
            "x-rapidapi-key": "136911ffb3msh69c6efb713e8d01p16ecf6jsnb0202d799a9f",
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
        var CurVal: Double = 1.0// has the value of the previous stock
        
        let headers = [
            "x-rapidapi-key": "136911ffb3msh69c6efb713e8d01p16ecf6jsnb0202d799a9f",
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
 
    
    
}
