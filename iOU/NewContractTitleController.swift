//
//  NewContractTitleController.swift
//  iOU
//
//  Created by Tateni Urio on 11/17/14.
//  Copyright (c) 2014 Tateni Urio. All rights reserved.
//

import UIKit

class NewContractTitleController: UIViewController {
  @IBOutlet weak var detailsContainer: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  @IBAction func segueToNewTypeContoller(sender: UIBarButtonItem)
  {
    if let subContainer = detailsContainer as? NewContractTitleSubController
    {
//      switch subContainer.contractType
//      {
//        
//      }
    }
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
