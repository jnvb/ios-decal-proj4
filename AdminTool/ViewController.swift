//
//  ViewController.swift
//  AdminTool
//
//  Created by jnvb on 2015. 12. 5..
//  Copyright © 2015년 jnvb. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    var deleteTaskIndexPath: NSIndexPath? = nil
    
    var computerName = [NSManagedObject]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = "Computer List"
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(animated: Bool)
    {
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDel.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Computer")
        
        do
        {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            computerName = results as! [NSManagedObject]
        }catch let error as NSError
        {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "statusSegue")
        {
            let indexPath = sender as! NSIndexPath
            let computerIndex = indexPath.row
            let computer = computerName[computerIndex]
            
            let destinationViewController = segue.destinationViewController as! StatusView
            destinationViewController.computer = computer.valueForKey("name") as? String
            destinationViewController.ip = computer.valueForKey("ip") as? String
            destinationViewController.port = computer.valueForKey("port") as? Int
        }
        
        if (segue.identifier == "addSegue")
        {
            let destinationViewController = segue.destinationViewController as! AddView
            destinationViewController.computerName = computerName
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func cancelDeleteTask(alertAction: UIAlertAction!)
    {
        deleteTaskIndexPath = nil
    }
    
    func handleDeleteTask(alertAction: UIAlertAction!) -> Void
    {
        if let indexPath = deleteTaskIndexPath {
            tableView.beginUpdates()
            
            let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDel.managedObjectContext
            managedContext.deleteObject(computerName[indexPath.row] as NSManagedObject)
            do
            {
                try managedContext.save()
                computerName.removeAtIndex(indexPath.row)
            }catch let error as NSError
            {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            deleteTaskIndexPath = nil
            tableView.endUpdates()
        }
    }
    
    func confirmDelete(task: NSManagedObject)
    {
        let name = task.valueForKey("name")!
        let alert = UIAlertController(title: "Delete Task", message: "Are you sure you want to permanently delete \(name)?", preferredStyle: .ActionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: handleDeleteTask)
        let CancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: cancelDeleteTask)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            deleteTaskIndexPath = indexPath
            let taskToDelete = computerName[indexPath.row]
            confirmDelete(taskToDelete)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return computerName.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        let name = computerName[indexPath.row]
        
        cell!.textLabel!.text = name.valueForKey("name") as? String
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        performSegueWithIdentifier("statusSegue", sender: indexPath)
    }
    
    @IBAction func addComputer(sender: AnyObject)
    {
        self.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        
        self.modalPresentationStyle = .CurrentContext
        
        self.presentViewController(StatusView(), animated: true, completion: nil)
    }
}

