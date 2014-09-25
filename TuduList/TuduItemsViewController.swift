    //
//  TuduItemsViewController.swift
//  TuduList
//
//  Created by Bruno Paulino on 9/5/14.
//  Copyright (c) 2014 Bruno Paulino. All rights reserved.
//

import UIKit

class TuduItemsViewController: UITableViewController, ItemDetailViewControllerDelegate {
    
    var tuduItems:[PFObject] = [PFObject]()
    var reachbility:AFNetworkReachabilityManager?

    @IBAction func showProfileScreen(sender: UIBarButtonItem?) {
        
        self.performSegueWithIdentifier("ProfileScreen", sender: self)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTuduItemsFromParse()
        self.checkInternetConnection()
    }
    
    func loadTuduItemsFromParse() -> Void{
        
        if PFUser.currentUser() == nil{
            self.showProfileScreen(nil)
        }else{
            
            let query:PFQuery = PFQuery(className: "TuduItem")
            query.whereKey("user", equalTo:PFUser.currentUser())
            query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                if error == nil{
                    println("Query works!!")
                    self.tuduItems.removeAll(keepCapacity: false)
                    if let items = objects as? [PFObject]{
                        for item in items{
                            self.tuduItems.append(item)
                        }
                        self.tableView.reloadData()
                    }
                }
            }
            
        }
        
    }
    
    func formatDateToFormatedString(date: NSDate) -> String{
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "h:mm a '-' MM/dd/YY"
        return formatter.stringFromDate(date)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.tuduItems.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath: indexPath) as UITableViewCell
        
        let tuduItem:PFObject = self.tuduItems[indexPath.row]
        cell.detailTextLabel?.text = self.formatDateToFormatedString(tuduItem["dueDate"] as NSDate)
        cell.textLabel?.text = tuduItem["title"] as? String

        return cell
    }
    
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete{
            let tuduItem:PFObject = self.tuduItems[indexPath.row]
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            self.tuduItems.removeAtIndex(indexPath.row)
            
            tuduItem.deleteInBackgroundWithBlock { (success, error) -> Void in
                if success{
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.tableView.reloadData()
                    println("The item has been deleted")
                }
                else if error != nil{
                    println("Delete Object error! \(error)")
                }
            }
        }
    }
    

    // MARK: - Table View Delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let tuduItem:PFObject = self.tuduItems[indexPath.row]
        self.performSegueWithIdentifier("EditItem", sender: tuduItem)
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "EditItem"{
            let tuduItem:PFObject = sender as PFObject
            let navigationController:UINavigationController = segue.destinationViewController as UINavigationController
            let itemDetailViewController:ItemDetailViewController = navigationController.topViewController as ItemDetailViewController
            itemDetailViewController.delegate = self
            itemDetailViewController.title = "Edit Item"
            itemDetailViewController.itemToEdit = tuduItem
        }
        else if segue.identifier == "AddItem"{
            println("AddItem!")
            let navigationController:UINavigationController = segue.destinationViewController as UINavigationController
            let itemDetailViewController:ItemDetailViewController = navigationController.topViewController as ItemDetailViewController
            itemDetailViewController.delegate = self
        }
    }
    
    func checkInternetConnection(){
        reachbility = AFNetworkReachabilityManager(forDomain: "www.parse.com")
        reachbility?.setReachabilityStatusChangeBlock { (status) -> Void in
            let statusString:String = AFStringFromNetworkReachabilityStatus(status)
            println("Reachability: \(statusString)")
        }
        reachbility?.startMonitoring()
    }
    
    // MARK: - ItemDetailViewControllerDelegate
    func didFinishEditingItem() {
        self.loadTuduItemsFromParse()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        if self.tuduItems.isEmpty{
            self.loadTuduItemsFromParse()
        }
    }

}



















