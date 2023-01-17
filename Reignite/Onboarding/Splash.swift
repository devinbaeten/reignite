//
//  File.swift
//  Reignite
//
//  Created by Devin Baeten on 4/7/22.
//

import Foundation
import UIKit
import SafariServices

class Splash:UIViewController {
    
    @IBOutlet weak var button:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: -1, height: 5)
        button.layer.shadowRadius = 10
    }
    
    @IBAction func explain() {
        guard let url = URL(string: "https://reignite.dbapps.dev/app-cgi/settings/how-it-works") else { return }
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }
    
}
