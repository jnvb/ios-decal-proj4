//
//  processView.swift
//  AdminTool
//
//  Created by jnvb on 2015. 12. 6..
//  Copyright © 2015년 jnvb. All rights reserved.
//

import UIKit

class processView: UIViewController
{
    @IBOutlet weak var textView: UITextView!
    
    var computer:String?
    var ip:String?
    var port:Int?
    
    override func viewDidAppear(animated: Bool) {
        var process = [UInt8]()
        var size = [UInt8]()
        var sizesize:String = ""
        
        let client:TCPClient = TCPClient(addr: ip!, port: Int(port!))
        var (success, _)=client.connect(timeout: 1)
        
        if success
        {
            var (success, errmsg)=client.send(str:"getProcess")
            if success
            {
                var data = client.read(1024*10)
                var i = 1
                var recieved = 0
                
                size = data!
                
                for(var i = 0; i < size.count; i++)
                {
                    if(size[i] == 0)
                    {
                        break
                    }
                    sizesize += String(UnicodeScalar(size[i]))
                }
                
                while(i != 0)
                {
                    data = client.read(1024)
                    
                    if(data == nil)
                    {
                        i = 0
                    }
                    else
                    {
                        process.appendContentsOf(data!)
                        recieved += data!.count
                    }
                }
            }
            else
            {
                print(errmsg)
            }
        }
        
        var processString:String = ""
        
        for(var i = 0; i < process.count-2; i++)
        {
            processString += String(UnicodeScalar(process[i]))
        }
        
        textView.text = processString
    }
    
    @IBAction func killProcess(sender: AnyObject)
    {
        let alert = UIAlertController(title: "Terminate Process",
            message: "pid to terminate",
            preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Kill",
            style: .Default,
            handler: { (action:UIAlertAction) -> Void in
                
                let textField = alert.textFields!.first
                
                let client:TCPClient = TCPClient(addr: self.ip!, port: Int(self.port!))
                var (success, _)=client.connect(timeout: 1)
                
                if success
                {
                    var (success, errmsg)=client.send(str:"terminateProcess|"+textField!.text!)
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
}
