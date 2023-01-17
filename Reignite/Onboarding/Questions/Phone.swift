//
//  Phone.swift
//  Reignite
//
//  Created by Devin Baeten on 7/4/22.
//

import Foundation
import UIKit
import SwiftUI
import PhoneNumberKit

class ObPhone: UIViewController {
    
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
    
    @IBOutlet weak var textBox: PhoneNumberTextField!
    @IBOutlet weak var button: UIButton!

    
    @objc func validateInput(_ textField: UITextField) {
        
        toggleButton(enabled: true)
        guard let text = textBox.text, text != "" else {
            toggleButton(enabled: false)
            return
        }
        
        if textBox.text != "" {
            UserDefaults.standard.set(text, forKey: "userPhone")
        }
        
//        let phoneRegex = "^\\d{3}\\d{3}\\d{4}$"
//        let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        
        let isValid = true
        
        if isValid {
            // Cont.
            guard let text = textBox.text else { return }
            textField.text = text.applyPatternOnNumbers(pattern: "+# (###) ###-####", replacementCharacter: "#")
        } else {
            //toggleButton(enabled: false)
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

extension String {
    func applyPatternOnNumbers(pattern: String, replacementCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(utf16Offset: index, in: pattern)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacementCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
}
