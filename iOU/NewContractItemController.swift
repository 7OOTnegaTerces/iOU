//
//  NewContractItem.swift
//  iOU
//
//  Created by Tateni Urio on 11/20/14.
//  Copyright (c) 2014 Tateni Urio. All rights reserved.
//

import UIKit

class NewContractItemController: UITableViewController, UITableViewDelegate, UITableViewDataSource
{
  @IBOutlet weak var titleAndType: UITableViewCell!
  @IBOutlet weak var value: UITableViewCell!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    //Register Table
    self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
  }
  
  @IBAction func saveAndSegueToMainInterface(sender: UIBarButtonItem)
  {
    iOULogic.segueToMainInterface(self, save: true)
  }
  
  @IBAction func cancelAndSegueToMainInterface(sender: UIBarButtonItem)
  {
    iOULogic.segueToMainInterface(self, save: false)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> (Int)
  {
    switch section
    {
    case 0:
      return 3
    case 1:
      return 3
    default:
      println("Error, there are not that many sections in New Contract Item!")
      return 1
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> (UITableViewCell)
  {
    let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
  {
    iOULogic.newContractItemRowSegue(self, indexPath: indexPath)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
