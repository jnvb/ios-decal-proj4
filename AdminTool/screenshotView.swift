//
//  screenshotView.swift
//  AdminTool
//
//  Created by jnvb on 2015. 12. 6..
//  Copyright © 2015년 jnvb. All rights reserved.
//

import UIKit

class screenshotView: UIViewController
{
    @IBOutlet weak var picView: UIImageView!
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    var computer: String?
    var ip: String?
    var port: Int?
    
    var imageData: NSData!
    
    override func viewDidAppear(animated: Bool)
    {
        var screenshot = [UInt8]()
        var size = [UInt8]()
        var sizesize:String = ""
        
        let client:TCPClient = TCPClient(addr: ip!, port: Int(port!))
        var (success, _)=client.connect(timeout: 1)
        
        if success
        {
            var (success, errmsg)=client.send(str:"getScreenshot")
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
                    
                    /*
                    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                    dispatch_async(dispatch_get_global_queue(priority, 0)) {
                        // do some task
                        dispatch_async(dispatch_get_main_queue()) {
                        }
                    }
                    */
                    
                    if(data == nil)
                    {
                        i = 0
                    }
                    else
                    {
                        screenshot.appendContentsOf(data!)
                        recieved += data!.count
                    }
                }
            }
            else
            {
                print(errmsg)
            }
        }
        
        progress.text = String(Int(sizesize)!/1024)+" kb"
        imageData = NSData(bytes: screenshot, length:Int(sizesize)!)
        picView.image = UIImage(data:imageData)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>)
    {
        if error == nil
        {
            let ac = UIAlertController(title: "Saved!", message: "Your image has been saved to your photos.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
        else
        {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    func getDocumentsDirectory() -> NSString
    {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    @IBAction func saveButton(sender: AnyObject)
    {
        //Save to the app directory
        /*
        if let data = UIImagePNGRepresentation(UIImage(data:imageData)!) {
            let filename = getDocumentsDirectory().stringByAppendingPathComponent("copy.png")
            data.writeToFile(filename, atomically: true)
            print("save success")
        }
        */
        
        //Save to album
        UIImageWriteToSavedPhotosAlbum(picView.image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
}
