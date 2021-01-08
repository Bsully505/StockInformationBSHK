//
//  StockViewController.swift
//  StockInformation
//
//  Created by Bryan Sullivan and Henok Ketsela on 12/18/20.
//
import Charts
import UIKit

class StockViewController: UIViewController, ChartViewDelegate {
    
    var LineChart = LineChartView()
    
    @IBOutlet var label: UILabel!
    @IBOutlet var CounterLabel: UILabel!
    @IBOutlet var StockCounter: UIStepper!
    @IBOutlet var ChangeStockAmt: UITextField!
    @IBOutlet var AVGReturn: UILabel!
    
    
    var stockSym: String!
    var curPos: Int?
    var update :(() -> Void)?
    var CurPrice: Double?
    var currStockAmt: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("the stock Symbol is \(stockSym!)")
        label.text = ("The current stock price for " + stockSym + " is $" + String(format:"%.2f" ,CurPrice!))
        StockCounter.value = UserDefaults().value(forKey: "\(stockSym!.uppercased())_Count") as! Double
        print("the value for stockSymCount is \(UserDefaults().value(forKey: "\(stockSym!.uppercased())_Count") as! Double)")
        currStockAmt = StockCounter.value//I am possibly using to many variables on these three lines above might have to remove some
        CounterLabel.text = "You own \(currStockAmt ?? 0.0) shares press the plus to buy or minus to sell"
        LineChart.delegate = self
        self.ShowNewTotalReturn()
        
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
   
    @IBAction func StepperValueChange(){//function for changing stock amount using the stepper
        if StockCounter.value >= 0{
            let oldStockAmt = currStockAmt
            currStockAmt = StockCounter.value
            UserDefaults().setValue(currStockAmt,forKey: "\(stockSym!)_Count")
            print(currStockAmt!)
            if oldStockAmt! < currStockAmt!{
                let oldAMT = oldStockAmt! * (UserDefaults().value(forKey: "\(stockSym!)_AvgPrice") as! Double)
            let NewAmt = (currStockAmt - oldStockAmt!) * (CurPrice!)
            var NewAVG = (oldAMT + NewAmt) / currStockAmt
            NewAVG = Double(round(NewAVG * 100)/100)
            UserDefaults().setValue(NewAVG ,forKey: "\(stockSym!)_AvgPrice")
            }
            ShowNewTotalReturn()
            
        }
        CounterLabel.text = "You own \(currStockAmt ?? 0.0) shares press the plus to buy or minus to sell"
        
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
                ShowNewTotalReturn()
            }
            else{
                // create this into a function possibly
                let oldAMT = temp! * (UserDefaults().value(forKey: "\(stockSym!)_AvgPrice") as! Double)
                let NewAmt = amount * (CurPrice!)
                var NewAVG = (oldAMT + NewAmt) / currStockAmt
                NewAVG = Double(round(NewAVG*100)/100)
                UserDefaults().setValue(NewAVG ,forKey: "\(stockSym!)_AvgPrice")
                ShowNewTotalReturn()
                print("the new AVG is \(NewAVG)")
                
            }
            CounterLabel.text = "You own \(currStockAmt ?? 0.0) shares press the plus to buy or minus to sell"
            
        }
        else{//happens if the user enters not a double
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
            ShowNewTotalReturn()
            CounterLabel.text = "You own \(currStockAmt ?? 0.0) shares press the plus to buy or minus to sell"
                
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
    
    func ShowNewTotalReturn(){
        let AvgP = UserDefaults().value(forKey: "\(stockSym!)_AvgPrice") as! Double
        var totalReturn = (CurPrice! - AvgP) * currStockAmt
        totalReturn = Double(round(totalReturn*100)/100)
        
        AVGReturn.text = "Your average stock price is \(String(format: "%.2f" ,AvgP))\n Your total return is \(String(format: "%.2f",totalReturn))"
    }

    override func viewDidLayoutSubviews() {//this is updated everytime i reclick on a stock
        super.viewDidLayoutSubviews()
        
        LineChart.frame = CGRect(x: 0, y: -400, width: 400, height: 275)
        LineChart.center = CGPoint(x: 200, y: 650)
        view.addSubview(LineChart)
        
        var entries = [ChartDataEntry]()
        
        for x in 0..<10 {
            //should get data from api call and put data in the y values
            
            entries.append(ChartDataEntry(x: Double(x), y: Double.random(in: 0...20)))
        }
        let set = LineChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.joyful()
        LineChart.backgroundColor = UIColor.white
        
        let data = LineChartData(dataSet: set)
        LineChart.data = data
    }
}
