//
//  SettingsTVC.swift
//  Reignite
//
//  Created by Devin Baeten on 7/5/22.
//

import Foundation
import UIKit
import SafariServices
import MessageUI

class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    var data = ReviewAnswers.userSCDetails.init(email: "", username: "", phone: "") // Default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        injectVersionString()
        
        let defaults = UserDefaults.standard
        
        if let userSCDetails = defaults.object(forKey: "userSCDetails") as? Data {
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode(ReviewAnswers.userSCDetails.self, from: userSCDetails) {
                data = loadedData
            }
        }
    }
    
    
    func reset() {
        
        // create the alert
        let alert = UIAlertController(title: "Are you sure?", message: "Your request history and account information will be permanently deleted. This information cannot be recovered.", preferredStyle: UIAlertController.Style.alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Reset", style: UIAlertAction.Style.destructive, handler: {_ in
        
            UserDefaults.standard.removeObject(forKey: "history")
            UserDefaults.standard.removeObject(forKey: "userSCDetails")
            UserDefaults.standard.set(false, forKey: "onboardingV1Complete")
            
            UserDefaults.standard.synchronize()
            
            let window = (UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate).window
            let storyboard = UIStoryboard(name: "Main", bundle:nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "setupFlow") as! UINavigationController
            window?.rootViewController = vc
            window?.makeKeyAndVisible()
            
        }))

        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 45
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Your Snapchat Account"
        } else if section == 1 {
            return "Resources"
        } else if section == 2 {
            return ""
        } else {
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "If you need to change any of the information above, you'll need to reset the app."
        } else if section == 1 {
            return ""
        } else if section == 2 {
            return ""
        } else {
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if section == 1 {
            return 3
        } else if section == 2 {
            return 1
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userSCDetail")
            if indexPath.row == 0 {
                cell?.textLabel?.text = "Email"
                cell?.detailTextLabel?.text = data.email
            } else if indexPath.row == 1 {
                cell?.textLabel?.text = "Username"
                cell?.detailTextLabel?.text = data.username
            } else {
                cell?.textLabel?.text = "Phone"
                cell?.detailTextLabel?.text = data.phone
            }
            return cell!
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "explainer")
                return cell!
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "help")
                return cell!
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "contact")
                return cell!
            }
            
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "donate")
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reset")
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                guard let url = URL(string: "https://reignite.dbapps.dev/app-cgi/settings/how-it-works") else { return }
                let svc = SFSafariViewController(url: url)
                present(svc, animated: true, completion: nil)
            } else if indexPath.row == 1 {
                guard let url = URL(string: "https://reignite.dbapps.dev/app-cgi/settings/faqs") else { return }
                let svc = SFSafariViewController(url: url)
                present(svc, animated: true, completion: nil)
            } else {
                func sendEmail() {
                    if MFMailComposeViewController.canSendMail() {
                        let mail = MFMailComposeViewController()
                        mail.mailComposeDelegate = self
                        mail.setToRecipients(["devin@devinbaeten.com"])
                        mail.setMessageBody("<p>Contacting in regards to the Reignite app</p><br/></br>", isHTML: true)

                        present(mail, animated: true)
                    } else {
                        // show failure alert
                    }
                }

                func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
                    controller.dismiss(animated: true)
                }
                
                sendEmail()
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        if indexPath.section == 3 {
            reset()
        }
    }
    
    @IBOutlet weak var footerString: UILabel!
    
    func injectVersionString() {
        
        let hc = footerString.text
        
        let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        
        var beta = ""
        
        if isTestFlight {
            beta = " Beta"
        }
        
        let pass1 = hc?.replacingOccurrences(of: "{{version}}", with: "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"))\(beta)")
        
        let pass2 = pass1?.replacingOccurrences(of: "[LB]", with: "\n")
        
        footerString.text = pass2
        
    }
    
}
