//
//  StockViewController.swift
//  StockInformation
//
//  Created by Bryan Sullivan and Henok Ketsela on 12/18/20.
//

import UIKit

class StockViewController: UIViewController {
    
    @IBOutlet var label: UILabel!
    
    var stockSym: String?
    var curPos: Int?
    var update :(() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        label.text = stockSym
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(DeleteStock))
    }
    
    
    @objc func DeleteStock(){
        
        let defaults = UserDefaults.standard
        guard let count = defaults.value(forKey: "count") as? Int else{
            return
        }
        
        let newcount = count - 1;
        
       
        print(curPos!)
        
        defaults.setValue(newcount,forKey: "count");
        
        defaults.setValue(nil,forKey: "stock_\(curPos!)");//now i am going to have to shift the rest of the stocks up so that we do not have a gap
        for x in curPos!..<count{
            defaults.setValue(defaults.value(forKey:"stock_\(x+1)"),forKey: "stock_\(x)")
        }
        update?();
        navigationController?.popViewController(animated: true)
        
    }
    

    

}
