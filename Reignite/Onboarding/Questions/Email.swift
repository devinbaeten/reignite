//
//  Email.swift
//  Reignite
//
//  Created by Devin Baeten on 7/4/22.
//

import Foundation
import UIKit
import SwiftUI

class ObEmail: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init Validation
        toggleButton(enabled: false)
        textBox.addTarget(self, action: #selector(validateInput(_:)), for: UIControl.Event.editingChanged)
        
        // Styles
        textBox.layer.cornerRadius = 15
        textBox.paddingLeft(inset: 15)
        
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: -1, height: 5)
        button.layer.shadowRadius = 10
        
        // Call text box
        textBox.becomeFirstResponder()
    }
    
    @IBOutlet weak var textBox: UITextField!
    @IBOutlet weak var button: UIButton!

    
    @objc func validateInput(_ textField: UITextField) {
        
        toggleButton(enabled: true)
        guard let text = textBox.text, text != "" else {
            toggleButton(enabled: false)
            return
        }
        
        if textBox.text != "" {
            UserDefaults.standard.set(text, forKey: "userEmail")
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        let isValid = emailPred.evaluate(with: textBox.text)
        
        if isValid {
            // Cont.
        } else {
            toggleButton(enabled: false)
        }
        
    }
    
    func toggleButton(enabled: Bool) {
        if enabled {
            button.isEnabled = true
            button.layer.opacity = 1
        } else {
            button.isEnabled = false
            button.layer.opacity = 0.25
        }
    }
    
}
