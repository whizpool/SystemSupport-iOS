//
//  ViewController.swift
//  SystemSupport
//
//  Created by HamzaMalik9805 on 07/18/2022.
//  Copyright (c) 2022 HamzaMalik9805. All rights reserved.
//

import UIKit
import SystemSupport

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        SLog.shared.initilization()
        
        // function Textview Editing Calls
//        SLog.shared.setPassword(password: "QWERTY")
//
//        // set Title
//        SLog.shared.setTitle(title: "Map App")
//
//        // set days
//        SLog.shared.setDaysForLog(numberOfDays: 2)
//
//        // set email
//        SLog.shared.setEmail(text: "hamza.mughal@whizpool.com")
//
//        // set email Subject
//        SLog.shared.setSubjectToEmail(sub: "BUG REPORT ")
//
//        // set place holder for the text views
//        SLog.shared.setPlaceHolder(text: "Enter Your Bug Detail")
//
//        // set final log file name which is going to be emailed
//        SLog.shared.setLogFileName(text: "finalLog")
 
        // set alert view background color
//        SLog.shared.setMainBackgroundColor(backgroundColor: .gray)
//
//        // set image to the close button
//        let img = #imageLiteral(resourceName: "testImg")
//        SLog.shared.setCloseBtnImage(img: img)
//
//        // set text view text, font name, font size, border color and text color
//        SLog.shared.setTextViewBackgroundColor(backgroundColor: .brown)
//        SLog.shared.setTextViewBorderColor(borderColor: .green)
//        SLog.shared.setTextViewTextColor(color: .green)
//        SLog.shared.setTextViewFont(fontName: "Marker Felt Thin")
//        SLog.shared.setTextViewFontSize(fontSize: 17)
//
//        // set title text, font name, font size and text color
//        SLog.shared.setTitle(title: "Title Here")
//        SLog.shared.setTitleFont(fontName: "Marker Felt Thin")
//        SLog.shared.setTitleFontSize(fontSize: 22)
//        SLog.shared.setTitleColor(color: .purple)
//
//        // set send button view text, font name, font size, border color and text color
//        SLog.shared.setSendButtonText(text: "Send Button Text")
//        SLog.shared.setSendBtnFont(fontName: "Marker Felt Thin")
//        SLog.shared.setSendBtnFontSize(fontSize: 30)
//        SLog.shared.setSendBtnTextColor(color: .green)
//        SLog.shared.setSendButtonBackgroundColor(backgroundColor: .black)
//        SLog.shared.setSendBtnBorderColor(color: .red)
    }

    // ****************************************************
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ****************************************************
    
    @IBAction func showlogBtn(_ sender : UIButton)
    {
        SLog.shared.summaryLog(text: "show log btn pressed")
    }

    //****************************************************
    
    @IBAction func deleteLogBtn(_ sender : UIButton)
    {
//        SLog.shared.deleteOldLogs(forcefullyDelete: true)
    }
    
    //****************************************************
    
    @IBAction func sendLogBtn(_ sender : UIButton)
    {
        SLog.shared.summaryLog(text: "summary log here")
        SLog.shared.detailLog(text: "detail log here", writeIntoFile: false)
        
        
        let bundle = Bundle(for: AlertViewController.self)
        let controllerView = AlertViewController(nibName: "AlertViewController", bundle: bundle)
        controllerView.modalPresentationStyle = .overCurrentContext
        self.present(controllerView, animated: true, completion: nil)
    }
}

