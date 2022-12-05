//
//  NewController.swift
//  SystemSupport
//
//  Created by Macbook on 18/07/2022.
//

import UIKit
import MessageUI
import SSZipArchive

public class NewController: UIViewController {

    
    // ********************* Outlets *********************//
    // MARK: - View controller Outlets -
    
    // Tittle Label Outlet
    @IBOutlet weak var titile_lbl: UILabel!
    
    // Send Button outlet
    @IBOutlet weak var sendBtnLbl: UILabel!
    @IBOutlet weak var sendBtnView: UIView!
    
    // skip button outlet
//    @IBOutlet weak var skip_btn_outlet: UIButton!
    
    // main view outlet
    @IBOutlet weak var main_dialogBox_view: UIView!
    @IBOutlet weak var textFieldView: UIView!
    
    // Bugs TextView Outlet
    @IBOutlet weak var BugsTextview: UITextView!
    
    // Close Btn outlet
    @IBOutlet weak var close_btn_outlet: UIButton!
    
    @IBOutlet weak var closeBtnImg : UIImageView!
    
    
    var bDarkMode = false
    
    //MARK: - // ********************* ViewDidLoad *********************// -
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // dailog box hidden
        textFieldView.isHidden = true
        
        // Textview Editing function
        textviewEditing()
        
        // calling function of NewControllerInitilizer() for showing main view
        NewControllerInitilizer()
        
