//
//  DocumentsViewController.swift
//  Scanner App
//
//

import UIKit
import WeScan
import PDFKit
import SwiftyStoreKit
import Foundation


class DocumentsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ImageScannerControllerDelegate, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var info: UIBarButtonItem!
    @IBOutlet weak var gridList: UIBarButtonItem!
    @IBOutlet weak var sort: UIBarButtonItem!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    var directoryObserver: DirectoryObserver!
    var imgArry = [UIImage]()
    var documents = [PdfAndThumb]()
    var scannedImage: UIImage!
    var documentOrderNumber = 0
    var longPress: UILongPressGestureRecognizer!
    var longPressTable: UILongPressGestureRecognizer?
    private var sectionInsets: UIEdgeInsets!
    private var itemsPerRow: CGFloat!
   // private let sectionInsets = UIEdgeInsets(top: 10.0,
                  //                           left: 10.0,
                   //                          bottom: 10.0,
                     //                        right: 10.0)
   // private let itemsPerRow: CGFloat = 2
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setToolbarHidden(true, animated: false)
        self.verifySubOneWeek()
        collection.reloadData()
        tableView.reloadData()
        sort.tag = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.userInterfaceIdiom == .pad{
            sectionInsets = UIEdgeInsets(top: 10.0,
                                         left: 10.0,
                                         bottom: 10.0,
                                         right: 10.0)
            itemsPerRow = 4
        }else{
            sectionInsets = UIEdgeInsets(top: 10.0,
                                         left: 10.0,
                                         bottom: 10.0,
                                         right: 10.0)
            itemsPerRow = 3
        }
        documents = Documents.getDocuments()
        collection.reloadData()
        tableView.reloadData()
        addButton.layer.cornerRadius = addButton.frame.height / 2
        addButton.titleLabel?.textAlignment = .center
        addButton.titleLabel?.numberOfLines = 0
        sort.title = NSLocalizedString("sort", comment: "Sort")
        
        directoryObserver = DirectoryObserver.watch(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
        directoryObserver.onNewFiles = { newFiles in
            print("new Files")
            DispatchQueue.main.async{
                self.documents = Documents.getDocuments()
                self.collection.reloadData()
                self.tableView.reloadData()
            }
        }
        directoryObserver.onDeletedFiles = { d in
            DispatchQueue.main.async {
                self.documents = Documents.getDocuments()
                self.collection.reloadData()
                self.tableView.reloadData()
            }
        }
        
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        longPressTable = UILongPressGestureRecognizer(target: self, action: #selector(longPressedTable))
        collection.addGestureRecognizer(longPress)
        tableView.addGestureRecognizer(longPressTable!)
        tableView.tableFooterView = UIView()
        if #available(iOS 13.0, *) {
            gridList.image = UIImage(systemName: "list.bullet")
            info.image = UIImage(systemName: "info.circle.fill")
        } else {
            gridList.image = UIImage(named: "list")
             info.image = UIImage(named: "info")
        }
        
        
    }
    @objc func longPressedTable(gesture: UILongPressGestureRecognizer){
           if gesture.state != .began{
               return
           }
        let generator: UIImpactFeedbackGenerator?
               if #available(iOS 13.0, *) {
                    generator = UIImpactFeedbackGenerator(style: .rigid)
               } else {
                    generator = UIImpactFeedbackGenerator(style: .light)
               }
               generator?.impactOccurred()
               let p = gesture.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: p){
                   print(indexPath.row)
                   let cell = self.tableView.cellForRow(at: indexPath) as! DocumentTableViewCell
                   UIView.animate(withDuration: 0.4) {
                       cell.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                   }
                   UIView.animate(withDuration: 0.2) {
                       cell.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                     
                   }
                 
                   if let docUrl = self.documents[indexPath.row].pdf.documentURL{
                       let items = [docUrl]
                       let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    if let pop = ac.popoverPresentationController{
                        pop.sourceView = self.view
                         pop.sourceRect = CGRect(x: p.x, y: p.y, width: 0, height: 0)
                       }
                       
                       self.present(ac, animated: true, completion: nil)
                       
                       
                   }
                   
                   print("long pressed")
               }
               
    }
    @objc func longPressed(gesture: UILongPressGestureRecognizer){
        if gesture.state != .began{
            return
        }
        let generator: UIImpactFeedbackGenerator?
        if #available(iOS 13.0, *) {
             generator = UIImpactFeedbackGenerator(style: .rigid)
        } else {
             generator = UIImpactFeedbackGenerator(style: .light)
        }
        generator?.impactOccurred()
        let p = gesture.location(in: self.collection)
        if let indexPath = self.collection.indexPathForItem(at: p){
            print(indexPath.row)
            let cell = self.collection.cellForItem(at: indexPath) as! DocumentCell
            UIView.animate(withDuration: 0.4) {
                cell.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            }
            UIView.animate(withDuration: 0.2) {
                cell.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
              
            }
          
            if let docUrl = self.documents[indexPath.row].pdf.documentURL{
                let items = [docUrl]
                let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                if let pop = ac.popoverPresentationController{
                    pop.sourceView = self.view
                    pop.sourceRect = CGRect(x: p.x, y: p.y, width: 0, height: 0)
                                      }
                self.present(ac, animated: true, completion: nil)
                
                
            }
            
            print("long pressed")
        }
        
    }
    @IBAction func addButtonACtion(_ sender: Any) {
        showActionsheet()
       
        
    }
    
   
    @IBAction func Sort(_ sender: UIBarButtonItem) {
        let actionsheet = UIAlertController(title: NSLocalizedString("sortBy", comment: "Sort by"), message: nil, preferredStyle: .actionSheet)
        actionsheet.addAction(UIAlertAction(title: NSLocalizedString("date", comment: "Date"), style: .default, handler: { (action) in
            self.documents.reverse()
            self.collection.reloadData()
            self.tableView.reloadData()
            sender.tag += 1
        }))
        actionsheet.addAction(UIAlertAction(title: NSLocalizedString("pageCount", comment: "Page count"), style: .default, handler: { (action) in
            if sender.tag % 2 == 0{
                
                self.documents = self.documents.sorted(by: {$1.pdf.pageCount < $0.pdf.pageCount})
                self.collection.reloadData()
                self.tableView.reloadData()
            }else{
                
                self.documents = self.documents.sorted(by: {$1.pdf.pageCount > $0.pdf.pageCount})
                self.collection.reloadData()
                self.tableView.reloadData()
            }
            sender.tag += 1
        }))
        actionsheet.addAction(UIAlertAction(title: NSLocalizedString("name", comment: "name"), style: .default, handler: { (alert) in
             if sender.tag % 2 == 0{
                self.documents = self.documents.sorted(by:
                    {$1.pdf.documentURL!.lastPathComponent.lowercased() >
                        $0.pdf.documentURL!.lastPathComponent.lowercased()})
                    self.collection.reloadData()
                    self.tableView.reloadData()
                
             }else{
                
                self.documents = self.documents.sorted(by: {$1.pdf.documentURL!.lastPathComponent.lowercased() < $0.pdf.documentURL!.lastPathComponent.lowercased()})
                    self.collection.reloadData()
                    self.tableView.reloadData()
            }
            
            sender.tag += 1
        }))
        actionsheet.addAction(UIAlertAction(title: CANCEL, style: .cancel, handler: nil))
        
        if let pop = actionsheet.popoverPresentationController{
            pop.barButtonItem = sender
               }
        present(actionsheet, animated: true, completion: nil)
    }
    func showActionsheet(){
        let actionsheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionsheet.addAction(UIAlertAction(title: NSLocalizedString("camera", comment: "camera"), style: .default, handler: { (action) in
            self.scanImage()
        }))
        actionsheet.addAction(UIAlertAction(title: NSLocalizedString("photos", comment: "photos"), style: .default, handler: { (action) in
            self.selectImage()
        }))
        actionsheet.addAction(UIAlertAction(title: CANCEL, style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            
        }
        if let pop = actionsheet.popoverPresentationController{
            pop.sourceView = self.view
            pop.sourceRect = CGRect(x: self.addButton.center.x, y: self.addButton.center.y, width: 0, height: 0)
        }
         
        present(actionsheet, animated: true, completion: nil)
        
    }
    
    func scanImage(){
        let scanner = ImageScannerController()
        scanner.imageScannerDelegate = self
        scanner.modalPresentationStyle = .fullScreen
    
        navigationController?.present(scanner, animated: true, completion: nil)
    }
    
    func selectImage(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func verifySubOneWeek(){
        let hasSubed = UserDefaults.standard.bool(forKey: "hasSubbed")
        
        if hasSubed == true {
            //verify sub
            let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "")
            SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                switch result {
                case .success(let receipt):
                    let productId = ""
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable,
                        productId: productId,
                        inReceipt: receipt)
                    switch purchaseResult {
                    case .purchased( _,  _):
                        UserDefaults.standard.set(true, forKey: "hasSubbed")
                    case .expired( _, _):
                        //print("\(productId) is expired since \(expiryDate)\n\(items)\n"
                        self.verifySubOneMonth()
                    case .notPurchased:
                        print("The user has never purchased \(productId)")
                        self.verifySubOneMonth()
                    }
                    
                case .error(let error):
                    print("Receipt verification failed: \(error)")
                }
            }
        }else{
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "sub") as! SubTableViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.navigationController?.present(nav, animated: true, completion: nil)
            
        }
    }
    func verifySubOneMonth(){
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "")
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = ""
              
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: productId,
                    inReceipt: receipt)
                switch purchaseResult {
                case .purchased( _, _):
                    UserDefaults.standard.set(true, forKey: "hasSubbed")
                case .expired( _, _):
                    //print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                    self.verifySubOneYearFreeTrial()
        
                case .notPurchased:
                    print("The user has never purchased \(productId)")
                    
                   self.verifySubOneYearFreeTrial()
                   
                }
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }
    func verifySubOneYearFreeTrial(){
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "")
               SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                   switch result {
                   case .success(let receipt):
                       let productId = ""
                     
                       let purchaseResult = SwiftyStoreKit.verifySubscription(
                           ofType: .autoRenewable,
                           productId: productId,
                           inReceipt: receipt)
                       switch purchaseResult {
                       case .purchased( _, _):
                           UserDefaults.standard.set(true, forKey: "hasSubbed")
                       case .expired( _, _):
                           //print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                           self.verifySubOneYear()
               
                       case .notPurchased:
                           print("The user has never purchased \(productId)")
                           
                          self.verifySubOneYear()
                          
                       }
                       
                   case .error(let error):
                       print("Receipt verification failed: \(error)")
                   }
               }
        
    }
    func verifySubOneYear(){
      
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "")
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = ""
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: productId,
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased( _, _):
                    UserDefaults.standard.set(true, forKey: "hasSubbed")
                case .expired(_, _):
                    //print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "sub") as! SubTableViewController
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen

                    self.navigationController?.present(nav, animated: true, completion: nil)
                    
                case .notPurchased:
                    print("The user has never purchased \(productId)")
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "sub") as! SubTableViewController
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen

                    self.navigationController?.present(nav, animated: true, completion: nil)
                    
                }
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
      
    }
    
    @IBAction func showSub(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "settings") as! SettingsViewController
        let nav = UINavigationController(rootViewController: vc)
         present(nav, animated: true, completion: nil)
    }
    func savePicture(picture: UIImage, imageName: String) {
       let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
      
        let pdfDoc = PDFDocument()
        let pdfPage = PDFPage(image: picture)
        pdfDoc.insert(pdfPage!, at: 0)
        let data = pdfDoc.dataRepresentation()
        
      
        FileManager.default.createFile(atPath: imagePath, contents: data, attributes: nil)
        
          self.documents = Documents.getDocuments()
          self.collection.reloadData()
          self.tableView.reloadData()
          let vc = storyboard?.instantiateViewController(withIdentifier: "save") as! SaveViewController
       DispatchQueue.main.async {
                vc.callBack = { [weak self] in
                    self?.documents = Documents.getDocuments()
                    self?.tableView.reloadData()
                    self?.collection.reloadData()
                    print("Callback")
                }
        }
          let url = URL(fileURLWithPath: imagePath)
          vc.pdfUrl = url
          vc.PDFDoc = pdfDoc
         
         // vc.PDFDoc = self.documents[0].pdf
         
         navigationController?.pushViewController(vc, animated: true)
    }
 

    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        if results.doesUserPreferEnhancedImage {
            scannedImage = results.enhancedImage
        } else {
            scannedImage = results.scannedImage
        }
        scanner.dismiss(animated: true, completion: nil)
       let name = "\(Documents.getTime()).pdf"
        savePicture(picture: scannedImage, imageName: name)
        
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        scanner.dismiss(animated: true, completion: nil)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.collection.collectionViewLayout.invalidateLayout()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // let documentPath = documents[indexPath.row].pdf.documentURL!.path

        let vc = storyboard?.instantiateViewController(withIdentifier: "save") as! SaveViewController
       DispatchQueue.main.async {
                vc.callBack = { [weak self] in
                    self?.documents = Documents.getDocuments()
                    self?.tableView.reloadData()
                    self?.collection.reloadData()
                    print("Callback")
                }
        }
        vc.PDFDoc = documents[indexPath.row].pdf
        navigationController?.pushViewController(vc, animated: true)
           // let nav = UINavigationController(rootViewController: vc)
            //present(nav, animated: true) {
            
        
       
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "doc", for: indexPath) as! DocumentCell
        cell.docImg.layer.cornerRadius = 15
        cell.docImg.clipsToBounds = true
        cell.pageCountView.layer.cornerRadius = cell.pageCountView.frame.height / 2
        cell.pageCount.text = "\( documents[indexPath.row].pdf.pageCount)"
         var documentTitle = documents[indexPath.row].pdf.documentURL?.path.components(separatedBy: "Documents/")[1]
               documentTitle = String(Array(documentTitle!)[0..<(documentTitle!.count-4)])
            //   cell.title.text = documentTitle
         cell.docImg.image = documents[indexPath.row].thumb
      
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return documents.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem + 30)//35)
    }
    
   
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
   
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
     
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell") as! DocumentTableViewCell
        cell.docImage.layer.cornerRadius = 3
        cell.docImage.clipsToBounds = true
        cell.docImage.image = documents[indexPath.row].thumb
        var documentTitle = documents[indexPath.row].pdf.documentURL?.path.components(separatedBy: "Documents/")[1]
        documentTitle = String(Array(documentTitle!)[0..<(documentTitle!.count-4)])
        cell.titleLabel.text = documentTitle
        let date = documents[indexPath.row].pdf.documentAttributes![PDFDocumentAttribute.creationDateAttribute] as! Date
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        let fDate = df.string(from: date)
        cell.dateLabel.text = fDate.description
        if documents[indexPath.row].pdf.pageCount > 1{
            cell.pageCountLabel.text =  String(documents[indexPath.row].pdf.pageCount) + NSLocalizedString("pages", comment: " Pages")
            
        }else{
              cell.pageCountLabel.text =  String(documents[indexPath.row].pdf.pageCount) + NSLocalizedString("page", comment: " Page")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "save") as! SaveViewController
               vc.PDFDoc = documents[indexPath.row].pdf
        DispatchQueue.main.async {
                vc.callBack = { [weak self] in
                    self?.documents = Documents.getDocuments()
                    self?.tableView.reloadData()
                    self?.collection.reloadData()
                    print("Callback")
                }
        }
               navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func gridToListView(_ sender: Any) {
        
        if collection.isHidden{
            collection.isHidden = false
            
            if #available(iOS 13.0, *) {
                gridList.image = UIImage(systemName: "list.bullet")
            } else {
                 gridList.image = UIImage(named: "list")
            }
           
           
        }else{
            collection.isHidden = true
            
            if #available(iOS 13.0, *) {
                gridList.image = UIImage(systemName: "square.grid.2x2.fill")
            } else {
               gridList.image = UIImage(named: "grid")
            }
        }
        
    }
    
}
extension DocumentsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
        
        let scanner = ImageScannerController(image: image, delegate: self)
        scanner.modalPresentationStyle = .fullScreen
        present(scanner, animated: true, completion: nil)
        
        
    }
}

