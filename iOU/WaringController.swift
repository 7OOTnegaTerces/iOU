//
//  WaringController.swift
//  iOU
//
//  Created by Tateni Urio on 1/6/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class WaringController: UIViewController, Segueable
{

  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }

  @IBAction func endWarning(sender: UIButton)
  {
    EditContractLogic.endWarning(self)
  }
  
  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func performSegue(#segueFrom: String, segueTo: String)
  {
    performSegueWithIdentifier(segueFrom + "->" + segueTo, sender: self)
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
