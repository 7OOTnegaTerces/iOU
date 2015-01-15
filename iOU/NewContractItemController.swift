//
//  NewContractItem.swift
//  iOU
//
//  Created by Tateni Urio on 11/20/14.
//  Copyright (c) 2014 Tateni Urio. All rights reserved.
//

import UIKit

class NewContractItemController: UITableViewController, UITableViewDelegate, UITableViewDataSource, NewContractViewController
{
  @IBOutlet weak var titleAndType: UITableViewCell!
  @IBOutlet weak var value: UITableViewCell!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    //Register Table
    self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    loadCellData()
  }
  
  func loadCellData()
  {
    //ToDo - Finish This!!!
  }
  
  func reloadData()
  {
    loadCellData()
    tableView.reloadData()
  }
  
  @IBAction func saveAndSegueToMainInterface(sender: UIBarButtonItem)
  {
    iOULogic.newContractEdited(self, save: true)
  }
  
  @IBAction func cancelAndSegueToMainInterface(sender: UIBarButtonItem)
  {
    iOULogic.newContractEdited(self, save: false)
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
      fatalError("Error, there are not that many sections in New Contract Item!")
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
    iOULogic.newContractItemRowSelection(self, indexPath: indexPath)
  }
  
  func performSegue(identifier: String)
  {
    performSegueWithIdentifier(identifier, sender: self)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
