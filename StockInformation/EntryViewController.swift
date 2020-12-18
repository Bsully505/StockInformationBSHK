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
        SaveStock()
        return true
    }

    @objc func SaveStock(){
        guard let text = field.text, !text.isEmpty else{
            return
        }
        guard let count = UserDefaults().value(forKey: "count") as? Int else{
            return
        }
        let newcount = count+1;
        
        UserDefaults().setValue(newcount, forKey: "count")
        UserDefaults().setValue(text, forKey:"stock_\(newcount)")
        
        update?()
        navigationController?.popViewController(animated: true)
        
    }
    

}