        self.bDarkMode = self.checkDarkMode()
        
    }
    
    // MARK: - ACTION MEHTODS -
    
    @IBAction func send_btn_action(_ sender: UIButton)
    {
        // Send Button Action where we can check textview is empty or check text is equal to placeholder when both condition are ture we can show alert message Bug Detail is Missing if condition is false then we can proceed further
        
        if BugsTextview.text.isEmpty || BugsTextview.text == SLog.shared.prefilledTextviewText || BugsTextview.text.count <= 10
        {
            // show alert when textview is empty
            let alert = UIAlertController(title: "Alert", message: "Bug Detail is Missing", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
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
    
    //****************************************************
    
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
    
    //****************************************************
    
    // close Button Action will close the main view
    @IBAction func close_btn_action(_ sender: UIButton) {
        textFieldView.isHidden = true
        view.backgroundColor = UIColor.init(named: "gray5")
        self.dismiss(animated: true, completion: nil)
    }
    
    //****************************************************
    
    func NewControllerInitilizer(){
        
        close_btn_outlet.setTitle("", for: .normal)
        textFieldView.isHidden = false
        //view.backgroundColor = UIColor(white: 1, alpha: 0.4)
        view.backgroundColor = UIColor.init(white: 0.7, alpha: 0.7)
    }
    
    //****************************************************
    
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
extension NewController:MFMailComposeViewControllerDelegate
{
    public func mailComposeController (_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let _ = error
        {
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
    func textviewEditing() {
        
        DispatchQueue.main.async {
            // set textview delegate to self
            self.BugsTextview.delegate = self
            
            // set predefine or placeholder text to textview
            self.BugsTextview.text = SLog.shared.prefilledTextviewText
            
            // setting textview cornerRadius and give background color
            self.BugsTextview.layer.cornerRadius = 12
            self.BugsTextview.layer.masksToBounds = true
//            self.BugsTextview.backgroundColor = SLog.shared.backgroundColor
            
            // setting Email Button background color and tint color
//            self.BugsTextview.textColor = SLog.shared.textColor
            
            // Textview Border or corner radius
//            self.BugsTextview.layer.borderColor = SLog.shared.borderColor
            self.BugsTextview.layer.borderWidth = 1.0
            self.BugsTextview.layer.cornerRadius = 12.0
            
            // Send Button Border or corner radius
            
            self.sendBtnView.layer.borderColor = UIColor.black.cgColor
            if self.bDarkMode
            {
                self.sendBtnView.layer.borderColor = UIColor.white.cgColor
            }
            
            self.sendBtnView.layer.borderWidth = 1.0
            self.sendBtnView.layer.cornerRadius = 12.0
            
//            Skip Button Border or corner radius
//            skip_btn_outlet.layer.borderColor = SLog.shared.borderColor
//            skip_btn_outlet.layer.borderWidth = 1.0
//            skip_btn_outlet.layer.cornerRadius = 12.0
            
            // main view corner radius
            self.textFieldView.layer.borderWidth = 1.0
            self.textFieldView.layer.cornerRadius = 12.0
//            self.textFieldView.backgroundColor = SLog.shared.backgroundColor
            
//            main_dialogBox_view.layer.borderWidth = 1.0
            self.main_dialogBox_view.layer.cornerRadius = 12.0
//            self.main_dialogBox_view.backgroundColor = SLog.shared.backgroundColor
//            self.titile_lbl.textColor = SLog.shared.textColor
            
            // set appName to tittle label
            if SLog.shared.titleText == ""
            {
                let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
                self.titile_lbl.text = appName
            }
            else
            {
                self.titile_lbl.text = SLog.shared.titleText
            }
        }
    }
    
    //****************************************************
    
    // when textview is Editing
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == SLog.shared.prefilledTextviewText{
            textView.text = ""
        }
    }
    
    //****************************************************
    
    // when textview text is change
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
        }
        return true
    }
    
    //****************************************************
    
    // when textview text is end
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == ""{
            textView.text = SLog.shared.prefilledTextviewText
        }
    }
    
    // ********************* Main Alert View *********************
    
    // setting background color for alert view
    public func setMainBackgroundColor (backgroundColor:UIColor)
    {
        DispatchQueue.main.async {
            //
            self.main_dialogBox_view.backgroundColor = backgroundColor
        }
    }
    
    //****************************************************
    
    // setting title color
    public func setTitleColor (color:UIColor)
    {
        DispatchQueue.main.async {
            //
            self.titile_lbl.textColor = color
        }
    }
    
    //****************************************************
    
    // setting title Font
    public func setTitleFont (fontName : String, fontSize: CGFloat)
    {
        DispatchQueue.main.async {
            //
            self.titile_lbl.font = UIFont(name: fontName, size: fontSize)
        }
    }
    
    // ********************* Cloase Btn Image View *********************
    
    // setting image for the close button
    public func setCloseBtnImage (img : UIImage)
    {
        DispatchQueue.main.async {
            //
            self.closeBtnImg.image = img
        }
    }
    
    // ********************* Text Field View *********************
    
    // setting background color for TEXT field
    public func setTextViewBackgroundColor (backgroundColor:UIColor)
    {
        DispatchQueue.main.async {
            //
            self.BugsTextview.backgroundColor = backgroundColor
        }
    }
    
    //****************************************************
    
    // setting border color for TEXT field
    public func setTextViewBorderColor (borderColor:UIColor)
    {
        DispatchQueue.main.async {
            //
            self.textFieldView.layer.borderColor = borderColor.cgColor
        }
    }
    
    //****************************************************
    
    // setting background color for TEXT view
    public func setTextViewTextColor (color:UIColor)
    {
        DispatchQueue.main.async {
            //
            self.BugsTextview.textColor = color
        }
    }
    
    //****************************************************
    
    // setting text field Font
    public func setTextViewFont (fontName : String, fontSize: CGFloat)
    {
        DispatchQueue.main.async {
            //
            self.BugsTextview.font = UIFont(name: fontName, size: fontSize)
        }
    }
    
    // ********************* Done Btn View *********************
    
    // setting background color for Send Btn view
    public func setDoneBtnViewColor (color:UIColor)
    {
        DispatchQueue.main.async {
            //
            self.sendBtnView.backgroundColor = color
        }
    }
    
    //****************************************************
    
    // set Done Btn Text Color
    public func setDoneBtnTextColor (color:UIColor)
    {
        DispatchQueue.main.async {
            //
            self.sendBtnLbl.textColor = color
        }
    }
    
    //****************************************************
    
    // set Done Btn view border Color
    public func setDoneBtnBorderColor (color:UIColor)
    {
        DispatchQueue.main.async {
            //
            self.sendBtnView.layer.borderColor = color.cgColor
        }
    }
    
    //****************************************************
    
    // setting Done btn Font
    public func setDoneBtnFont (fontName : String, fontSize: CGFloat)
    {
        DispatchQueue.main.async {
            //
            self.sendBtnLbl.font = UIFont(name: fontName, size: fontSize)
        }
    }
    
    //****************************************************
    
    func checkDarkMode() -> Bool
    {
        if #available(iOS 12.0, *) {
            if( self.traitCollection.userInterfaceStyle == UIUserInterfaceStyle.dark)
            {
                return true
            }
            else
            {
                return false
            }
        }
        
        return false
    }
}
