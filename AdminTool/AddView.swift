//
//  AddView.swift
//  AdminTool
//
//  Created by jnvb on 2015. 12. 5..
//  Copyright © 2015년 jnvb. All rights reserved.
//

import UIKit
import CoreData

class AddView: UIViewController
{
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var ipInput: UITextField!
    @IBOutlet weak var portInput: UITextField!
    
    var computerName = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    @IBAction func close(sender: UIButton)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func ok(sender: UIButton)
    {
        let name = nameInput.text
        let ip = ipInput.text
        let port = Int(portInput.text!)
        
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDel.managedObjectContext
        let entity = NSEntityDescription.entityForName("Computer", inManagedObjectContext:managedContext)
        let computer = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        computer.setValue(name, forKey: "name")
        computer.setValue(ip, forKey: "ip")
        computer.setValue(port, forKey: "port")
        
        do
        {
            try managedContext.save()
            computerName.append(computer)
        }catch let error as NSError
        {
            print("Could not save \(error), \(error.userInfo)")
        }

        
        dismissViewControllerAnimated(true, completion: nil)
    }
}