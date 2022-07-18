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

        // Write Logs in Logs File with message
        SLog.shared.log(text: "Hello Buddy")
        SLog.shared.log(text: "Hi")
        SLog.shared.log(text: "Yes Please")
        SLog.shared.log(text: "No")

        // function Textview Editing Calls
        SLog.shared.setpassword(password: "QWERTY")

        // set tittle
        SLog.shared.setTittle(title: "Map App")

        // set days
        SLog.shared.setDaysForLog(numberOfDays: 8)

        // set tag
        SLog.shared.setDefaultTag(tagName: "Logs")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

