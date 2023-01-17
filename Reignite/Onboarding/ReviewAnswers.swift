//
//  ReviewAnswers.swift
//  Reignite
//
//  Created by Devin Baeten on 4/7/22.
//

import Foundation
import UIKit

class ReviewAnswers: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tableView.clipsToBounds = false
//        self.tableView.layer.masksToBounds = false
    }
    
    let fields = ["Email","Username","Phone Number"]
    let stored = ["userEmail","userUsername","userPhone"]
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 45
        } else {
            return UITableView.automaticDimension
        }
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 50
        }
    }

    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Your Snapchat Account"
        } else {
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return ""
        } else {
            return "It is important that the details above are accurate. If anything above is invalid, your requests will always fail. You can go back and change your answers if neccesary, otherwise press confirm."
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return fields.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let field = indexPath.item
            let key = fields[field]
            let value = UserDefaults.standard.string(forKey: stored[field])
            let cell = tableView.dequeueReusableCell(withIdentifier: "fieldCell")
            cell?.textLabel?.text = key
            cell?.detailTextLabel?.text = value
            cell?.layer.shadowColor = UIColor.black.cgColor
            cell?.layer.shadowOpacity = 0.25
            cell?.layer.shadowOffset = CGSize(width: -1, height: 5)
            cell?.layer.shadowRadius = 10
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "continue")
            cell?.layer.cornerRadius = 20
            cell?.layer.shadowColor = UIColor.black.cgColor
            cell?.layer.shadowOpacity = 0.25
            cell?.layer.shadowOffset = CGSize(width: -1, height: 5)
            cell?.layer.shadowRadius = 10
            return cell!
        }
    }
    
    struct userSCDetails: Codable {
        let email: String
        let username: String
        let phone: String
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            
            print("Onboarding Complete")
            
            guard let email = UserDefaults.standard.string(forKey: "userEmail") else { return }
            guard let username = UserDefaults.standard.string(forKey: "userUsername") else { return }
            guard let phone = UserDefaults.standard.string(forKey: "userPhone") else { return }
            
            let data = userSCDetails(email: email, username: username, phone: phone)
            
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(data) {
                let defaults = UserDefaults.standard
                defaults.set(encoded, forKey: "userSCDetails")
            }
            
            UserDefaults.standard.set(true, forKey: "onboardingV1Complete")
            UserDefaults.standard.set(true, forKey: "needsIntro")
            
            let window = (UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate).window
            let storyboard = UIStoryboard(name: "Main", bundle:nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "MainNC") as! MainNavigationController
            window?.rootViewController = vc
            window?.makeKeyAndVisible()
            
        }
    }
    
}
