//
//  EditContractController.swift
//  iOU
//
//  Created by Tateni Urio on 11/20/14.
//  Copyright (c) 2014 Tateni Urio. All rights reserved.
//

import UIKit

class EditContractController: UITableViewController, Segueable
{
  override func viewDidLoad()
  {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    EditContractLogic.newContractViewDidLoad(self)
  }
  
  override func viewWillDisappear(animated: Bool)
  {
    super.viewWillDisappear(animated)
    EditContractLogic.newContractViewWillDisappear(self)
  }
  
  func refreshTable()
  {
    EditContractLogic.refreshNewContractors()
    self.tableView.reloadData()
  }
  
  func refreshCells(notification: NSNotification)
  {
    EditContractLogic.refreshNewContractCells(view: self, notification: notification)
  }
  
  func keyboardWillShow(notification: NSNotification)
  {
    EditContractLogic.keyboardWillShow(editContractController: self, notification: notification)
  }
  
  func keyboardWillHide()
  {
    EditContractLogic.keyboardWillHide(self.tableView)
  }
  
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator)
  {
    EditContractLogic.refreshNewContract()
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
  }
  
  @IBAction func doneActivated(sender: UIBarButtonItem)
  {
    EditContractLogic.newContractEdited(sender: self, save: true)
  }
  
  @IBAction func cancelActivated(sender: UIBarButtonItem)
  {
    EditContractLogic.newContractEdited(sender: self, save: false)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> (Int)
  {
    return EditContractLogic.newContractSectionCount(section)
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> (CGFloat)
  {
    return EditContractLogic.newContractMoneyRowHeight(indexPath)
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> (UITableViewCell)
  {
    var cell = EditContractLogic.newContractCreateCell(tableView: tableView, indexPath: indexPath)
    
    if (cell == nil)
    {
      cell =  super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    EditContractLogic.newContractMoneyUpdateCell(cell: cell!, indexPath: indexPath)
    
    return cell!
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
  {
    EditContractLogic.newContractSelectRow(tableView: tableView, indexPath: indexPath)
  }
  
  func lenderNameWarning()
  {
    performSegue(segueFrom: "NewContract", segueTo: "LenderNameWarning")
  }
  
  func borrowerNameWarning()
  {
    performSegue(segueFrom: "NewContract", segueTo: "BorrowerNameWarning")
  }
  
  func performSegue(segueFrom segueFrom: String, segueTo: String)
  {
    performSegueWithIdentifier(segueFrom + "->" + segueTo, sender: self)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
