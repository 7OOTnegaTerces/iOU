//
//  NewContractLenders.swift
//  iOU
//
//  Created by Tateni Urio on 11/25/14.
//  Copyright (c) 2014 Tateni Urio. All rights reserved.
//

import UIKit

class NewContractLenders: UIViewController, UITableViewDelegate, UITableViewDataSource
{
  @IBOutlet weak var contractLenders: UITableView!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    self.contractLenders.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
  }
  
  @IBAction func cancelInputAndSegue(sender: UIBarButtonItem)
  {
    iOULogic.newContractInputSegue(self, save: false)
  }
  
  @IBAction func saveInputAndSegue(sender: UIBarButtonItem)
  {
    iOULogic.newContractInputSegue(self, save: true)
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> (Int)
  {
    //There should only be one section, if it asks about any others, crash the app by passing an invalid value.
    if (section > 0)
    {
      return -1
    }
    
    //Otherwise the number of rows is equal to the number of lenders, plus one for the add new lender cell.
    let dictionary = iOUData.sharedInstance.temporaryData[1] as [String: Float]
    let count = dictionary.count + 1
    return count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> (UITableViewCell)
  {
    return iOULogic.newContractLendersCell(tableView, indexPath: indexPath)
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
  {
    iOULogic.newContractLendersRowSegue(self, indexPath: indexPath)
  }
  
  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}