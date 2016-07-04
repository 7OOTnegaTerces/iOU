//
//  MainInterfaceController.swift
//  iOU
//
//  Created by Tateni Urio on 11/8/14.
//  Copyright (c) 2014 Tateni Urio. All rights reserved.
//

import UIKit
import CoreData

class MainInterfaceController: UIViewController, Segueable
{
  @IBOutlet weak var listType: UISegmentedControl!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    /*TODO: Find out if this code was legit or just an artifact...
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshView), name:"Refresh", object: nil)*/
    
    //Initialize any varibles that need it.
    listType.selectedSegmentIndex = iOUData.sharedInstance.listType.rawValue
    
    //Create the three different add buttons for the navigation bar, stick them in an array, and add it to the right side of the navigation bar.
    var buttonImage = UIImage(named: "Lightning bolt.png")
//    let lightningAdd = UIBarButtonItem(image: buttonImage, style: .Plain, target: self, action:"segueToLigtningAdd:")
    
    buttonImage = UIImage(named: "Exclamation.png")
    let fastAdd = UIBarButtonItem(image: buttonImage, style: .Plain, target: self, action:#selector(MainInterfaceController.segueToFastAdd(_:)))
    
    buttonImage = UIImage(named: "add.png")
    let normalAdd = UIBarButtonItem(image: buttonImage, style: .Plain, target: self, action:#selector(MainInterfaceController.segueToNewContractTitle(_:)))
    
//    let buttons = [normalAdd, fastAdd, lightningAdd]
    let buttons = [normalAdd, fastAdd]
    self.navigationItem.rightBarButtonItems = buttons
    
  }
  
  @IBAction func changeList(sender: UISegmentedControl)
  {
    iOUData.sharedInstance.listType = ListType(rawValue: listType.selectedSegmentIndex)!
  }
  
  func segueToNewContractTitle(sender: UIBarButtonItem)
  {
    EditContractLogic.segueToNewContract(self)
  }
  
  func segueToFastAdd(sender: UIBarButtonItem)
  {
    
  }
  
  func performSegue(segueFrom segueFrom: String, segueTo: String)
  {
    performSegueWithIdentifier(segueFrom + "->" + segueTo, sender: self)
  }
  
  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
