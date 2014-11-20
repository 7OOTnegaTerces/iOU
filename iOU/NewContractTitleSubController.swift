//
//  NewContractTitleSubController.swift
//  iOU
//
//  Created by Tateni Urio on 11/18/14.
//  Copyright (c) 2014 Tateni Urio. All rights reserved.
//

import UIKit
import CoreData

class NewContractTitleSubController: UIViewController
{
  @IBOutlet weak var contractTitle: UITextField!
  @IBOutlet weak var contractType: UISegmentedControl!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
//    contractType.selectedSegmentIndex = mainInterfaceData.listType.rawValue
    contractType.selectedSegmentIndex = 2
  }
  
  @IBAction func setContractType(sender: UISegmentedControl)
  {
    
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
