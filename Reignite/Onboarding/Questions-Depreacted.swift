//
//  Questions.swift
//  Reignite
//
//  Created by Devin Baeten on 4/7/22.
//

import Foundation
import UIKit
import SwiftUI

class Questions:UIViewController {
    
    @IBOutlet weak var button:UIButton!
    
    @IBOutlet weak var demand:UILabel!
    @IBOutlet weak var desc:UILabel!
    
    @IBOutlet weak var textBox:UITextField!
    
    var ps1:Bool = true // Email
    var ps2:Bool = true // Username
    var ps3:Bool = true // Phone
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textBox.layer.cornerRadius = 15
        textBox.paddingLeft(inset: 15)
        
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: -1, height: 5)
        button.layer.shadowRadius = 10
        
        // Reset
        disableButton()
        
        // Begin Sequence
        presentStepOne()
        
    }
    
    // Reusable UI
    
    func configureUI(with demand:String, with desc:String, with placeholder:String) {
        
        self.demand.text = demand
        self.desc.text = desc
        self.textBox.placeholder = placeholder
        
    }
    
    func disableButton() {
        self.button.isEnabled = false
        self.button.backgroundColor = UIColor.systemGray5
    }
    func enableButton() {
        self.button.isEnabled = true
        self.button.backgroundColor = UIColor.init(named: "scCyan")
    }
    func resetFields() {
        self.textBox.text = ""
    }
    
    // UI Actions
    
    @IBAction func clickedNext() {
        
        disableButton()
        self.textBox.resignFirstResponder()
        
        if ps1 {
            self.presentStepTwo()
            self.ps1 = false
        }
        else {
            if ps2 {
                self.presentStepThree()
                self.ps2 = false
            }
            else {
                if ps3 {
                    self.presentStepFour()
                    self.ps3 = false
                }
                else {
                    // Exit
                }
            }
        }
        
    }
    
    // Presentables
    
    func presentStepOne() {
        
        resetFields()
        
        configureUI(with: "Enter your Email", with: "This needs to be the one you use with your Snapchat account", with: "example@mail.com")
        
        self.textBox.becomeFirstResponder()
        self.enableButton()
        
    }
    
    func presentStepTwo() {
        
        resetFields()
        
        configureUI(with: "Enter your Username", with: "This needs to be the one associated with your Snapchat account", with: "teamsnapchat")
        
        self.textBox.becomeFirstResponder()
        self.enableButton()
        
    }
    
    func presentStepThree() {
        
        resetFields()
        
        configureUI(with: "Enter your Phone Number", with: "This needs to be the one associated with your Snapchat account", with: "1234567890")
        
        self.textBox.becomeFirstResponder()
        self.enableButton()
        
    }
    
    func presentStepFour() {
        
        resetFields()
        
        configureUI(with: "", with: "", with: "")
        
        // EXIT
        self.performSegue(withIdentifier: "reviewSetupAnswers", sender: self)
        
    }
    
}

extension UITextField {
    func paddingLeft(inset: CGFloat){
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: inset, height: self.frame.height))
        self.leftViewMode = UITextField.ViewMode.always
    }
}
