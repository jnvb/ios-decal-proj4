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
        //print(computer)
        //print(ip)
        //print(port)
        let client:TCPClient = TCPClient(addr: ip!, port: Int(port!))
        var (success,errmsg)=client.connect(timeout: 1)
        if success
        {
            statusLabel.text = "Status: On"
            print("Status: On")
            var (success,errormsg)=client.close()
        }else
        {
            statusLabel.text = "Status: Off"
            print("Status: Off")
        }
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