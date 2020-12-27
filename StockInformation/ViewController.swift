//
//  ViewController.swift
//  StockInformation
//
//  Created by Bryan Sullivan and Henok Ketsela on 12/15/20.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var stockSymbols = [String]()
    
    
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
            if let _ = defaults.setValue(nil, forKey: "stock_\(x+1)") as? String{
                //print("at position \(x) we have \(stock)")
                //stockSymbols.append(stock)
            }
        }
        tableView.reloadData()
    }
    func UpdateStocks(){
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
        vc.title = "Stock Information"
        vc.stockSym = stockSymbols[indexPath.row]
        vc.curPos = indexPath.row as Int
        vc.CurPrice = GetStockValueforStockSym(stockSymbolTemp: vc.stockSym!)
        vc.update = {
            DispatchQueue.main.async {
                self.UpdateStocks()
            }
            
        }
        navigationController?.pushViewController(vc, animated: true)
        
    }
}

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stockSymbols.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProtoCell", for : indexPath)
        
        cell.textLabel?.text = stockSymbols[indexPath.row]
        return cell;
    }
    func GetStockValueforStockSym(stockSymbolTemp :String ) -> Double//change the variable name after
    {
        var CurVal: Double = 1.0 // Double = 1.0// it is returning 1.0 not the changed value
        
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
                                    CurVal = (meta["regularMarketPrice"]! as! Double)
                                    print("The curVal value is changed to \(CurVal)")
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
        return CurVal
       
    }
    
    
}
