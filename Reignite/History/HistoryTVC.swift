//
//  HistoryTVC.swift
//  Reignite
//
//  Created by Devin Baeten on 7/5/22.
//

import Foundation
import UIKit
import SwiftUI

class HistoryTableViewController: UITableViewController {
    
    var events = ViewController.history.init(event: [ViewController.hEntry.init(username: "", timestamp: Date())]) // Default
    
    @IBOutlet weak var deleteBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        setupDeleteBtn()
        
    }
    
    func loadData() {
        
        let defaults = UserDefaults.standard
        
        if let userHistory = defaults.object(forKey: "history") as? Data {
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode(ViewController.history.self, from: userHistory) {
                events = loadedData
                events.event = events.event.sorted(by: { $0.timestamp.compare($1.timestamp) == .orderedDescending })
                tableView.reloadData()
                self.setupDeleteBtn()
            }
        } else {
            events = ViewController.history.init(event: [])
        }
        
    }
    
    func setupDeleteBtn() {
        if events.event.count > 0 {
            self.deleteBtn.isEnabled = true
        } else {
            self.deleteBtn.isEnabled = false
        }
    }
    
    @IBAction func deleteHistory() {
        
        // create the alert
        let alert = UIAlertController(title: "Are you sure?", message: "This data cannot be recovered once it has been deleted.", preferredStyle: UIAlertController.Style.alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Clear History", style: UIAlertAction.Style.destructive, handler: {_ in
        
            UserDefaults.standard.removeObject(forKey: "history")
            UserDefaults.standard.synchronize()
            
            self.loadData()
            self.tableView.reloadData()
            self.setupDeleteBtn()
            
        }))

        // show the alert
        self.present(alert, animated: true, completion: nil)
    
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.event.count
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if events.event.count == 0 {
            return "You haven't restored any streaks yet. Every time you successfully submit a request it will be recorded here."
        } else {
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "event")
        let event = events.event[indexPath.row]
        let username = event.username
        let ts = event.timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/YY · h:mm:ss a"
        let tss = dateFormatter.string(from: ts)
        cell?.textLabel?.text = username
        cell?.detailTextLabel?.text = tss
        return cell!
    }
}
