//
//  NewContractMoneyController.swift
//  iOU
//
//  Created by Tateni Urio on 11/20/14.
//  Copyright (c) 2014 Tateni Urio. All rights reserved.
//

import UIKit

class NewContractMoneyController: UITableViewController, UITableViewDelegate, UITableViewDataSource
{
  @IBOutlet weak var newContractTitle: UILabel!
  @IBOutlet weak var newContractType: UILabel!
  @IBOutlet weak var newContractValue: UILabel!

  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    //Register Table.
    self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    
    //Initialzie the Table.
    newContractTitle.text = iOUData.sharedInstance.newContractTitle
    newContractType.text = iOUData.sharedInstance.newContractType.toString()
    let currency = iOUData.sharedInstance.currency.rawValue
    newContractValue.text = String(format: "\(currency) %.2f", iOUData.sharedInstance.newContractMonetaryValue)
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
    let int = super.tableView(tableView, numberOfRowsInSection: section)
    return int
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> (UITableViewCell)
  {
    let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
  {
    iOULogic.newContractMoneyRowSegue(self, indexPath: indexPath)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
