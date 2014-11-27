//
//  NewContractMonetaryValueController.swift
//  iOU
//
//  Created by Tateni Urio on 11/23/14.
//  Copyright (c) 2014 Tateni Urio. All rights reserved.
//

import UIKit

class NewContractMonetaryValueController: UIViewController
{
  @IBOutlet weak var contractCurrency: UIButton!
  @IBOutlet weak var contractMonetaryValue: UITextField!
  var previousMonetaryValue: String = ""
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    //Initialize contractMonetaryValue to reflect the data stored in iOUData.
    if let dollarValue = iOUData.sharedInstance.temporaryData[1] as? Float
    {
      contractMonetaryValue.text = String(format: "%.2f", dollarValue)
      previousMonetaryValue = contractMonetaryValue.text
    }
    else
    {
      println("From: NewContractTitleController. Error in Temporary Data, cannot extract monetary value: \(iOUData.sharedInstance.temporaryData)")
    }
    contractCurrency.setTitle(iOUData.sharedInstance.currency.rawValue, forState: UIControlState.Normal)
  }
  
  @IBAction func changeContractMonetaryValue(sender: UITextField)
  {
    //Whenever the user changes the contract monetary value, update     iOUData.sharedInstance.temporaryData[1].
    
    //First, eliminate any characters that are not numbers from contractMonetaryValue.text. (Note: Since this is being done in real time, this effectively prevents the user from inputing any non-number characters.)
    var monetaryValue = contractMonetaryValue.text
    contractMonetaryValue.text = ""
    
    for character in monetaryValue
    {
      switch character
      {
        case "0"..."9":
          contractMonetaryValue.text.append(character)
        default:
          continue
      }
    }
    
    //Find the total number of digits in monetaryValue and use this to insert a '.' just before the final two digits, which represnt the change. (Note: Later steps will force contractMonetaryValue.text to always have at least one zero before the decimal point and two after, thus contractMonetaryValue.text will always have at least two digits, guaranteeing the possiblity to place a decimal point just before them.)
    var totalDigitLength = countElements(contractMonetaryValue.text)
    let dollarDigitLength = totalDigitLength - 2
    let dollarDigits = contractMonetaryValue.text[0..<dollarDigitLength]
    let changeDigits = contractMonetaryValue.text[dollarDigitLength..<totalDigitLength]
    monetaryValue = dollarDigits + "." + changeDigits
    
    //Get the float value from monetaryValue and assign it to iOUData.sharedInstance.temporaryData[1] and use it to format contractMonetaryValue.text with "%.2f" so that it always has at least one zero before the decimal point and two after.
    let dollarValue = monetaryValue.floatValue
    iOUData.sharedInstance.temporaryData[1] = dollarValue
    contractMonetaryValue.text = String(format: "%.2f", dollarValue)
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