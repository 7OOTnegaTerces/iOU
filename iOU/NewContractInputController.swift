//
//  NewContractInputController.swift
//  iOU
//
//  Created by Tateni Urio on 11/17/14.
//  Copyright (c) 2014 Tateni Urio. All rights reserved.
//

import UIKit

class NewContractInputController: UIViewController, NewContractViewController
{
  var tableView: UITableView!

  override func viewDidLoad()
  {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    loadCellData()
  }
  
  func loadCellData()
  {
    //ToDo - Finish This!
  }

  @IBAction func cancelInputAndSegue(sender: UIBarButtonItem)
  {
    iOULogic.newContractEdited(self, save: false)
  }
  
  @IBAction func saveInputAndSegue(sender: UIBarButtonItem)
  {
    iOULogic.newContractEdited(self, save: true)
  }

  func performSegue(identifier: String)
  {
    performSegueWithIdentifier(identifier, sender: self)
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
