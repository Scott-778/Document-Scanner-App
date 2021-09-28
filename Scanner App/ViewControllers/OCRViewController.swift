//
//  OCRViewController.swift
//  Scanner App
//
//

import UIKit
import Firebase
import GoogleMobileVision


class OCRViewController: UIViewController {
    var image: UIImage!
    var scannedText: String!
    
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("scannedText", comment: "Scanned text")
        if let st = scannedText{
         self.textView.text = st
        }
       
        // Do any additional setup after loading the view.
    }
    
    @IBAction func share(_ sender: Any) {
        let items = [textView.text]
        let ac = UIActivityViewController(activityItems: items as [Any], applicationActivities: nil)
        if let pop = ac.popoverPresentationController{
                        pop.barButtonItem = sender as? UIBarButtonItem
                                                            }
        present(ac, animated: true, completion: nil)
    }
    
    
    @IBAction func copyText(_ sender: Any) {
        UIPasteboard.general.string = textView.text
      
        let copiedMessage = NSLocalizedString("copied", comment: "copied")
        let alert = UIAlertController(title: copiedMessage, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (alert) in
            
        }))
        present(alert, animated: true, completion: nil)
        
    }
   
}
