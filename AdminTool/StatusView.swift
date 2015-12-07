//
//  StatusView.swift
//  AdminTool
//
//  Created by jnvb on 2015. 12. 5..
//  Copyright © 2015년 jnvb. All rights reserved.
//

import UIKit

class StatusView: UIViewController
{
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var screenShotBtn: UIButton!
    @IBOutlet weak var processBtn: UIButton!
    @IBOutlet weak var sendMessageBtn: UIButton!
    @IBOutlet weak var turnOffBtn: UIButton!
    
    var computer:String?
    var ip:String?
    var port:Int?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "screenshotSegue")
        {
            let destinationViewController = segue.destinationViewController as! screenshotView
            destinationViewController.computer = computer
            destinationViewController.ip = ip
            destinationViewController.port = port
        }
        
        if (segue.identifier == "processSegue")
        {
            let destinationViewController = segue.destinationViewController as! processView
            destinationViewController.computer = computer
            destinationViewController.ip = ip
            destinationViewController.port = port
        }
    }

    
    override func viewWillAppear(animated: Bool)
    {
        let client:TCPClient = TCPClient(addr: ip!, port: Int(port!))
        var (success,errmsg)=client.connect(timeout: 1)
        if success
        {
            statusLabel.text = "Status: On"
            //print("Status: On")
            screenShotBtn.enabled = true;
            processBtn.enabled = true;
            sendMessageBtn.enabled = true;
            turnOffBtn.enabled = true;
            
            var (success,errormsg)=client.close()
        }else
        {
            statusLabel.text = "Status: Off"
            //print("Status: Off")
            screenShotBtn.enabled = false;
            processBtn.enabled = false;
            sendMessageBtn.enabled = false;
            turnOffBtn.enabled = false;
        }
    }
    
    @IBAction func sendMessage(sender: AnyObject)
    {
        let alert = UIAlertController(title: "Send Message to PC",
            message: "Message to send",
            preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Send",
            style: .Default,
            handler: { (action:UIAlertAction) -> Void in
                
                let textField = alert.textFields!.first
                
                let client:TCPClient = TCPClient(addr: self.ip!, port: Int(self.port!))
                var (success, _)=client.connect(timeout: 1)
                
                if success
                {
                    var (success, errmsg)=client.send(str:"sendMessage|"+textField!.text!)
                    if success
                    {
                        //print(textField!.text)
                    }
                    else
                    {
                        
                    }
                }
                else
                {
                    
                }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
            animated: true,
            completion: nil)
    }
    
    @IBAction func shutdown(sender: AnyObject)
    {
        let client:TCPClient = TCPClient(addr: ip!, port: Int(port!))
        var (success, _)=client.connect(timeout: 1)
        
        if success
        {
//Change before realease: shutdownTest -> shutdown
            var (success, errmsg)=client.send(str:"shutdownTest")
            if success
            {
                statusLabel.text = "Status: Off"
            }
            else
            {
                
            }
        }
        else
        {
            
        }
    }
}