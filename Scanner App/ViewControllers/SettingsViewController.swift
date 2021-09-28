//
//  SettingsViewController.swift
//  Scanner App
//
//
import UIKit
import MessageUI
import SafariServices
class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate  {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let titles = [NSLocalizedString("terms", comment: "terms"),NSLocalizedString("pp", comment: "privacy"),NSLocalizedString("contact", comment: "contact")]
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = titles[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        navigationController?.navigationBar.tintColor = UIColor(named: "Blue")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.barTintColor = UIColor.systemBackground
        }
        else {
            navigationController?.navigationBar.barTintColor = UIColor.white
        }
        // Do any additional setup after loading the view.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            if let url = URL(string: ""){
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                let vc = SFSafariViewController(url: url, configuration: config)
                present(vc, animated: true, completion: nil)
            }
        }
        if indexPath.row == 1{
            if let url = URL(string: ""){
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                let vc = SFSafariViewController(url: url, configuration: config)
                present(vc, animated: true, completion: nil)
            }
        }
        if indexPath.row == 2{
            if MFMailComposeViewController.canSendMail(){
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([""])
                mail.setSubject("Support")
                present(mail, animated: true, completion: nil)
            }
            else{
                if let url = URL(string: ""){
                    UIApplication.shared.open(url, options: [ : ], completionHandler: nil)
                }
            }
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
