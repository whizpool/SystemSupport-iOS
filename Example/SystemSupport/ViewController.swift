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
//        SLog.shared.setpassword(password: "QWERTY")

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
        SLog.shared.log(text: "show log btn pressed")
    }

    //****************************************************
    
    @IBAction func deleteLogBtn(_ sender : UIButton)
    {
        SLog.shared.deleteOldLogs(forcefullyDelete: true)
    }
    
    //****************************************************
    
    @IBAction func sendLogBtn(_ sender : UIButton)
    {
        SLog.shared.log(text: "send log btn pressed")
//        SLog.shared.
        
        let bundle = Bundle(for: NewController.self)
        let controllerView = NewController(nibName: "NewController", bundle: bundle)
        controllerView.modalPresentationStyle = .fullScreen
        
        let Uimage = #imageLiteral(resourceName: "testImg")
        controllerView.setCloseBtnImage(img: Uimage)

        controllerView.setMainBackgroundColor(backgroundColor: .lightGray)
        controllerView.setTitleColor(color: .red)
        controllerView.setTitleFont(fontName: "kefa", fontSize: 24)

        controllerView.setTextViewBackgroundColor(backgroundColor: .darkGray)
        controllerView.setTextViewTextColor(color: .green)
        controllerView.setTextViewBorderColor(borderColor: .red)
        controllerView.setTextViewFont(fontName: "kefa", fontSize: 15)

        controllerView.setDoneBtnViewColor(color: .green)
        controllerView.setDoneBtnTextColor(color: .red)
        controllerView.setDoneBtnBorderColor(color: .yellow)
        
        self.present(controllerView, animated: true, completion: nil)
        
        
    }
}

