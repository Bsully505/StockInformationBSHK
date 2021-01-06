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
    @IBOutlet var ChangeStockAmt: UITextField!
    @IBOutlet var AVGReturn: UILabel!
    
    
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
        print("the value for stockSymCount is \(UserDefaults().value(forKey: "\(stockSym!.uppercased())_Count") as! Double)")
        print("the stock counter value is \(StockCounter.value)")
        currStockAmt = StockCounter.value//I am possibly using to many variables on these three lines above might have to remove some
        CounterLabel.text = "You own \(currStockAmt ?? 0.0) of shares press the plus to buy more and minus to sell"
        let AvgP = UserDefaults().value(forKey: "\(stockSym!)_AvgPrice") as! Double
        let totalReturn = (CurPrice! - AvgP) * currStockAmt
        AVGReturn.text = "Your average stock price is \(UserDefaults().value(forKey: "\(stockSym!)_AvgPrice")!)\n Your total return is \(totalReturn)"
        
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
        defaults.setValue(0.0,forKey: "\(temp!)_Count")
        defaults.setValue(nil,forKey: "stock_\(curPos!+1)");
        defaults.setValue(0.0, forKey: "\(temp!)_AvgPrice")
        for x in curPos!+1..<count{
            defaults.setValue(defaults.value(forKey:"stock_\(x+1)"),forKey: "stock_\(x)")
            
        }
        update?();
        navigationController?.popViewController(animated: true)
        
    }
   
    @IBAction func removeStockAmt(){//bad naming convension we should name Change stock Amt
        if StockCounter.value >= 0{
            let oldStockAmt = currStockAmt
            currStockAmt = StockCounter.value
            let temp = UserDefaults().value(forKey: "stock_\(curPos!+1)")
            //instead of using temp i can possibly use StockSym!
            UserDefaults().setValue(currStockAmt,forKey: "\(temp!)_Count")
            print(currStockAmt!)
            if oldStockAmt! < currStockAmt!{
                let oldAMT = oldStockAmt! * (UserDefaults().value(forKey: "\(stockSym!)_AvgPrice") as! Double)
            let NewAmt = (currStockAmt - oldStockAmt!) * (CurPrice!)
            let NewAVG = (oldAMT + NewAmt) / currStockAmt
            UserDefaults().setValue(NewAVG ,forKey: "\(stockSym!)_AvgPrice")
            let totalReturn = (CurPrice! - NewAVG) * CurPrice!
            
            
            AVGReturn.text = "Your average stock price is \(UserDefaults().value(forKey: "\(stockSym!)_AvgPrice")!)\n Your total return is \(totalReturn)"
                
            print("the new AVG is \(NewAVG)")
            }
            
        }
        CounterLabel.text = "You own \(currStockAmt ?? 0.0) of shares press the plus to buy more and minus to sell"
        
    }
    
    @IBAction func BuyStock(){
        self.view.endEditing(true)
        if let amount = Double(ChangeStockAmt.text!){
            //possibly test if user has current amount of cash > amount * curprice 
            let temp = currStockAmt
            currStockAmt = currStockAmt + amount
            UserDefaults().setValue(currStockAmt ,forKey: "\(stockSym!)_Count")
            StockCounter.value = UserDefaults().value(forKey: "\(stockSym!)_Count") as! Double
            
            
            if  UserDefaults().value(forKey: "\(stockSym!)_AvgPrice") as! Double == 0.0 {
            UserDefaults().setValue(CurPrice ,forKey: "\(stockSym!)_AvgPrice")
                AVGReturn.text = "Your average stock price is \(UserDefaults().value(forKey: "\(stockSym!)_AvgPrice")!)"
            }
            else{
                // create this into a function possibly
                let oldAMT = temp! * (UserDefaults().value(forKey: "\(stockSym!)_AvgPrice") as! Double)
                let NewAmt = amount * (CurPrice!)
                let NewAVG = (oldAMT + NewAmt) / currStockAmt
                UserDefaults().setValue(NewAVG ,forKey: "\(stockSym!)_AvgPrice")
                AVGReturn.text = "Your average stock price is \(UserDefaults().value(forKey: "\(stockSym!)_AvgPrice")!)"
                print("the new AVG is \(NewAVG)")
                
            }
            CounterLabel.text = "You own \(currStockAmt ?? 0.0) of shares press the plus to buy more and minus to sell"
            
        }
        else{
            print("we have a problem")
        }
    }
    
    @IBAction func SellStock(){
        self.view.endEditing(true)
        if let amount = Double(ChangeStockAmt.text!){
            //know we know that the person had entered the right amount and we can also possibly add a if statement to see if the person has enouph money to buy this amount
            let temp = currStockAmt - amount
            if temp >= 0 {
                if temp == 0.0{
                    UserDefaults().setValue(0.0 ,forKey: "\(stockSym!)_AvgPrice")
                    AVGReturn.text = "Your average stock price is \(UserDefaults().value(forKey: "\(stockSym!)_AvgPrice")!)"
                }
                
            currStockAmt = temp 
            UserDefaults().setValue(currStockAmt ,forKey: "\(stockSym!)_Count")
            StockCounter.value = UserDefaults().value(forKey: "\(stockSym!)_Count") as! Double
            CounterLabel.text = "You own \(currStockAmt ?? 0.0) of shares press the plus to buy more and minus to sell"
                
            }
        }
        else{
            print("we have a problem")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    // ideal data storage for users[bryan sullivan,800,[acb,7,08.36][tesla,2,146.28]]
    //

}
