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
    @IBOutlet weak var titleLbl: UILabel!
    
    // Send Button outlet
    @IBOutlet weak var sendBtnLbl: UILabel!
    @IBOutlet weak var sendBtnView: UIView!
    
    // skip button outlet
//    @IBOutlet weak var skip_btn_outlet: UIButton!
    
    // main view outlet
    @IBOutlet weak var mainDialogBoxView: UIView!
    @IBOutlet weak var textFieldView: UIView!
    
    // Bugs TextView Outlet
    @IBOutlet weak var bugsTextview: GrowingTextView!
    
    // Close Btn outlet
    @IBOutlet weak var closeBtnOutlet: UIButton!
    
    @IBOutlet weak var closeBtnImg : UIImageView!
    
    
    var bDarkMode = false
    var sendBtnBorderColor : UIColor? = nil
    var textFieldBorderColor : UIColor? = nil
    
    //MARK: - // ********************* ViewDidLoad *********************// -
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // dailog box hidden
        textFieldView.isHidden = true
        
        // Textview Editing function
        textviewEditing()
        
        // calling function of NewControllerInitilizer() for showing main view
        newControllerInitilizer()
        
        self.bDarkMode = self.checkDarkMode()
    }
    
    // MARK: - // ********************* ACTION MEHTODS *********************// -
    
    @IBAction func sendBtnAction(_ sender: UIButton)
    {
        // Send Button Action where we can check textview is empty or check text is equal to placeholder when both condition are ture we can show alert message Bug Detail is Missing if condition is false then we can proceed further
        
        if bugsTextview.text.isEmpty || bugsTextview.text == SLog.shared.prefilledTextviewText || bugsTextview.text.count <= 10
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
                
                let alert = UIAlertController(title: "Alert", message: "Email not configure", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let composer = MFMailComposeViewController()
            composer.mailComposeDelegate = self
            composer.setToRecipients([recieverEmail])
            composer.setSubject(SLog.shared.emailSubject)
            composer.setMessageBody(bugsTextview.text, isHTML: true)
            let filePath = SLog.shared.getRootDirPath()
            let url = URL(string: filePath)
            let zipPath = url!.appendingPathComponent("/\(SLog.shared.LOG_FILE_New_Folder_DIR_NAME)")
            do {
                self.createPasswordProtectedZipLogFile(at: zipPath.path, composer: composer)

                if MFMailComposeViewController.canSendMail() {
                    self.present(composer, animated: true)
                }
            }
        }
    }
    
    //****************************************************
    
    // close Button Action will close the main view
    @IBAction func closeBtnAction(_ sender: UIButton) {
        textFieldView.isHidden = true
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - // ********************* Methods *********************// -
    
    func newControllerInitilizer() {
        
        closeBtnOutlet.setTitle("", for: .normal)
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
            SLog.shared.makeJsonFile { jsonfilePath in
                //
                let contentsPath = logfilePath
                
                // create a json file and call a function of makeJsonFile
                if FileManager.default.fileExists(atPath: contentsPath)
                {
                    let createZipPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(SLog.shared.finalLogFileName_After_Combine).zip").path
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
                            viewController.addAttachmentData(data, mimeType: "application/zip", fileName: ("\(SLog.shared.finalLogFileName_After_Combine).zip"))
                        }
                        data = nil
                    }
                }
            }
        }
    }
    
    //****************************************************
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        self.bDarkMode = self.checkDarkMode()
        self.textFieldView.layer.borderColor = SLog.shared.borderColor
        if self.textFieldBorderColor != nil
        {
            self.textFieldView.layer.borderColor = self.textFieldBorderColor?.cgColor
        }
        else if self.bDarkMode
        {
            self.textFieldView.layer.borderColor = SLog.shared.borderColorDark
        }
        
        // Send Button Border or corner radius
        self.sendBtnView.layer.borderColor = SLog.shared.borderColor
        if self.sendBtnBorderColor != nil
        {
            self.sendBtnView.layer.borderColor = self.sendBtnBorderColor?.cgColor
        }
        else if self.bDarkMode
        {
            self.sendBtnView.layer.borderColor = SLog.shared.borderColorDark
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
extension NewController:UITextViewDelegate {
    
    // setting textview, buttons colors and set app name to tittle label
    func textviewEditing() {
        
        DispatchQueue.main.async {
            //
            self.bugsTextview.delegate = self
            self.bugsTextview.layer.cornerRadius = 12.0
            self.bugsTextview.maxHeight = 270
            self.bugsTextview.minHeight = 100
            self.bugsTextview.trimWhiteSpaceWhenEndEditing = true
            self.bugsTextview.placeholder = SLog.shared.prefilledTextviewText
            self.bugsTextview.placeholderColor = UIColor(white: 0.8, alpha: 1.0)
    //        self.BugsTextview.font = UIFont.systemFont(ofSize: 15)
            self.bugsTextview.translatesAutoresizingMaskIntoConstraints = false
            
            
            // Send Button Border or corner radius
            
//            self.sendBtnView.layer.borderColor = UIColor.white.cgColor
            self.sendBtnView.layer.borderWidth = 1.0
            self.sendBtnView.layer.cornerRadius = 12.0
            
            // main view corner radius
            self.textFieldView.layer.borderWidth = 1.0
            self.textFieldView.layer.cornerRadius = 12.0
//            self.textFieldView.backgroundColor = SLog.shared.backgroundColor
            
//            main_dialogBox_view.layer.borderWidth = 1.0
            self.mainDialogBoxView.layer.cornerRadius = 12.0
//            self.main_dialogBox_view.backgroundColor = SLog.shared.backgroundColor
//            self.titile_lbl.textColor = SLog.shared.textColor
            
            
            
            // set the image of the close Btn
            if SLog.shared.closeBtnIcon != nil
            {
                self.closeBtnImg.image = SLog.shared.closeBtnIcon
            }
                
            
            
            
            
            // set appName to tittle label
            if SLog.shared.titleText.isEmpty
            {
                let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
                self.titleLbl.text = appName
            }
            else
            {
                self.titleLbl.text = SLog.shared.titleText
            }
            
            // set Send button Lable
            if SLog.shared.sendBtnText.isEmpty
            {
                self.sendBtnLbl.text = "Send"
            }
            else
            {
                self.sendBtnLbl.text = SLog.shared.sendBtnText
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
    
    // MARK: - // ********************* Public Methods *********************// -
    
    // ********************* Main Alert View *********************
    
    // setting background color for alert view
    public func setMainBackgroundColor (backgroundColor : UIColor)
    {
        DispatchQueue.main.async {
            //
            self.mainDialogBoxView.backgroundColor = backgroundColor
        }
    }
    
    // ********************* Title View *********************
    
    // setting title color
    public func setTitleColor (color : UIColor)
    {
        DispatchQueue.main.async {
            //
            self.titleLbl.textColor = color
        }
    }
    
    //****************************************************
    
    // setting title Font
    public func setTitleFont (fontName : String)
    {
        DispatchQueue.main.async {
            //
            let currentFontSize = self.titleLbl.font.pointSize
            self.titleLbl.font = UIFont(name: fontName, size: currentFontSize)
        }
    }
    
    //****************************************************
    
    // setting title Font
    public func setTitleFontSize (fontSize: CGFloat)
    {
        DispatchQueue.main.async {
            //
            self.titleLbl.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
    
    // ********************* Text Field View *********************
    
    // setting background color for TEXT field
    public func setTextFieldBackgroundColor (backgroundColor:UIColor)
    {
        DispatchQueue.main.async {
            //
            self.bugsTextview.backgroundColor = backgroundColor
            self.textFieldView.backgroundColor = backgroundColor
        }
    }
    
    //****************************************************
    
    // setting border color for TEXT field
    public func setTextFieldBorderColor (borderColor:UIColor)
    {
        DispatchQueue.main.async {
            //
            self.textFieldBorderColor = borderColor
            self.textFieldView.layer.borderColor = borderColor.cgColor
        }
    }
    
    //****************************************************
    
    // setting background color for TEXT view
    public func setTextFieldTextColor (color:UIColor)
    {
        DispatchQueue.main.async {
            //
            self.bugsTextview.textColor = color
        }
    }
    
    //****************************************************
    
    // setting text field Font
    public func setTextFieldFont (fontName : String)
    {
        DispatchQueue.main.async {
            //
            let currentFontSize = self.bugsTextview.font?.pointSize
            self.bugsTextview.font = UIFont(name: fontName, size: currentFontSize!)
        }
    }
    
    //****************************************************
    
    // setting text field Font
    public func setTextFieldFontSize (fontSize: CGFloat)
    {
        DispatchQueue.main.async {
            //
            self.bugsTextview.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
    
    // ********************* Send Btn View *********************
    
    // setting background color for Send Btn view
    public func setSendBtnViewColor (color:UIColor)
    {
        DispatchQueue.main.async {
            //
            self.sendBtnView.backgroundColor = color
        }
    }
    
    //****************************************************
    
    // set Send Btn Text Color
    public func setSendBtnTextColor (color:UIColor)
    {
        DispatchQueue.main.async {
            //
            self.sendBtnLbl.textColor = color
        }
    }
    
    //****************************************************
    
    // set Send Btn view border Color
    public func setSendBtnBorderColor (color:UIColor)
    {
        DispatchQueue.main.async {
            //
            self.sendBtnBorderColor = color
            self.sendBtnView.layer.borderColor = color.cgColor
        }
    }
    
    //****************************************************
    
    // setting Send btn Font
    public func setSendBtnFont (fontName : String)
    {
        DispatchQueue.main.async {
            //
            let currentFontSize = self.sendBtnLbl.font.pointSize
            self.sendBtnLbl.font = UIFont(name: fontName, size: currentFontSize)
        }
    }
    
    //****************************************************
    
    // setting Send btn Font
    public func setSendBtnFontSize (fontSize: CGFloat)
    {
        DispatchQueue.main.async {
            //
            self.sendBtnLbl.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
    
    //****************************************************
    
    func checkDarkMode() -> Bool
    {
        if #available(iOS 12.0, *) {
            if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyle.dark)
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
