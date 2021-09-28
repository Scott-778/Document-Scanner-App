//
//  SubTableViewController.swift
//  Scanner App
//
//

import UIKit
import SafariServices
import SwiftyStoreKit
import AppsFlyerLib

class SubTableViewController: UITableViewController {
    
   // @IBOutlet weak var oneMonthSub: UIButton!
   // @IBOutlet weak var oneYearSub: UIButton!
    
    @IBOutlet weak var restoreButton: UIBarButtonItem!
    
    @IBOutlet weak var oneMonthSub: UIButton!
    
    @IBOutlet weak var oneWeekSub: UIButton!
    @IBOutlet weak var features: UITextView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var trial: UITextView!
    var oneMonthPriceString = ""
    var generator: UIImpactFeedbackGenerator?
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    let restoreActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
      
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent          }
    override func viewDidLoad() {
        super.viewDidLoad()
        oneWeekSub.tag = 0
        oneMonthSub.tag = 1
        
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor(named: "Blue")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
       navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        getProductInfo()
        activityIndicator.frame = view.bounds
       // activityIndicator.center.y = view.center.y - 140
        activityIndicator.center.y = self.oneWeekSub.center.y
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        
        activityIndicator.color = UIColor.white
        
        view.addSubview(activityIndicator)
        navigationController?.setToolbarHidden(false, animated: true)
        navigationController?.toolbar.isTranslucent = true
        navigationController?.navigationBar.isTranslucent = true
      
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationItem.largeTitleDisplayMode = .never
       
        navigationController?.navigationBar.shadowImage = UIImage()
       // oneYearSub.layer.cornerRadius = 12
        oneWeekSub.layer.cornerRadius = 12
       oneMonthSub.layer.cornerRadius = 12
        tableView.tableFooterView = UIView()
       
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.duration = 0.9
        pulse.toValue = 1.07
        pulse.fromValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 6
        oneWeekSub.layer.add(pulse, forKey: "scale")
        
        if #available(iOS 13.0, *) {
             generator = UIImpactFeedbackGenerator(style: .rigid)
        } else {
             generator = UIImpactFeedbackGenerator(style: .light)
        }
    }

    func getProductInfo(){
        
        trial.text = NSLocalizedString("trialWeek", comment: "trial")
               features.text = NSLocalizedString("features", comment:"features")
               SwiftyStoreKit.retrieveProductsInfo([""]) { result in
                   if let product = result.retrievedProducts.first {
                       let priceString = product.localizedPrice!
                       print("Product: \(product.localizedDescription), price: \(priceString)")
                       let hasSubed = UserDefaults.standard.bool(forKey: "hasSubbed")
                       if hasSubed == true {
                           DispatchQueue.main.async {
                                let week = NSLocalizedString("week",comment: "week")
                               self.price.text = "\(priceString)\(week)"
                           let continueString = NSLocalizedString("continue", comment: "continue")
                           self.oneWeekSub.setTitle(continueString, for: .normal)
                           }
                       }else{
                           DispatchQueue.main.async {
                               let string1 = NSLocalizedString("Try 3 days FREE Then", comment: "try")
                               let week = NSLocalizedString("week",comment: "week")
                               
                               self.price.text =
                               "\(string1) \(priceString)\(week)"
                           }
                           
                       }
                       
                   }
                   else if let invalidProductId = result.invalidProductIDs.first {
                       print("Invalid product identifier: \(invalidProductId)")
                   }
                   else {
                    print("Error: \(String(describing: result.error))")
                   }
               }
        SwiftyStoreKit.retrieveProductsInfo([""]) {
        result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                let year = NSLocalizedString("month", comment: "month")
                 DispatchQueue.main.async {
                   self.oneMonthSub.setTitle(priceString + year, for: .normal)
                }
                self.oneMonthPriceString = priceString + year
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(String(describing: result.error))")
            }
        }
             
    }
    
    @IBAction func purchaseOneMonth(_ sender: Any) {
            self.startActivity(sender: sender as! UIButton)
            
           generator?.impactOccurred()
                
                    
                    SwiftyStoreKit.purchaseProduct("", quantity: 1, atomically: true) { result in
                    switch result {
                    case .success(let purchase):
                        print("Purchase Success: \(purchase.productId)")
                        UserDefaults.standard.set(true, forKey: "hasSubbed")
                        self.stopActivity()
                       
                        self.dismiss(animated: true, completion: nil)
                    case .error(let error):
                       self.stopActivity()
                       
                        switch error.code {
                            
                        case .unknown: print("Unknown error. Please contact support")
                        case .clientInvalid: print("Not allowed to make the payment")
                        case .paymentCancelled: break
                        case .paymentInvalid: print("The purchase identifier was invalid")
                        case .paymentNotAllowed: print("The device is not allowed to make the payment")
                        case .storeProductNotAvailable: print("The product is not available in the current storefront")
                        case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                        case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                        case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                        case .privacyAcknowledgementRequired:
                            print("privacy")
                        case .unauthorizedRequestData:
                            print("unauth")
                        case .invalidOfferIdentifier:
                            print("invalid identifier")
                        case .invalidSignature:
                            print("invalid sig")
                        case .missingOfferParams:
                            print("missing offer")
                        case .invalidOfferPrice:
                            print("invalid")
                        case .overlayCancelled:
                            print("invalid")

                        case .overlayInvalidConfiguration:
                            print("invalid")

                        case .overlayTimeout:
                            print("invalid")

                        case .ineligibleForOffer:
                            print("invalid")

                        case .unsupportedPlatform:
                            print("invalid")
                        case .overlayPresentedInBackgroundScene:
                            print("invalid")
                        }
                    }
                    
                    
                }
           
       }
       
    
    
    @IBAction func purchaseOneYear(_ sender: Any) {
        self.activityIndicator.startAnimating()
     
        generator?.impactOccurred()
        SwiftyStoreKit.purchaseProduct("", quantity: 1, atomically: true) { result in
            
            
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                UserDefaults.standard.set(true, forKey: "hasSubbed")
                self.activityIndicator.stopAnimating()
               
                self.dismiss(animated: true, completion: nil)
            case .error(let error):
                self.activityIndicator.stopAnimating()
               
                switch error.code {
                    
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                case .privacyAcknowledgementRequired:
                    print("privacy")
                case .unauthorizedRequestData:
                    print("unauth")
                case .invalidOfferIdentifier:
                    print("invalid identifier")
                case .invalidSignature:
                    print("invalid sig")
                case .missingOfferParams:
                    print("missing offer")
                case .invalidOfferPrice:
                    print("invalid")
                case .overlayCancelled:
                    print("invalid")

                case .overlayInvalidConfiguration:
                    print("invalid")

                case .overlayTimeout:
                    print("invalid")

                case .ineligibleForOffer:
                    print("invalid")

                case .unsupportedPlatform:
                    print("invalid")
                case .overlayPresentedInBackgroundScene:
                    print("invalid")
                }
            }
            
            
        }
   
    }
    
    
    @IBAction func purchase(_ sender: Any) {
         // self.activityIndicator.startAnimating()
        self.startActivity(sender: sender as! UIButton)
        generator?.impactOccurred()
        SwiftyStoreKit.purchaseProduct("", quantity: 1, atomically: true) { result in
            
            
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                UserDefaults.standard.set(true, forKey: "hasSubbed")
                //self.activityIndicator.stopAnimating()
                AppsFlyerLib.shared().logEvent("freeTrial", withValues: ["":""])

                self.stopActivity()
              
                self.dismiss(animated: true, completion: nil)
            case .error(let error):
              //  self.activityIndicator.stopAnimating()
               self.stopActivity()
               switch error.code {
                 
                 case .unknown: print("Unknown error. Please contact support")
                 case .clientInvalid: print("Not allowed to make the payment")
                 case .paymentCancelled: break
                 case .paymentInvalid: print("The purchase identifier was invalid")
                 case .paymentNotAllowed: print("The device is not allowed to make the payment")
                 case .storeProductNotAvailable: print("The product is not available in the current storefront")
                 case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                 case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                 case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
               case .privacyAcknowledgementRequired:
               print("privacy")
               case .unauthorizedRequestData:
               print("unauth")
               case .invalidOfferIdentifier:
               print("invalid identifier")
               case .invalidSignature:
                print("invalid sig")
               case .missingOfferParams:
                print("missing offer")
               case .invalidOfferPrice:
                print("invalid")
               case .overlayCancelled:
                print("invalid")

               case .overlayInvalidConfiguration:
                print("invalid")

               case .overlayTimeout:
                print("invalid")

               case .ineligibleForOffer:
                print("invalid")

               case .unsupportedPlatform:
                   print("invalid")
               case .overlayPresentedInBackgroundScene:
                   print("invalid")
               
               }
            }
            
            
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    @IBAction func terms(_ sender: Any) {
        if #available(iOS 11.0, *) {
        let config = SFSafariViewController.Configuration()
        
        config.entersReaderIfAvailable = true
       
        let vc = SFSafariViewController(url: URL(string:"")!, configuration: config)
       
        
        present(vc, animated: true)
       // UIApplication.shared.statusBarStyle = .default
        }
    }
    @IBAction func privacy(_ sender: Any) {
        if #available(iOS 11.0, *) {
        let config = SFSafariViewController.Configuration()
       
        config.entersReaderIfAvailable = true
        
       
            let vc = SFSafariViewController(url: URL(string:"")!, configuration: config)
      
       
        present(vc, animated: true)
      
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
   

@IBAction func dismiss(_ sender: Any) {
       
            //self.activityIndicator.startAnimating()
        self.startActivityRestore()
       
            SwiftyStoreKit.restorePurchases(atomically: true) { results in
                if results.restoreFailedPurchases.count > 0 {
                    print("Restore Failed: \(results.restoreFailedPurchases)")
                   // self.activityIndicator.stopAnimating()
                    self.stopActivityRestore()
                    
                   
                }
                else if results.restoredPurchases.count > 0 {
                    print("Restore Success: \(results.restoredPurchases)")
                    UserDefaults.standard.set(true, forKey: "hasSubbed")
                    self.dismiss(animated: true, completion: nil)
                
                    //self.activityIndicator.stopAnimating()
                    self.stopActivityRestore()
                   
                }
                else {
                    print("Nothing to Restore")
                     //self.activityIndicator.stopAnimating()
                    self.stopActivityRestore()
                    
                }
            }
        
    }
   
  //  func startActivity(){
  //      self.oneWeekSub.setTitle("", for: .normal)
   //     self.activityIndicator.startAnimating()
  //  }
    func startActivity(sender: UIButton){
        if sender.tag == 0{
        activityIndicator.center.y = self.oneWeekSub.center.y
        self.oneWeekSub.setTitle("", for: .normal)
        self.activityIndicator.startAnimating()
        }else if sender.tag == 1{
            activityIndicator.center.y = self.oneMonthSub.center.y
            self.oneMonthSub.setTitle("", for: .normal)
            self.activityIndicator.startAnimating()
        }
    }
    func stopActivity(){
         let hasSubed = UserDefaults.standard.bool(forKey: "hasSubbed")
             if hasSubed == true {
                 self.oneWeekSub.setTitle(NSLocalizedString("continue", comment: "Continue"), for: .normal)
             }else{
                 self.oneWeekSub.setTitle(NSLocalizedString("startFreeTrial", comment: "Free Trial"), for: .normal)}
        self.oneMonthSub.setTitle(oneMonthPriceString, for: .normal)
        self.activityIndicator.stopAnimating()
    }
    func startActivityRestore(){
        let a = UIActivityIndicatorView(activityIndicatorStyle: .white)
        a.color = UIColor.white
        a.hidesWhenStopped = true
        a.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: a)
        
    }
    func stopActivityRestore(){
        let but = UIBarButtonItem()
        but.title = NSLocalizedString("restore", comment: "Restore")
        but.target = self
        but.tintColor = UIColor.white
        but.action = #selector(dismiss(_:))
        self.navigationItem.rightBarButtonItem = but
        
    }
    
   
    @IBAction func moreOptions(_ sender: Any) {
        let sub2 = storyboard?.instantiateViewController(withIdentifier: "sub2") as! MoreSubsTableViewController
        navigationController?.pushViewController(sub2, animated: true)
    }
}
