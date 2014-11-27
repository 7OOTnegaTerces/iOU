//
//  NewContractTitleController.swift
//  iOU
//
//  Created by Tateni Urio on 11/18/14.
//  Copyright (c) 2014 Tateni Urio. All rights reserved.
//

import UIKit

class NewContractTitleController: UIViewController
{
  @IBOutlet weak var contractTitle: UITextField!
  @IBOutlet weak var contractType: UISegmentedControl!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    //Initialize the text field and segmented control to reflect the data stored in iOUData.
    if let title = iOUData.sharedInstance.temporaryData[1] as? String
    {
      contractTitle.text = title
    }
    else
    {
      println("From: NewContractTitleController. Error in Temproary Data, cannot extract title. \(iOUData.sharedInstance.temporaryData)")
    }
    
    if let type = iOUData.sharedInstance.temporaryData[2] as? Type
    {
      contractType.selectedSegmentIndex = type.rawValue
    }
    else
    {
      println("From: NewContractTitleController. Error in Temporary Data, cannot extract type. \(iOUData.sharedInstance.temporaryData)")
    }
  }
  
  @IBAction func changeContractTitle(sender: UITextField)
  {
    //Whenever the user changes the contract title, update New Contract Temporary Data.
    iOUData.sharedInstance.temporaryData[1] = contractTitle.text
  }
  
  @IBAction func changeContractType(sender: UISegmentedControl)
  {
    //Whenever the user changes the contract type, update iOUData.sharedInstance.newContractType.
    iOUData.sharedInstance.temporaryData[2] = Type(rawValue: sender.selectedSegmentIndex)!
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
