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
        
        print(defaults.value(forKey: "count") as? Int)
        // Do any additional setup after loading the view.
    }
    func UpdateStocks(){
        stockSymbols.removeAll()
        guard let count = UserDefaults.value(forKey: "count") as? Int else{
            return
        }
        for x in 0..<count{
            if let stock = UserDefaults.value(forKey: "Stock_\(x+1)") as? String{
                stockSymbols.append(stock)
            }
        }
        tableView.reloadData()
    }
    @IBAction func didTouchApp(){
        let vc = storyboard?.instantiateViewController(identifier: "Entry") as! EntryViewController
        vc.title = "new Stock"
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
    
}
