//
//  NewContractLenders.swift
//  iOU
//
//  Created by Tateni Urio on 11/25/14.
//  Copyright (c) 2014 Tateni Urio. All rights reserved.
//

import UIKit

class NewContractLenders: UIViewController, UITableViewDelegate, UITableViewDataSource, Refreshable, Segueable
{
  @IBOutlet weak var shares: UISegmentedControl!
  @IBOutlet weak var lendersList: UITableView!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshView:",name:"Refresh", object: nil)
    
    //Register Table.
    lendersList.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    
    //Initialzie the Table.
    lendersList.estimatedRowHeight = 44.0
    lendersList.rowHeight = UITableViewAutomaticDimension
    var nib = UINib(nibName: "EditContractorNameAndValueCell", bundle: nil)
    lendersList.registerNib(nib, forCellReuseIdentifier: "EditContractorNameAndValueCell")
    nib = UINib(nibName: "EditContractorNameCell", bundle: nil)
    lendersList.registerNib(nib, forCellReuseIdentifier: "EditContractorNameCell")
    nib = UINib(nibName: "ContractorCell", bundle: nil)
    lendersList.registerNib(nib, forCellReuseIdentifier: "ContractorCell")
    nib = UINib(nibName: "EditLenderNameAndValueCell", bundle: nil)
    lendersList.registerNib(nib, forCellReuseIdentifier: "EditLenderNameAndValueCell")
    nib = UINib(nibName: "LenderCell", bundle: nil)
    lendersList.registerNib(nib, forCellReuseIdentifier: "LenderCell")
  }
  
  func reloadData()
  {
    //TODO - Finish!!!
  }
  
  func refreshView(notification: NSNotification)
  {
    reloadData()
    lendersList.reloadData()
  }
  
  @IBAction func updateDivideShares(sender: UISegmentedControl)
  {
    if (iOULogic.saveDynamicChanges())
    {
      let previousShare = iOUData.sharedInstance.temporaryData.contract.lenderShares.rawValue
      sender.selectedSegmentIndex = previousShare
      return
    }
    
    let share: Shares = Shares(rawValue: sender.selectedSegmentIndex)!
    iOULogic.resetDynamicEditing()
    iOUData.sharedInstance.temporaryData.contract.lenderShares = share
    iOULogic.refreshViews()
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> (Int)
  {
    //There should only be one section, if it asks about any others, print a warning and return.
    if (section > 0)
    {
      fatalError("There is only 1 section, not \(section), in the New Contract Contractor's table.")
    }
    
    return 1 + iOUData.sharedInstance.temporaryData.contract.lenders.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> (UITableViewCell)
  {
    return iOULogic.newContractLendersCell(tableView: tableView, indexPath: indexPath)
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
  {
    iOULogic.newContractLendersRowSelection(indexPath)
  }

  func performSegue(#segueFrom: String, segueTo: String)
  {
    performSegueWithIdentifier(segueFrom + "->" + segueTo, sender: self)
  }
  
  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}