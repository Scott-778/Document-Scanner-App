//
//  SaveViewController.swift
//  Scanner App
//
//
import UIKit
import Firebase
import PDFKit
import WeScan
import ImageSlideshow
import Zip
import StoreKit
import QuickLook
class SaveViewController: UIViewController, ImageScannerControllerDelegate {
    @IBOutlet weak var preview: UIImageView!
    var image: UIImage!
    var pdfUrl: URL!
    var PDFDoc: PDFDocument!
    var scannedImage: UIImage!
    @IBOutlet weak var slideshowView: ImageSlideshow!
    var imageSources = [ImageSource]()
    var images = [UIImage]()
    var callBack: (() -> Void)?
    var isReadNamed = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        images.removeAll()
        imageSources.removeAll()
        for i in 0 ..< PDFDoc.pageCount{
            guard let page = PDFDoc.page(at: i) else {
                continue
            }
            let image = page.thumbnail(of: CGSize(width: preview.frame.size.width*5, height: preview.frame.size.height*5), for: .trimBox)
            let source = ImageSource(image: image)
            imageSources.append(source)
            images.append(image)
        }
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.black
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        slideshowView.pageIndicator = pageControl
        slideshowView.delegate = self
        slideshowView.setImageInputs(imageSources)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        SKStoreReviewController.requestReview()
        navigationController?.setToolbarHidden(false, animated: true)
        navigationController?.toolbar.isTranslucent = false
        if let pdf = pdfUrl{
            var documentTitle = pdf.path.components(separatedBy: "Documents/")[1]
            documentTitle = String(Array(documentTitle)[0..<(documentTitle.count-4)])
            self.navigationItem.prompt = documentTitle
        }
        else{
            var documentTitle = PDFDoc!.documentURL!.path.components(separatedBy: "Documents/")[1]
            documentTitle = String(Array(documentTitle)[0..<(documentTitle.count-4)])
            self.navigationItem.prompt = documentTitle
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    @IBAction func rename(_ sender: Any) {
        self.renamePDF()
    }

    func renamePDF(){
        let alertController = UIAlertController(title: NSLocalizedString("rename", comment: "Rename"), message: NSLocalizedString("enterNewName", comment: "Enter new document name"), preferredStyle: .alert)
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: NSLocalizedString("save", comment: "Save"), style: .default) {
            (_) in
            let name = alertController.textFields?[0].text
            if name != "" {
                if let pdf = self.pdfUrl{
                    if Documents.checkSameName(fileName: name!) {
                        do {
                            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                            let documentDirectory = URL(fileURLWithPath: path)
                            let originPath = documentDirectory.appendingPathComponent(pdf.lastPathComponent)
                            let destinationPath = documentDirectory.appendingPathComponent("\(name!)(1).pdf")
                            try FileManager.default.moveItem(at: originPath, to: destinationPath)
                            self.navigationItem.prompt = name!
                            self.PDFDoc = PDFDocument(url: destinationPath)
                            self.pdfUrl = destinationPath
                            self.isReadNamed = true
                        }
                        catch{
                            print("error")
                        }
                    }
                    else {
                        //self.savePicture(picture: scannedImage, imageName: "\(name!).jpg")
                        do {
                            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                            let documentDirectory = URL(fileURLWithPath: path)
                            let originPath = documentDirectory.appendingPathComponent(pdf.lastPathComponent)
                            let destinationPath = documentDirectory.appendingPathComponent("\(name!).pdf")
                            try FileManager.default.moveItem(at: originPath, to: destinationPath)
                            self.navigationItem.prompt = name!
                            self.PDFDoc = PDFDocument(url: destinationPath)
                            self.pdfUrl = destinationPath
                            self.isReadNamed = true
                        }
                        catch{
                            print("error")
                        }
                    }
                }
                else{
                    if Documents.checkSameName(fileName: name!) {
                        do {
                            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                            let documentDirectory = URL(fileURLWithPath: path)
                            let originPath = documentDirectory.appendingPathComponent(self.PDFDoc.documentURL!.lastPathComponent)
                            let destinationPath = documentDirectory.appendingPathComponent("\(name!)(1).pdf")
                            try FileManager.default.moveItem(at: originPath, to: destinationPath)
                            self.navigationItem.prompt = name!
                            self.PDFDoc = PDFDocument(url: destinationPath)
                            self.isReadNamed = true
                        }
                        catch{
                            print("error")
                        }
                    }
                    else {
                        //self.savePicture(picture: scannedImage, imageName: "\(name!).jpg")
                        do {
                            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                            let documentDirectory = URL(fileURLWithPath: path)
                            let originPath = documentDirectory.appendingPathComponent(self.PDFDoc.documentURL!.lastPathComponent)
                            let destinationPath = documentDirectory.appendingPathComponent("\(name!).pdf")
                            try FileManager.default.moveItem(at: originPath, to: destinationPath)
                            self.navigationItem.prompt = name!
                            self.PDFDoc = PDFDocument(url: destinationPath)
                            self.isReadNamed = true
                        }
                        catch{
                            print("error")
                        }
                    }
                }
            }
            else {
                //self.savePicture(picture: scannedImage, imageName: "\(now).jpg")
            }
        }
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: CANCEL, style: .cancel) {
            (_) in
        }
        //adding textfields to our dialog box
        alertController.addTextField {
            (textField) in
            textField.placeholder = ""
        }
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        //finally presenting the dialog box
        present(alertController, animated: true, completion: nil)
    }

    @IBAction func sharePDForJPEG(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("exportFormat", comment: "Export format"), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "PDF", style: .default, handler: {
            (a) in
            if let pdf = self.PDFDoc{
                if let docUrl = pdf.documentURL{
                    let items = [docUrl]
                    let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    if let pop = ac.popoverPresentationController{
                        pop.barButtonItem = sender as? UIBarButtonItem
                    }
                    self.present(ac, animated: true, completion: nil)
                }
                else{
                    if let url = self.pdfUrl{
                        let items = [url]
                        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                        if let pop = ac.popoverPresentationController{
                            pop.barButtonItem = sender as? UIBarButtonItem
                        }
                        self.present(ac, animated: true, completion: nil)
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Zipped PDF", style: .default, handler: {
            (action) in
            do{
                if let pdf = self.PDFDoc{
                    if let docUrl = pdf.documentURL{
                        let zip = try Zip.quickZipFiles([docUrl], fileName: "archive")
                        let items = [zip]
                        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                        if let pop = ac.popoverPresentationController{
                            pop.barButtonItem = sender as? UIBarButtonItem
                        }
                        self.present(ac, animated: true, completion: nil)
                    }
                    else{
                        if let url = self.pdfUrl{
                            let zip = try Zip.quickZipFiles([url], fileName: "archive.zip")
                            let items = [zip]
                            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                            if let pop = ac.popoverPresentationController{
                                pop.barButtonItem = sender as? UIBarButtonItem
                            }
                            self.present(ac, animated: true, completion: nil)
                        }
                    }
                }
            }
            catch{
            }
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("image", comment: "image"), style: .default, handler: {
            (a) in
            let items = self.images
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            if let pop = ac.popoverPresentationController{
                pop.barButtonItem = sender as? UIBarButtonItem
            }
            self.present(ac, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: CANCEL, style: .cancel, handler: {
            (a) in
        }))
        if let pop = alert.popoverPresentationController{
            pop.barButtonItem = sender as? UIBarButtonItem
        }
        present(alert, animated: true, completion: nil)
    }

    @IBAction func ocr(_ sender: Any) {
        let vision = Vision.vision()
        let textRecognizer = vision.onDeviceTextRecognizer()
        let vImage = VisionImage(image: images[slideshowView.currentPage])
        textRecognizer.process(vImage) {
            result, error in guard error == nil, let result = result else{
                let alert = UIAlertController(title: NSLocalizedString("noText", comment: "no text found"), message: NSLocalizedString("differentImage", comment: "Try a different image"), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ocr") as! OCRViewController
            vc.image = self.images[self.slideshowView.currentPage]
            vc.scannedText = result.text
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func addPageOrSignature(_ sender: Any) {
        let actionsheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionsheet.addAction(UIAlertAction(title: NSLocalizedString("markup", comment: "markup"), style: .default, handler: {
            (a) in
            if #available(iOS 13.0, *){
                self.addSignature()
            }
            else{
                let alert = UIAlertController(title: "Sorry this feature is not available", message: "This feature is only available on iOS 13.0 and higher", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    (a) in
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        actionsheet.addAction(UIAlertAction(title: NSLocalizedString("addCamera", comment: "add pages with camera"), style: .default, handler: {
            (action) in
            self.scanImage()
        }))
        actionsheet.addAction(UIAlertAction(title: NSLocalizedString("addPhotos", comment: "add pages from photos"), style: .default, handler: {
            (action) in
            self.selectImage()
        }))
        actionsheet.addAction(UIAlertAction(title: CANCEL, style: .cancel, handler: nil))
        if let pop = actionsheet.popoverPresentationController{
            pop.barButtonItem = sender as? UIBarButtonItem
        }
        present(actionsheet, animated: true, completion: nil)
    }

    func addSignature(){
        let ql = QLPreviewController()
        ql.dataSource = self
        ql.delegate = self
        ql.setEditing(true, animated: true)
        present(ql, animated: true, completion: nil)
    }

    func scanImage(){
        let scanner = ImageScannerController()
        scanner.modalPresentationStyle = .fullScreen
        scanner.imageScannerDelegate = self
        navigationController?.present(scanner, animated: true, completion: nil)
    }

    func selectImage(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true, completion: nil)
    }

    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        if results.doesUserPreferEnhancedImage {
            scannedImage = results.enhancedImage
        }
        else {
            scannedImage = results.scannedImage
        }
        scanner.dismiss(animated: true, completion: nil)
        let pdfPage = PDFPage(image: scannedImage)
        PDFDoc.insert(pdfPage!, at: PDFDoc.pageCount)
        if let pdfurl = pdfUrl{
            PDFDoc.write(to: pdfurl)
            callBack?()
        }
        else{
            PDFDoc.write(to: PDFDoc.documentURL!)
        }
        if isReadNamed {
            callBack?()
        }
    }

    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        scanner.dismiss(animated: true, completion: nil)
    }

    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
    }

    @IBAction func deleteFile(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("deletePDF", comment: "delete PDF?"), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("delete", comment: "delete"), style: .destructive, handler: {
            (action) in
            if let url = self.pdfUrl{
                do{
                    try FileManager.default.removeItem(at: url)
                    self.navigationController?.popViewController(animated: true)
                }
                catch{
                }
            }
            else{
                do{
                    try FileManager.default.removeItem(at: self.PDFDoc.documentURL!)
                    self.navigationController?.popViewController(animated: true)
                }
                catch{
                }
            }
        }))
        alert.addAction(UIAlertAction(title: CANCEL, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
extension SaveViewController: QLPreviewControllerDataSource{
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        var item: NSURL!
        if let pdfurl = pdfUrl{
            item = pdfurl as NSURL
        }
        else{
            item = PDFDoc!.documentURL! as NSURL
        }
        return item as QLPreviewItem
    }

}
extension SaveViewController: QLPreviewControllerDelegate{
    @available(iOS 13.0, *)
    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        return .updateContents
    }

    func previewController(_ controller: QLPreviewController, didUpdateContentsOf previewItem: QLPreviewItem) {
        let url = previewItem.previewItemURL
        self.PDFDoc = PDFDocument(url: url!)
    }

    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        callBack?()
    }

}
extension SaveViewController: ImageSlideshowDelegate{
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print(page)
    }

}
extension SaveViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        let scanner = ImageScannerController(image: image, delegate: self)
        scanner.modalPresentationStyle = .fullScreen
        present(scanner, animated: true, completion: nil)
    }

}
