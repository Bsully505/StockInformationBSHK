//
//  StockViewController.swift
//  StockInformation
//
//  Created by Bryan Sullivan and Henok Ketsela on 12/18/20.
//

import UIKit

class StockViewController: UIViewController {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var CounterLabel: UILabel!
    @IBOutlet var StockCounter: UIStepper!
    
    var stockSym: String!
    var curPos: Int?
    var update :(() -> Void)?
    var CurPrice: Double?
    var UpdateLabel: (() -> Void)?
    var currStockAmt: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("the stock Symbol is \(stockSym!)")
        let labelOutput = ("The current stock price for " + stockSym + " is $" + String(CurPrice!))
        label.text = labelOutput
        StockCounter.value = UserDefaults().value(forKey: "\(stockSym!.uppercased())_Count") as! Double
        currStockAmt = StockCounter.value//I am possibly using to many variables on these three lines above might have to remove some
        CounterLabel.text = "You own \(currStockAmt ?? 0.0) of shares press the plus to buy more and minus to sell"
        //UpdateLabel?()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(DeleteStock))
    }
    
    
    @objc func DeleteStock(){
        
        let defaults = UserDefaults.standard
        guard let count = defaults.value(forKey: "count") as? Int else{
            return
        }        
        let newcount = count - 1;
        defaults.setValue(newcount,forKey: "count");
        let temp = defaults.value(forKey: "stock_\(curPos!+1)")
        defaults.setValue(0.0,forKey: "\(temp)_Count")
        defaults.setValue(nil,forKey: "stock_\(curPos!+1)");
        
        for x in curPos!+1..<count{
            defaults.setValue(defaults.value(forKey:"stock_\(x+1)"),forKey: "stock_\(x)")
            
        }
        update?();
        navigationController?.popViewController(animated: true)
        
    }
   
    @IBAction func removeStockAmt(){//bad naming convension we should name Change stock Amt
        if StockCounter.value >= 0{
            currStockAmt = StockCounter.value
            let temp = UserDefaults().value(forKey: "stock_\(curPos!+1)")
            UserDefaults().setValue(currStockAmt,forKey: "\(temp)_Count")
            print(currStockAmt!)
        }
        CounterLabel.text = "You own \(currStockAmt ?? 0.0) of shares press the plus to buy more and minus to sell"
        
    }
    
    
    
    // ideal data storage for users[bryan sullivan,800,[acb,7,08.36][tesla,2,146.28]]
    

}
