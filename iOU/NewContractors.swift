//
//  NewContractors.swift
//  iOU
//
//  Created by Tateni Urio on 11/25/14.
//  Copyright (c) 2014 Tateni Urio. All rights reserved.
//

import UIKit

class NewContractors: UIViewController, UITableViewDelegate, UITableViewDataSource, Segueable
{
  @IBOutlet weak var shares: UISegmentedControl!
  @IBOutlet weak var contractorsList: UITableView!
  private var contractorType: String = ""
  
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    EditContractLogic.newContractorViewDidLoad(view: self, table: contractorsList, contractorType: contractorType)
  }
  
  override func viewWillDisappear(animated: Bool)
  {
    super.viewWillDisappear(animated)
    
    EditContractLogic.newContractorViewWillDisappear(view: self, contractorType: contractorType)
  }
  
  func refreshTable()
  {
    EditContractLogic.refreshNewContractorTable(sharesController: shares, table: contractorsList, contractorType: contractorType)
  }
  
  func keyboardWillShow(notification: NSNotification)
  {
    EditContractLogic.keyboardWillShow(newContractor: self, notification: notification)
  }
  
  @IBAction func updateShares(sender: UISegmentedControl)
  {
    EditContractLogic.updateShares(sender: sender, contractorType: contractorType)
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> (Int)
  {
    return EditContractLogic.newContractRowCount(section: section, contractorType: contractorType)
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> (CGFloat)
  {
    return EditContractLogic.newContractorRowHeight(indexPath: indexPath, contractorType: contractorType)
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> (UITableViewCell)
  {
    return EditContractLogic.newContractorsCreateCell(tableView, indexPath, contractorType: contractorType)
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
  {
    EditContractLogic.newContractorsRowSelection(tableView, indexPath, contractorType: contractorType)
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



class NewContractBorrowers: NewContractors
{
  override func viewDidLoad()
  {
    contractorType = "Borrower"
    super.viewDidLoad()
  }
}



class NewContractLenders: NewContractors
{
  override func viewDidLoad()
  {
    contractorType = "Lender"
    super.viewDidLoad()
  }
}