//
// Documents.swift
//

import Foundation
import PDFKit
import CloudKit


let CANCEL = NSLocalizedString("cancel", comment: "cancel")

class Documents {
    class func getTime() -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let dateString = formatter.string(from: now)
        return dateString
    }
    
    class func getDocuments() -> [PdfAndThumb] {
        var contents = [PdfAndThumb]()
        var urls = [URL]()
        do {
            let docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            print(docURL)
           let docUrls = try (FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: nil, options: [FileManager.DirectoryEnumerationOptions.skipsHiddenFiles, FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants]))
            urls = docUrls.filter{$0.pathExtension == "pdf"}
          
        } catch {
            print("Fetch pdfs error")
            
        }
        for url in urls{
            let pdf = PDFDocument(url: url)
            if let page1 = pdf!.page(at: 0) {
                let thumb = page1.thumbnail(of: CGSize(
                    width: 500,
                    height: 500), for: .trimBox)
                 let pt = PdfAndThumb.init(pdf: pdf!, thumb: thumb)
                contents.append(pt)
            }
        }
        let content = contents.sorted(by: {$0.pdf.documentAttributes![PDFDocumentAttribute.creationDateAttribute] as! Date > $1.pdf.documentAttributes![PDFDocumentAttribute.creationDateAttribute] as! Date})
        return content
    }
    
    class func checkSameName(fileName: String) -> Bool {
        do {
            let docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            print(docURL)
           let docUrls = try (FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: nil, options: [FileManager.DirectoryEnumerationOptions.skipsHiddenFiles, FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants]))
           let urls = docUrls.filter{$0.pathExtension == "pdf"}
            for fileURL in urls {
                var title = fileURL.path.components(separatedBy: "Documents/")[1]
                title = String(Array(title)[0..<(title.count-4)])
                if fileName == title {
                    return true
                }
            }
        } catch {
            print("Fetch pdfs error")
        }
       /* for fileURL in documents {
            var title = fileURL.path.components(separatedBy: "Documents/")[1]
            title = String(Array(title)[0..<(title.count-4)])
            if fileName == title {
                return true
            }
        }
        return false*/
        return false
    }
    

    
}
