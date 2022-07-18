//
//  NewController.swift
//  SystemSupport
//
//  Created by Macbook on 18/07/2022.
//

import UIKit
import MessageUI
import SSZipArchive

class NewController: UIViewController {

    
    // ********************* Outlets *********************//
    // MARK: - View controller Outlets
    
    // Tittle Label Outlet
    @IBOutlet var titile_lbl: UILabel!
    
    // Send Button outlet
    @IBOutlet var send_btn_outlet: UIButton!
    
    // skip button outlet
    @IBOutlet var skip_btn_outlet: UIButton!
    
    // main view outlet
    @IBOutlet var main_dialogBox_view: UIView!
    
    // Bugs TextView Outlet
    @IBOutlet var BugsTextview: UITextView!
    
    // Close Btn outlet
    @IBOutlet var close_btn_outlet: UIButton!
    
    
    
    // ********************* ViewDidLoad *********************//
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // dailog box hidden
        main_dialogBox_view.isHidden = true
        
        // Textview Editing function
        textviewEditing()
        
        // calling function of NewControllerInitilizer() for showing main view
        NewControllerInitilizer()
        
    }
    
    // ********************* Actions *********************//
    
    // Send Button Action where we can check textview is empty or check text is equal to placeholder when both condition are ture we can show alert message Bug Detail is Missing if condition is false then we can proceed further
    
    
    
    
    
    @IBAction func send_btn_action(_ sender: UIButton) {
        if BugsTextview.text.isEmpty || BugsTextview.text == SLog.shared.prefilledTextviewText{
            
            // show alert when textview is empty
            let alert = UIAlertController(title: "Alert", message: "Bug Detail is Missing", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            let recieverEmail = SLog.shared.sendToEmail
            guard MFMailComposeViewController.canSendMail()  else {
                return
            }
            let composer = MFMailComposeViewController()
            composer.mailComposeDelegate = self
            composer.setToRecipients([recieverEmail])
            composer.setSubject(SLog.shared.emailSubject)
            composer.setMessageBody(BugsTextview.text, isHTML: true)
            let filePath = SLog.shared.getRootDirPath()
            let url = URL(string: filePath)
            let zipPath = url!.appendingPathComponent(SLog.shared.appendZipFolderPath)
            do {
                self.createPasswordProtectedZipLogFile(at: zipPath.path, composer: composer)
                
                if MFMailComposeViewController.canSendMail() {
                    self.present(composer, animated: true)
                }
            }
            
        }
    }
    
    // Skip Button Action where we cannot check textview text is equal to textview placeholder then send messageBody empty
    @IBAction func skip_btn_action(_ sender: UIButton) {
        let recieverEmail = SLog.shared.sendToEmail
        guard MFMailComposeViewController.canSendMail()  else {
            return
        }
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients([recieverEmail])
        composer.setSubject(SLog.shared.emailSubject)
        composer.setMessageBody("", isHTML: true)
        let filePath = SLog.shared.getRootDirPath()
        let url = URL(string: filePath)
        let zipPath = url!.appendingPathComponent(SLog.shared.appendZipFolderPath)
        do {
            self.createPasswordProtectedZipLogFile(at: zipPath.path, composer: composer)
            
            if MFMailComposeViewController.canSendMail() {
                self.present(composer, animated: true)
            }
        }
    }
    
    // close Button Action will close the main view
    @IBAction func close_btn_action(_ sender: UIButton) {
        main_dialogBox_view.isHidden = true
        view.backgroundColor = UIColor.init(named: "gray5")
        self.dismiss(animated: true, completion: nil)
    }
    
    func NewControllerInitilizer(){
        
        close_btn_outlet.setTitle("", for: .normal)
        main_dialogBox_view.isHidden = false
        //view.backgroundColor = UIColor(white: 1, alpha: 0.4)
        view.backgroundColor = UIColor.init(white: 0.7, alpha: 0.7)
    }
    
    
    
    // Function create zip and create password on it
    func createPasswordProtectedZipLogFile(at logfilePath: String, composer viewController: MFMailComposeViewController)
    {
        var isZipped:Bool = false
        // calling combine all files into one file
        SLog.shared.combineLogFiles { filePath in
            //
            SLog.shared.self.makeJsonFile { jsonfilePath in
                //
                let contentsPath = logfilePath
                
                // create a json file and call a function of makeJsonFile
                if FileManager.default.fileExists(atPath: contentsPath)
                {
                    let createZipPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(SLog.shared.temp_zipFileName).path
                    if SLog.shared.password.isEmpty{
                        isZipped = SSZipArchive.createZipFile(atPath: createZipPath, withContentsOfDirectory: contentsPath)
                    }
                    else{
                        isZipped = SSZipArchive.createZipFile(atPath: createZipPath, withContentsOfDirectory: contentsPath, keepParentDirectory: true, withPassword: SLog.shared.password)
                    }
                    
                    if isZipped {
                        var data = NSData(contentsOfFile: createZipPath) as Data?
                        if let data = data
                        {
                            viewController.addAttachmentData(data, mimeType: "application/zip", fileName: SLog.shared.zipFileName)
                        }
                        data = nil
                    }
                }
            }
        }
        
        
    }
    
    
    
}
// ********************* Extensions *********************//

