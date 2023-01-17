//
//  ViewController.swift
//  Reignite
//
//  Created by Devin Baeten on 12/20/21.
//

import UIKit
import WebKit
import SwiftyXMLParser
import Alamofire
import GoogleMobileAds

class ViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate {
    
    var bannerView: GADBannerView!
    
    @IBOutlet weak var adSpace: UIView!
    
    @IBOutlet weak var browserView: WKWebView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var reigniteButton: UIButton!
    
    @IBOutlet weak var bitmojiPreview: UIImageView!
    @IBOutlet weak var bmView: UIView!
    
    @IBOutlet weak var buttonPanel: UIView!
    
    @IBOutlet weak var resetButton: UIBarButtonItem!
    
    var usernameForRestore:String = "NULL"
//    var setup:Bool = UserDefaults.standard.bool(forKey: "UserOnboarded")
    
    var data = ReviewAnswers.userSCDetails.init(email: "", username: "", phone: "") // Default

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-1078692801643345/9923176532"
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        let needsIntro = UserDefaults.standard.bool(forKey: "needsIntro")
        
        if needsIntro {
            presentIntro()
        }
        
        if UserDefaults.standard.value(forKey: "needsIntro") == nil {
            presentIntro()
        }
        
        func presentIntro() {
            UserDefaults.standard.set(false, forKey: "needsIntro")
            self.performSegue(withIdentifier: "intro", sender: self)
        }
        
//        let window = (UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate).window
//                   let storyboard = UIStoryboard(name: "Main", bundle:nil)
//               if setup == false {
//                   let vc = storyboard.instantiateViewController(withIdentifier: "setupFlow") as! UINavigationController
//                   window?.rootViewController = vc
//                   window?.makeKeyAndVisible()
//               } else if setup == true {
//                   let vc = storyboard.instantiateViewController(withIdentifier: "mainFlow") as! UINavigationController
//                   window?.rootViewController = vc
//                   window?.makeKeyAndVisible()
//               }
        
        // Setup User Data
        let defaults = UserDefaults.standard
        
        if let userSCDetails = defaults.object(forKey: "userSCDetails") as? Data {
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode(ReviewAnswers.userSCDetails.self, from: userSCDetails) {
                data = loadedData
            }
        }
        
        resetButton.isEnabled = false
        
        browserView.navigationDelegate = self
        browserBusy()
        
        let url = URL(string: "https://support.snapchat.com/en-US/i-need-help?start=5695496404336640")!
        browserView.load(URLRequest(url: url))
        browserView.allowsBackForwardNavigationGestures = true
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.checkForSuccess()
        })
        
        browserView.layer.opacity = 0
        
        // Init Bitmoji Preview
        usernameField.addTarget(self, action: #selector(fetchBitmoji(_:)), for: UIControl.Event.editingChanged)
        
        // Add btn shadow
        reigniteButton.layer.shadowColor = UIColor.black.cgColor
        reigniteButton.layer.shadowOpacity = 0.20
        reigniteButton.layer.shadowOffset = CGSize(width: -1, height: 3)
        reigniteButton.layer.shadowRadius = 10
        
        // Add uf shadow
        usernameField.layer.shadowColor = UIColor.black.cgColor
        usernameField.layer.shadowOpacity = 0.05
        usernameField.layer.shadowOffset = CGSize(width: -1, height: 2)
        usernameField.layer.shadowRadius = 5
        
        // Add bitmoji header shadow
        bmView.layer.shadowColor = UIColor.black.cgColor
        bmView.layer.shadowOpacity = 0.05
        bmView.layer.shadowOffset = CGSize(width: -1, height: 2)
        bmView.layer.shadowRadius = 5
        
        // RETURN
        self.usernameField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Init Keyboard
        usernameField.becomeFirstResponder()
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        let viewWidth = adSpace.frame.width
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        adSpace.addSubview(bannerView)
        bannerView.centerXAnchor.constraint(equalTo: adSpace.centerXAnchor).isActive = true
        bannerView.centerYAnchor.constraint(equalTo: adSpace.centerYAnchor).isActive = true
       }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func toggleUi(show: Bool) {
        
        guard let one = self.bmView else { return }
        guard let two = self.usernameField else { return }
        guard let three = self.buttonPanel else { return }
        
        guard let rb = self.resetButton else { return }
        
        if show {
            one.layer.opacity = 1
            two.layer.opacity = 1
            three.layer.opacity = 1
            rb.isEnabled = false
        } else {
            one.layer.opacity = 0
            two.layer.opacity = 0
            three.layer.opacity = 0
            rb.isEnabled = true
        }
        
    }
    
    @objc func fetchBitmoji(_ textField: UITextField) {
        
        guard let username = usernameField.text else { return }
        
        let delayTime = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
            if self.usernameField.text == username {
                AF.request("https://app.snapchat.com/web/deeplink/snapcode?username=\(username)&type=SVG&bitmoji=enable")
                    .response { response in

                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                            
                            let testXml = utf8Text
                            
                            let xml = try! XML.parse(testXml)
                            
                            var sb64 = ""
                            
                            if let index = xml["svg", "image", 0].attributes["xlink:href"] {
                                print(index)
                                sb64 = index
                                let strBase64 = sb64.replacingOccurrences(of: "data:image/png;base64", with: "")
                                
                                guard let dataDecoded : Data = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters) else { return }
                                let decodedimage = UIImage(data: dataDecoded)
                                self.bitmojiPreview.image = decodedimage
                            } else {
                                print("no bitmoji found for \(username)")
                                
                                let noBitmojiImg = UIImage(named: "NoBitmoji.png")
                                
                                self.bitmojiPreview.image = noBitmojiImg
                            }
                            
                            
                        }
                    }
            }
        })
        
