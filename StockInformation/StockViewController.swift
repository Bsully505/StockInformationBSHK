//
//  StockViewController.swift
//  StockInformation
//
//  Created by Bryan Sullivan and Henok Ketsela on 12/18/20.
//

import UIKit

class StockViewController: UIViewController {
    
    @IBOutlet var label: UILabel!
    
    var stockSym: String!
    var curPos: Int?
    var update :(() -> Void)?
    var CurPrice: Double?
    var UpdateLabel: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("the stock Symbol is \(stockSym!)")
        let labelOutput = ("The current stock price for " + stockSym + " is $" + String(CurPrice!))
        label.text = labelOutput
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
        defaults.setValue(nil,forKey: "stock_\(curPos!+1)");
        for x in curPos!+1..<count{
            defaults.setValue(defaults.value(forKey:"stock_\(x+1)"),forKey: "stock_\(x)")
        }
        update?();
        navigationController?.popViewController(animated: true)
        
    }
   
    
    
    

    

}
