//
//  Segues.swift
//  Reignite
//
//  Created by Devin Baeten on 7/6/22.
//

import Foundation
import UIKit

class IntroductionVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        
        // Styles
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: -1, height: 5)
        button.layer.shadowRadius = 10
        
    }
    
    @IBOutlet weak var button: UIButton!
    
    @IBAction func close() {
        self.dismiss(animated: true)
    }
}
