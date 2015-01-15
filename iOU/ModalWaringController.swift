//
//  ModalWaringController.swift
//  iOU
//
//  Created by Tateni Urio on 1/6/15.
//  Copyright (c) 2015 Tateni Urio. All rights reserved.
//

import UIKit

class ModalWaringController: UIViewController
{

  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }

  override func touchesEnded(touches: NSSet, withEvent event: UIEvent)
  {
    let source = iOUData.sharedInstance.temporaryData.warnSource
    NSNotificationCenter.defaultCenter().postNotificationName("Refresh" + source + "Only", object: nil)
    iOUData.sharedInstance.temporaryData.warnSource = ""
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
  {
    //Do nothing???
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent)
  {
    //Do nothing???
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
