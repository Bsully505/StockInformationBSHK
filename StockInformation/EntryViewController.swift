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
    
    var update :(() -> Void)?
    var stockSym1 =  [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        field.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(SaveStock))
        // Do any additional setup after loading the view.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //this is where we can add a check for User input which would allow us to call the current string in the text field and then place some data into a label underneath the textbox with the company name not the symbol
        print(stockSym1.contains(field.text!))
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
        guard let count = UserDefaults().value(forKey: "count") as? Int else{
            return
        }
        if !stockSym1.contains(field.text!){
            let newcount = count+1;
            UserDefaults().setValue(newcount, forKey: "count")
            UserDefaults().setValue(StockSym, forKey:"stock_\(newcount)")
            update?()
            navigationController?.popViewController(animated: true)
    }
        else{
            //this is where we can code up a label which would include text stating that no duplicate code can be made.
            if label.text == "result" {     // you should probably force everything to lowercase, to avoid wrong test
                      label.text = "Correct"
                } else {
                      label.text = "Please do not include duplicates, \(StockSym) is \n already in your portfolio"
                
                }
            
        }
    

}
   

}
