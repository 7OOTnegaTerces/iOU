//
//  MainInterfaceController.swift
//  iOU
//
//  Created by Tateni Urio on 11/8/14.
//  Copyright (c) 2014 Tateni Urio. All rights reserved.
//

import UIKit
import CoreData

class MainInterfaceController: UIViewController
{
  @IBOutlet weak var listType: UISegmentedControl!
  
  override func viewWillAppear(animated: Bool)
  {
    super.viewWillAppear(animated)
    
    //Load saved Main Interface Data and initailize views
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    listType.selectedSegmentIndex = iOUData.sharedInstance.listType.rawValue
    
    /*  //Not Sure if I still want this code or not...
    
    //Create the three different add buttons for the navigation bar, stick them in an array, and add it to the right side of the navigation bar.
    let buttonSize = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
    
    let lightningAdd = UIBarButtonItem(customView: buttonSize)
    lightningAdd.image = UIImage(named: "Lightning bolt.png")
    
    let fastAdd = UIBarButtonItem(customView: buttonSize)
    fastAdd.image = UIImage(named: "Exclamation.png")
    
    let normalAdd = UIBarButtonItem(customView: buttonSize)
    normalAdd.image = UIImage(named: "add.png")
    
    let buttons = [normalAdd, fastAdd, lightningAdd]
    self.navigationItem.rightBarButtonItems = buttons
    var navigationBarAppearace = UINavigationBar.appearance()
    
    navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: CGFloat(0), green: CGFloat(109), blue: CGFloat(66), alpha: CGFloat(1))]
    */
  }
  
  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
