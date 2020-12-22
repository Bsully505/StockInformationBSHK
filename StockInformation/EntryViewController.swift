//
//  EntryViewController.swift
//  StockInformation
//
//  Created by Bryan Sullivan and Henok Ketsela on 12/18/20.
//

import UIKit

class EntryViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var field: UITextField! //This is the way the user inputs the added stock symbol
   
    var update :(() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        field.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(SaveStock))
        // Do any additional setup after loading the view.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //this is where we can add a check for User input which would allow us to call the current string in the text field and then place some data into a label underneath the textbox with the company name not the symbol 
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
        let newcount = count+1;
        
        UserDefaults().setValue(newcount, forKey: "count")
        UserDefaults().setValue(StockSym, forKey:"stock_\(newcount)")
        
        update?()
        navigationController?.popViewController(animated: true)
        
    }
    

}
