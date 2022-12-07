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
        
        SLog.shared.initilization()
        
        // function Textview Editing Calls
//        SLog.shared.setPassword(password: "QWERTY")

        // set tittle
        SLog.shared.setTittle(title: "Map App")

        // set days
        SLog.shared.setDaysForLog(numberOfDays: 2)

        // set tag
        SLog.shared.setDefaultTag(tagName: "Logs")
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
        SLog.shared.deleteOldLogs(forcefullyDelete: true)
    }
    
    //****************************************************
    
    @IBAction func sendLogBtn(_ sender : UIButton)
    {
//        SLog.shared.summaryLog(text: "send log btn pressed")
        SLog.shared.detailLog(text: "detail log", writeIntoFile: true)
        
        SLog.shared.setTittle(title: "Title Here")
        SLog.shared.setSendButtonText(text: "Send Button Text")
        SLog.shared.setEmail(text: "hamza.mughal@whizpool.com")
        SLog.shared.setPlaceHolder(text: "Enter Your Bug Detail")
        SLog.shared.setLogFileName(text: "FINALLOG")
        
        
        let img = #imageLiteral(resourceName: "testImg")
//        SLog.shared.setCloseBtnImage(img: img)
        
        
        
        
        
        
        let bundle = Bundle(for: NewController.self)
        let controllerView = NewController(nibName: "NewController", bundle: bundle)
        controllerView.modalPresentationStyle = .overCurrentContext
        
        
//        controllerView.setMainBackgroundColor(backgroundColor: .white)


//        controllerView.setTitleColor(color: .red)
//
//        controllerView.setTitleFont(fontName: "kefa")
//        controllerView.setTitleFontSize(fontSize: 16)
//
//        controllerView.setTextFieldBackgroundColor(backgroundColor: .darkGray)
//        controllerView.setTextFieldTextColor(color: .green)
//        controllerView.setTextFieldBorderColor(borderColor: .red)
//
//        controllerView.setTextFieldFont(fontName: "kefa")
//        controllerView.setTextFieldFontSize(fontSize: 12)
//
//        controllerView.setSendBtnViewColor(color: .green)
//        controllerView.setSendBtnTextColor(color: .red)
//        controllerView.setSendBtnBorderColor(color: .red)
        
        self.present(controllerView, animated: true, completion: nil)
    }
}