// Extension for mail composing delegate
extension NewController:MFMailComposeViewControllerDelegate{
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error{
            controller.dismiss(animated: true, completion: nil)
        }
        switch result {
        case .cancelled:
            print("cancel")
        case .saved:
            print("saved")
        case .sent:
            print("sent")
        case .failed:
            print("failed")
        default:
            print("default")
        }
        controller.dismiss(animated: true, completion: nil)
    }
}


// Extension for Textview Editing or Delegate
extension NewController:UITextViewDelegate{
    
    // setting textview, buttons colors and set app name to tittle label
    func textviewEditing(){
        
        // set textview delegate to self
        BugsTextview.delegate = self
        
        // set predefine or placeholder text to textview
        BugsTextview.text = SLog.shared.prefilledTextviewText
        
        // setting textview cornerRadius and give background color
        BugsTextview.layer.cornerRadius = 8
        BugsTextview.layer.masksToBounds = true
        BugsTextview.backgroundColor = SLog.shared.backgroundColor
        
        // setting Email Button background color and tint color
        BugsTextview.textColor = SLog.shared.textColor
        
        // Textview Border or corner radius
        BugsTextview.layer.borderColor = SLog.shared.borderColor
        BugsTextview.layer.borderWidth = 1.5
        BugsTextview.layer.cornerRadius = 8.0
        
        // Send Button Border or corner radius
        send_btn_outlet.layer.borderColor = SLog.shared.borderColor
        send_btn_outlet.layer.borderWidth = 1.5
        send_btn_outlet.layer.cornerRadius = 8.0
        
        // Skip Button Border or corner radius
        skip_btn_outlet.layer.borderColor = SLog.shared.borderColor
        skip_btn_outlet.layer.borderWidth = 1.5
        skip_btn_outlet.layer.cornerRadius = 8.0
        
        // main view corner radius
        main_dialogBox_view.layer.cornerRadius = 8.0
        main_dialogBox_view.backgroundColor = SLog.shared.backgroundColor
        
        // set appName to tittle label
        if SLog.shared.titleText == ""{
            let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
            titile_lbl.text = appName
        }
        else{
            titile_lbl.text = SLog.shared.titleText
        }
    }
    
    // when textview is Editing
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == SLog.shared.prefilledTextviewText{
            textView.text = ""
        }
    }
    
    // when textview text is change
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
        }
        return true
    }
    
    // when textview text is end
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == ""{
            textView.text = SLog.shared.prefilledTextviewText
        }
    }
    // function for setting color of theme
    func setThemeColor(backgroundColor:UIColor,textColor:UIColor,BorderColor:UIColor){
        
        titile_lbl.textColor = textColor
        send_btn_outlet.tintColor = textColor
        send_btn_outlet.backgroundColor = backgroundColor
        send_btn_outlet.layer.borderColor = BorderColor.cgColor
        
        skip_btn_outlet.tintColor = textColor
        skip_btn_outlet.backgroundColor = backgroundColor
        skip_btn_outlet.layer.borderColor = BorderColor.cgColor
        
        main_dialogBox_view.backgroundColor = backgroundColor

        
        BugsTextview.textColor = textColor
        BugsTextview.backgroundColor = backgroundColor
        BugsTextview.layer.borderColor = BorderColor.cgColor
    }



}