//        let url = URL(string: "https://app.snapchat.com/web/deeplink/snapcode?username=\(username)&type=SVG&bitmoji=enable")
        
        var imgStr = "null"
        
//        if let url = URL(string: "https://app.snapchat.com/web/deeplink/snapcode?username=\(username)&type=SVG&bitmoji=enable") {
//            do {
//                let contents = try String(contentsOf: url)
//                imgStr = contents
//            } catch {
//                // contents could not be loaded
//            }
//        } else {
//            // the URL was bad!
//        }
        
        
//        let testXml = imgStr
//
//        let xml = try! XML.parse(testXml)
//
//        var sb64 = ""
//
//        if let index = xml["svg", "image", 0].attributes["xlink:href"] {
//            print(index)
//            sb64 = index
//        } else {
//            print("no bitmoji found for \(username)")
//        }
//
//        let strBase64 = sb64.replacingOccurrences(of: "data:image/png;base64", with: "")
//
//        guard let dataDecoded : Data = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters) else { return }
//        let decodedimage = UIImage(data: dataDecoded)
//        bitmojiPreview.image = decodedimage
        
        DispatchQueue.main.async {
//            self.bitmojiPreview.kf.setImage(with: url)
        }
        
    }
    
    var timer = Timer()
    
    func checkNetwork() {
        
    }

    func checkForSuccess() {
        if browserView.url?.absoluteString == "https://support.snapchat.com/en-US/success" {
            
            igniteSuccess()
            
        }
    }
    
    @IBAction func reignite() {
        
        if usernameField.text == "" {
            let alert = UIAlertController(title: "Oops! 🙈", message: "You can't leave the username empty. Please try again.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
            return
        } else {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
        
        toggleUi(show: false)
        browserView.layer.opacity = 1
        
        print(usernameField.text ?? "NULL")
        browserBusy()
        
        usernameForRestore = usernameField.text ?? "NULL"
        
        injectFormData()
        
//        let url = URL(string: "https://support.snapchat.com/en-US/api/v1/send")!
//        browserView.load(URLRequest(url: url))
//        browserView.allowsBackForwardNavigationGestures = true
        
    }
    
    @IBAction func resetBrowser() {
        
        browserView.layer.opacity = 0
        toggleUi(show: true)
        
        usernameField.text = ""
        let noBitmojiImg = UIImage(named: "NoBitmoji.png")
        self.bitmojiPreview.image = noBitmojiImg
        
        browserBusy()
        browserView.reload()
        
    }
    
    struct history: Codable {
        var event: [hEntry]
    }
    struct hEntry: Codable {
        let username: String
        let timestamp: Date
    }
    
    func addToLog(_ : String) {
        
        let defaults = UserDefaults.standard
        
        if let existingData = defaults.object(forKey: "history") as? Data {
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode(history.self, from: existingData) {
                let date = Date()
                var data = loadedData
                
                data.event.append(hEntry.init(username: usernameForRestore, timestamp: date))
                
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(data) {
                    let defaults = UserDefaults.standard
                    defaults.set(encoded, forKey: "history")
                } else {
                    print("Logging: Level 3 Error")
                }
            } else {
                print("Logging: Level 2 Error")
            }
        } else {
            print("Logging: Level 1 Error")
            let date = Date()
            let data = history.init(event:[hEntry.init(username: usernameForRestore, timestamp: date)])
            
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(data) {
                let defaults = UserDefaults.standard
                defaults.set(encoded, forKey: "history")
            } else {
                print("Logging: Level 2 Error")
            }
        }
        
//        let date = Date()
//
//        data.event.append(hEntry.init(username: usernameForRestore, timestamp: date))
//
//        let encoder = JSONEncoder()
//        if let encoded = try? encoder.encode(data) {
//            let defaults = UserDefaults.standard
//            defaults.set(encoded, forKey: "history")
//        }
        
    }
    
    func browserBusy() {
        
        usernameField.isEnabled = false
        reigniteButton.isEnabled = false
        reigniteButton.layer.opacity = 0.5
        
    }
    
    func browserReady() {
        
        usernameField.isEnabled = true
        reigniteButton.isEnabled = true
        reigniteButton.layer.opacity = 1
        
    }
    
    func igniteSuccess() {
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        addToLog(usernameForRestore)
        
        toggleUi(show: true)
        browserView.layer.opacity = 0
        
        usernameField.text = ""
        let noBitmojiImg = UIImage(named: "NoBitmoji.png")
        self.bitmojiPreview.image = noBitmojiImg
        browserReady()
        
        let url = URL(string: "https://support.snapchat.com/en-US/i-need-help?start=5695496404336640")!
        browserView.load(URLRequest(url: url))
        browserView.allowsBackForwardNavigationGestures = true
        
        let alert = UIAlertController(title: "Request Submitted", message: "In most cases, your streak should re-appear immediately. If not, keep an eye on your inbox for an update from Team Snapchat.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        injectFormatting()
        browserReady()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.checkForValidForm()
        }
        
    }
    
    func injectFormatting() {
        
        // Style the Webpage to fit in with the native UI here
        // Note: Should be called upon webview having loaded.
        
        let hideNav = "document.getElementsByClassName('header-container')[0].style.display = 'none';"
        let hideHeader = "document.getElementsByClassName('snapchat-header')[0].style.display = 'none';"
        let hideMobileHeader = "document.getElementsByClassName('snapchat-mobile-header')[0].style.display = 'none';"
        let hideSB1 = "document.getElementsByClassName('desktop-navigation')[0].style.visibility = 'hidden';"
        let resSB1 = "document.getElementsByClassName('sc-content')[0].style.visibility = 'visible';"
        let hideFooter = "document.getElementsByClassName('footer-container')[0].style.display = 'none';"
        
        let maincss = "var addRule; if (typeof document.styleSheets != \"undefined\" && document.styleSheets) { addRule = function(selector, rule) { var styleSheets = document.styleSheets, styleSheet; if (styleSheets && styleSheets.length) { styleSheet = styleSheets[styleSheets.length - 1]; if (styleSheet.addRule) { styleSheet.addRule(selector, rule) } else if (typeof styleSheet.cssText == \"string\") { styleSheet.cssText = selector + \" {\" + rule + \"}\"; } else if (styleSheet.insertRule && styleSheet.cssRules) { styleSheet.insertRule(selector + \" {\" + rule + \"}\", styleSheet.cssRules.length); } } } } else { addRule = function(selector, rule, el, doc) { el.appendChild(doc.createTextNode(selector + \" {\" + rule + \"}\")); }; } function createCssRule(selector, rule, doc) { doc = doc || document; var head = doc.getElementsByTagName(\"head\")[0]; if (head && addRule) { var styleEl = doc.createElement(\"style\"); styleEl.type = \"text/css\"; styleEl.media = \"screen\"; head.appendChild(styleEl); addRule(selector, rule, styleEl, doc); styleEl = \"div{top:0 !important;}\"; } }; createCssRule(\"div\", \"top: 0; !important\");"
        
        browserView.evaluateJavaScript(hideNav, completionHandler: nil)
        browserView.evaluateJavaScript(hideHeader, completionHandler: nil)
        browserView.evaluateJavaScript(hideMobileHeader, completionHandler: nil)
        browserView.evaluateJavaScript(hideSB1, completionHandler: nil)
        browserView.evaluateJavaScript(resSB1, completionHandler: nil)
        browserView.evaluateJavaScript(hideFooter, completionHandler: nil)
        browserView.evaluateJavaScript(maincss, completionHandler: nil)
        
    }
    
    func checkForValidForm() {
        
        let keyField = "field-24281229"
        
        let js = "var element =  document.getElementById('\(keyField)'); if (typeof(element) != 'undefined' && element != null){}else{location.reload();}"
        
        browserView.evaluateJavaScript(js, completionHandler: nil)
        
    }
    
    
    
    func injectFormData() {
        
        let userUsername = data.username
        let userEmail = data.email
        let userPhone = data.phone
        
        let js = "document.getElementsByName('field-24281229')[0].value ='\(userUsername)'; document.getElementsByName('field-24335325')[0].value ='\(userEmail)'; document.getElementsByName('field-24369716')[0].value ='\(userPhone)'; document.getElementsByName('field-24369726')[0].value ='\(UIDevice.current.model)'; document.getElementsByName('field-24369736')[0].value ='\(usernameForRestore)'; document.getElementsByName('field-24326423')[0].value ='Today'; document.getElementsByName('field-24641746')[0].value ='123'; document.getElementsByName('field-24643406')[0].value ='hourglass-no'; document.getElementsByName('field-22808619')[0].value ='Please Restore!'; document.querySelectorAll(\"input[type=submit]\")[0].click(); var element = document.getElementsByTagName(\"iframe\")[0]; element.scrollIntoView(); element.scrollIntoView(false); element.scrollIntoView({block: \"end\"}); element.scrollIntoView({behavior: \"smooth\", block: \"end\", inline: \"nearest\"});"
        
        browserView.evaluateJavaScript(js, completionHandler: nil)
        
    }


}
