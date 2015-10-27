//
//  iOUData.swift
//  iOU
//
//  Created by Tateni Urio on 11/19/14.
//  Copyright (c) 2014 Tateni Urio. All rights reserved.
//

import Foundation
import CoreData
import UIKit

private let iOUDataSharedInstance = iOUData()

class iOUData
{
  class var sharedInstance: iOUData
  {
    return iOUDataSharedInstance
  }
  private let managedObjectContext: NSManagedObjectContext
  private let mainData: NSManagedObject
  var debug: Bool
  {
    get
    {
      if let temporaryExtractedDatum: AnyObject = mainData.valueForKey("debug")
      {
        return temporaryExtractedDatum as! Bool
      }
      else
      {
        return true
      }
    }
    set
    {
      debugFlag = newValue
      saveToMainData("debug", dataValue: newValue)
    }
  }
  private var debugFlag = true
  var debugging: Bool
  {
    get
    {
      return debugFlag
    }
  }
  var listType: ListType
  {
    get
    {
      if let temporaryExtractedDatum: AnyObject = mainData.valueForKey("listType")
      {
        let temporaryUnwrappedDatum = temporaryExtractedDatum as! Int
        return ListType(rawValue: temporaryUnwrappedDatum)!
      }
      else
      {
        return ListType.Money
      }
    }
    set
    {
      saveToMainData("listType", dataValue: newValue.rawValue)
    }
  }
  var currency: Currency
  {
    get
    {
      if let temporaryExtractedDatum: AnyObject = mainData.valueForKey("currency")
      {
        let temporaryUnwrappedDatum = temporaryExtractedDatum as! String
        return Currency(rawValue: temporaryUnwrappedDatum)!
      }
      else
      {
        return Currency.USD
      }
    }
    set
    {
      saveToMainData("currency", dataValue: newValue.rawValue)
    }
  }
  var standardTip: Int
  {
    get
    {
      if let temporaryExtractedDatum: AnyObject = mainData.valueForKey("standardTip")
      {
        return temporaryExtractedDatum as! Int
      }
      else
      {
        return 15
      }
    }
    set
    {
      saveToMainData("standardTip", dataValue: newValue)
    }
  }
  var standardIntrest: Double
  {
    get
    {
      if let temporaryExtractedDatum: AnyObject = mainData.valueForKey("standardIntrest")
      {
        return temporaryExtractedDatum as! Double
      }
      else
      {
        return 2.5
      }
    }
    set
    {
      saveToMainData("standardIntrest", dataValue: newValue)
    }
  }
  var orientationIsPortrait: Bool
  {
    get
    {
      return UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)
    }
  }
  var orientationIsLandscape: Bool
  {
    get
    {
      return UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)
    }
  }
  var mainScreenBoundries: CGRect
  {
    get
    {
      return UIScreen.mainScreen().bounds
    }
  }
  var mainScreenWidth:CGFloat
  {
    get
    {
      return mainScreenBoundries.size.width
    }
  }
  var mainScreenHeight:CGFloat
  {
    get
    {
      return mainScreenBoundries.size.height
    }
  }
  var currentFocus: Focus!
  {
    get
    {
      return focus
    }
    set
    {
      if (focus != nil)
      {
        focus.clearFocus()
      }
      
      focus = newValue
    }
  }
  var contractTemporaryData: ContractTemporaryData
  {
    get
    {
      return cTD
    }
  }
  var newContract: Contract
  {
    get
    {
      return nC
    }
  }
  var moneyContracts: [Contract]
  {
    get
    {
      return mCs
    }
    set
    {
      for contract in newValue
      {
        mCs.append(contract)
      }
    }
  }
  var itemContracts: [Contract]
  {
    get
    {
      return iCs
    }
    set
    {
      for contract in newValue
      {
        iCs.append(contract)
      }
    }
  }
  var serviceContracts: [Contract]
  {
    get
    {
      return sCs
    }
    set
    {
      for contract in newValue
      {
        sCs.append(contract)
      }
    }
  }
  
  internal var cTD = ContractTemporaryData()
  internal var nC = Contract()
  internal var mCs: [Contract] = []
  internal var iCs: [Contract] = []
  internal var sCs: [Contract] = []
  let loopRadius: Int = 25
  private var focus: Focus!
  let currencyFormatter = CurrencyFormatter()
  let dateFormatter = NSDateFormatter()
  
  
  private init()
  {
    //Initalize Temporary Data and New Contract data values.
    //Set it up so that we can save and load variables.
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    managedObjectContext = appDelegate.managedObjectContext!
    let fetchRequest = NSFetchRequest(entityName:"MainData")
    var error: NSError?
    
    if let fetchedResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
    {
      if (fetchedResults == [])
      {
        //If this is the first time this app has ever run, create mainData Core Data storage object to save all main app data values.
        let entity =  NSEntityDescription.entityForName("MainData", inManagedObjectContext: managedObjectContext)
        mainData = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
      }
      else
      {
        //Otherwise, initialize mainData from saved data.
        mainData = fetchedResults[0]
      }
    }
    else
    {
      fatalError("Could not fetch \(error), \(error!.userInfo)")
    }
  }
  
  func totalLenderParts() -> (Int)
  {
    return Int(totalContractorValue(contractorType: "Lender", valueIndex: 0, includeDynamicCell: true))
  }
  
  func totalBorrowerParts() -> (Int)
  {
    return Int(totalContractorValue(contractorType: "Borrower", valueIndex: 0, includeDynamicCell: true))
  }
  
  func totalLenderPercentageUsed() -> (Double)
  {
    return totalContractorValue(contractorType: "Lender", valueIndex: 1, includeDynamicCell: false)
  }
  
  func totalBorrowerPercentageUsed() -> (Double)
  {
    return totalContractorValue(contractorType: "Borrower", valueIndex: 1, includeDynamicCell: false)
  }
  
  func totalLenderFixedUsed() -> (Double)
  {
    return totalContractorValue(contractorType: "Lender", valueIndex: 2, includeDynamicCell: false)
  }
  
  func totalBorrowerFixedUsed() -> (Double)
  {
    return totalContractorValue(contractorType: "Borrower", valueIndex: 2, includeDynamicCell: false)
  }
  
  private func totalContractorValue(#contractorType: String, valueIndex: Int, includeDynamicCell: Bool) -> (Double)
  {
    var total: Double = 0
    var contractorValues: [(parts: Int, percent: Int, fixed: Double)]
    
    if (contractorType == "Lender")
    {
      contractorValues = cTD.lendersTemporary.values
    }
    else
    {
      contractorValues = cTD.borrowersTemporary.values
    }
    
    if (cTD.dynamicallyEditing && cTD.dynamicEditID == contractorType)
    {
      var dynamicEditIndex = cTD.dynamicEditCell.row
      
      if (contractorType == "Lender")
      {
        dynamicEditIndex -= EditContractLogic.newBorrowerInsertionOffset
      }
      else
      {
        dynamicEditIndex -= EditContractLogic.newLenderInsertionOffset
      }
      
      for i in 0..<contractorValues.count
      {
        if (i != dynamicEditIndex)
        {
          switch valueIndex
          {
            case 0:
              total += Double(contractorValues[i].0)
            case 1:
              total += Double(contractorValues[i].1)
            case 2:
              total += contractorValues[i].2
            default:
              fatalError("valueIndex out of bounds for dynamicEditContractorTally!")
          }
        }
        else if (includeDynamicCell)
        {
          let contractor = cTD.dynamicEditValues["DynamicEditContractor"] as! (key: String, value: (parts: Int, percent: Int, fixed: Double))
          let contractorValues = contractor.value
          
          switch valueIndex
          {
            case 0:
              total += Double(contractorValues.parts)
            case 1:
              total += Double(contractorValues.percent)
            case 2:
              total += contractorValues.fixed
            default:
              fatalError("valueIndex out of bounds for dynamicEditContractorTally!")
          }
        }
      }
    }
    else
    {
      for value in contractorValues
      {
        switch valueIndex
        {
          case 0:
            total += Double(value.0)
          case 1:
            total += Double(value.1)
          case 2:
            total += value.2
          default:
            fatalError("valueIndex out of bounds for dynamicEditContractorTally!")
        }
      }
    }
    
    return total
  }
  
  private func dynamicEditContractorTally(#contractorValues: [(parts: Int, percent: Int, fixed: Double)], dynamicEditIndex: Int, valueIndex: Int, includeDynamicCell: Bool) -> (Double)
  {
    var value: Double = 0
    
    
    return value
  }
  
  private func getContractorValue(#contratorValue: (parts: Int, percent: Int, fixed: Double), valueIndex: Int) -> (Double)
  {
    switch valueIndex
    {
    case 0:
      return Double(contratorValue.0)
    case 1:
      return Double(contratorValue.1)
    case 2:
      return contratorValue.2
    default:
      fatalError("valueIndex out of bounds for getContractorValue!")
    }
  }
  
  func eraseNewContractData()
  {
    cTD = ContractTemporaryData()
    nC = Contract()
  }
  
  private func saveToMainData(key: String, dataValue: AnyObject)
  {
    mainData.setValue(dataValue, forKey: key)
    var error: NSError?
    
    if (!managedObjectContext.save(&error))
    {
      fatalError("Could not save \(error), \(error?.userInfo)")
    }
  }
  
  func mostPopularContractType() -> (Type)
  {
    //TODO - Finish this method...
    return Type.Item
  }
}





class ContractTemporaryData
{
  var dynamicallyEditing: Bool
  {
    get
    {
      return dEditing
    }
    set
    {
      if (newValue)
      {
        dEditing = true
      }
      else
      {
        fatalError("DynamicallyEditing cannot be set to false, ContractTemporaryData must be reset instead.")
      }
    }
  }
  
  var dynamicEditID = ""
  var dynamicEditCell = NSIndexPath()
  internal var dEditing = false
  var dynamicEditValues: [String:Any]
  var continuousEditValue: [String:Any] = ["IncludeInterest": false, "DisplayingLenders": false, "DisplayingBorrowers": false, "AdjustForKeyboard": false, "DisplayAlertSettings": false, "DisplayAlertRepeatSettings": false, "DisplayDueCalender": false, "DisplayAlertCalender": false]
  var lenderSlackRow = -1
  var borrowerSlackRow = -1
  var warnRefreshID = ""
  var warnFromID = ""
  var warnToID = ""
  var contract: Contract
  var lendersTemporary: SortableDictionary<String, (parts: Int, percent: Int, fixed: Double)> = SortableDictionary()
  var borrowersTemporary: SortableDictionary<String, (parts: Int, percent: Int, fixed: Double)> = SortableDictionary()
  
  init(contract c: Contract)
  {
    contract = c
  }
  
//  var scrollResetPoint: CGPoint! = nil Now to be found in ContinousEditing, or not if value is nil.
  
  func reset()
  {
    dynamicEditID = ""
    dynamicEditCell = NSIndexPath()
    dEditing = false
    warnRefreshID = ""
    warnFromID = ""
    warnToID = ""
    lendersTemporary = SortableDictionary()
    borrowersTemporary = SortableDictionary()
    
    setEditDictionaries()
  }
  
  private func setEditDictionaries()
  {
    dynamicEditValues = ["DisplayCalculator": false]
    continuousEditValue["IncludeTip"] = contract.includeTip
    continuousEditValue["IncludeInterest"] = contract.includeInterest
    
  }
}





class CurrencyFormatter: NSNumberFormatter
{
  required init(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
  }
  
  override init()
  {
    super.init()
    self.locale = NSLocale.currentLocale()
    self.maximumFractionDigits = 2
    self.minimumFractionDigits = 2
    self.alwaysShowsDecimalSeparator = true
    self.numberStyle = .CurrencyStyle
  }
}





enum Type: Int
{
  case Money = 0
  case Item, Service
  
  
  func toString() -> (String)
  {
    switch self
    {
      case .Money:
        return "Money"
      case .Item:
        return "Item"
      case .Service:
        return "Service"
    }
  }
  
  func toAlternateString() -> (String)
  {
    switch self
    {
      case .Money:
        return "Monetary"
      case .Item:
        return "Item"
      case .Service:
        return "Service"
    }
  }
  
  func compare(typeOther: Type) -> (Bool)
  {
    return self.rawValue == typeOther.rawValue
  }
  
  func convert() -> (ListType)
  {
    return ListType(rawValue: self.rawValue)!
  }
}





enum ListType: Int
{
  case Money = 0
  case Item, Service, Starred
  
  
  func toString() -> (String)
  {
    switch self
    {
      case .Money:
        return "Money"
      case .Item:
        return "Item"
      case .Service:
        return "Service"
      case .Starred:
        return "Starred"
    }
  }
  
  func compare(typeOther: ListType) -> (Bool)
  {
    return self.rawValue == typeOther.rawValue
  }
  
  func convert() -> (Type)
  {
    if (self == ListType.Starred)
    {
      fatalError("Cannot convert from ListType Starred to Type.")
    }
    
    return Type(rawValue: self.rawValue)!
  }
}





enum Currency: String
{
  case USD = "USD"
  
  
  func compare(typeOther: Currency) -> (Bool)
  {
    return self.rawValue == typeOther.rawValue
  }
  
  func compare(typeOther: String) -> (Bool)
  {
    return self.rawValue == typeOther
  }
}





enum Shares: Int
{
  case Equal = 0
  case Part, Percentage, Fixed
  
  
  func toString() -> (String)
  {
    switch self
    {
      case .Equal:
        return "Equal"
      case .Part:
        return "Part"
      case .Percentage:
        return "Percentage"
      case .Fixed:
        return "Fixed"
    }
  }
  
  func compare(typeOther: Shares) -> (Bool)
  {
    return self.rawValue == typeOther.rawValue
  }
}




enum Operation: Int
{
  case Add = 0
  case Subtract, Multiply, Divide
  
  
  func compare(typeOther: Operation) -> (Bool)
  {
    return self.rawValue == typeOther.rawValue
  }
}





enum AlertNagRate: Int
{
  case Once = 0
  case Minutly, Hourly, Daily, Weekly
  
  
  func toString() -> (String)
  {
    switch self
    {
      case .Once:
        return "Once"
      case .Minutly:
        return "Nag Every Minute"
      case .Hourly:
        return "Nag Every Hour"
      case .Daily:
        return "Remind Daily"
      case .Weekly:
        return "Remind Weekly"
    }
  }
  
  func compare(typeOther: AlertNagRate) -> (Bool)
  {
    return self.rawValue == typeOther.rawValue
  }
}





enum TimeInterval: Int
{
  case Day = 0
  case Week, Month, Year
  
  
  func toString() -> (String)
  {
    switch self
    {
      case .Day:
        return "Day"
      case .Week:
        return "Week"
      case .Month:
        return "Month"
      case .Year:
        return "Year"
    }
  }
  
  func compare(typeOther: TimeInterval) -> (Bool)
  {
    return self.rawValue == typeOther.rawValue
  }
}





enum Days: Int
{
  case Monday = 0
  case Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday, AnyDay, Weekday, WeekendDay
  
  
  func toString() -> (String)
  {
    switch self
    {
      case .Monday:
        return "Monday"
      case .Tuesday:
        return "Tuesday"
      case .Wednesday:
        return "Wednesday"
      case .Thursday:
        return "Thursday"
      case .Friday:
        return "Friday"
      case .Saturday:
        return "Saturday"
      case .Sunday:
        return "Sunday"
      case .AnyDay:
        return "Day"
      case .Weekday:
        return "Weekday"
      case .WeekendDay:
        return "Weekend Day"
    }
  }
  
  func compare(typeOther: Days) -> (Bool)
  {
    return self.rawValue == typeOther.rawValue
  }
}





enum AlertRepeatType: Int
{
  case Simple = 0
  case Month, Days
  
  
  func toString() -> (String)
  {
    switch self
    {
      case .Simple:
        return "Simple"
      case .Month:
        return "Month"
      case .Days:
        return "Days"
    }
  }
  
  func compare(typeOther: AlertRepeatType) -> (Bool)
  {
    return self.rawValue == typeOther.rawValue
  }
}





enum AlertRepeatCellType: Int
{
  case Simple = 0
  case MonthPattern, MonthRate, DaysPattern, DaysRate
  
  
  init(fromAlertRepeatType base:AlertRepeatType)
  {
    switch (base)
    {
      case AlertRepeatType.Simple:
        self = .Simple
      case AlertRepeatType.Month:
        self = .MonthPattern
      case AlertRepeatType.Days:
        self = .DaysPattern
    }
  }
  
  func toString() -> (String)
  {
    switch self
    {
      case .Simple:
        return "Simple"
      case .MonthPattern:
        return "Month Pattern"
      case .MonthRate:
        return "Month Rate"
      case .DaysPattern:
        return "Days Pattern"
      case .DaysRate:
        return "Days Rate"
    }
  }
  
  func compare(typeOther: AlertRepeatCellType) -> (Bool)
  {
    return self.rawValue == typeOther.rawValue
  }
  
  func swapPatternRate() -> (AlertRepeatCellType)
  {
    switch self
    {
      case .Simple:
        return AlertRepeatCellType.Simple
      case .MonthPattern:
        return AlertRepeatCellType.MonthRate
      case .MonthRate:
        return AlertRepeatCellType.MonthPattern
      case .DaysPattern:
        return AlertRepeatCellType.DaysRate
      case .DaysRate:
        return AlertRepeatCellType.DaysPattern
    }
  }
  
  func isPattern() -> (Bool)
  {
    if (self =| [AlertRepeatCellType.MonthPattern, AlertRepeatCellType.DaysPattern])
    {
      return true
    }
    else
    {
      return false
    }
  }
  
  func isRate() -> (Bool)
  {
    if (self =| [AlertRepeatCellType.MonthRate, AlertRepeatCellType.DaysRate])
    {
      return true
    }
    else
    {
      return false
    }
  }
}





enum AlertTone: Int
{
  case NewMail = 0
  case MailSent, Voicemail, ReceivedMessage, SentMessage, Alarm, LowPower, SmsReceived1, SmsReceived2, SmsReceived3, SmsReceived4, SmsReceived1B, SmsReceived5B, SmsReceived6B, VoicemailB, TweetSent, Anticipate, Bloom, Calypso, ChooChoo, Descent, Fanfare, Ladder, Minuet, NewsFlash, Noir, SherwoodForest, Spell, Suspense, Telegraph, Tiptoes, Typewriters, Update, Ussd, SIMToolkitCallDropped, SIMToolkitGeneralBeep, SIMToolkitNegativeACK, SIMToolkitPositiveACK, SIMToolkitSMS, Tink, CtBusy, CtCongestion, CtPathAck, CtError, CtCallWaiting, CtKeytone2, Lock, Unlock, TinkB, Tock, TockB, BeepBeep, RingerChanged, PhotoShutter, Shake, LongLowShortHigh, ShortDoubleHigh, ShortLowHigh, ShortDoubleLow, ShortDoubleLowB, Middle9ShortDoubleLow, VoicemailC, ReceivedMessageB, NewMailB, MailSentB, AlarmB, LockB, TockC, SmsReceived1C, SmsReceived2B, SmsReceived3B, SmsReceived4B, SmsReceived1D, SmsReceived5D, SmsReceived6D, VoicemailD, AnticipateB, BloomB, CalypsoB, ChooChooB, DescentB, FanfareB, LadderB, MinuetB, NewsFlashB, NoirB, SherwoodForestB, SpellB, SuspenseB, TelegraphB, TiptoesB, TypewritersB, UpdateB
  
  
  func toString() -> (String)
  {
    switch self
    {
    case .NewMail:
      return "newMail"
    case .MailSent:
      return "mailSent"
    case .Voicemail:
      return "voicemail"
    case .ReceivedMessage:
      return "receivedMessage"
    case .SentMessage:
      return "sentMessage"
    case .Alarm:
      return "alarm"
    case .LowPower:
      return "lowPower"
    case .SmsReceived1:
      return "smsReceived1"
    case .SmsReceived2:
      return "smsReceived2"
    case .SmsReceived3:
      return "smsReceived3"
    case .SmsReceived4:
      return "smsReceived4"
    case .SmsReceived1B:
      return "smsReceived1B"
    case .SmsReceived5B:
      return "smsReceived5B"
    case .SmsReceived6B:
      return "smsReceived6B"
    case .VoicemailB:
      return "voicemailB"
    case .TweetSent:
      return "tweetSent"
    case .Anticipate:
      return "anticipate"
    case .Bloom:
      return "bloom"
    case .Calypso:
      return "calypso"
    case .ChooChoo:
      return "chooChoo"
    case .Descent:
      return "descent"
    case .Fanfare:
      return "fanfare"
    case .Ladder:
      return "ladder"
    case .Minuet:
      return "minuet"
    case .NewsFlash:
      return "newsFlash"
    case .Noir:
      return "noir"
    case .SherwoodForest:
      return "sherwoodForest"
    case .Spell:
      return "spell"
    case .Suspense:
      return "suspense"
    case .Telegraph:
      return "telegraph"
    case .Tiptoes:
      return "tiptoes"
    case .Typewriters:
      return "typewriters"
    case .Update:
      return "update"
    case .Ussd:
      return "ussd"
    case .SIMToolkitCallDropped:
      return "sIMToolkitCallDropped"
    case .SIMToolkitGeneralBeep:
      return "sIMToolkitGeneralBeep"
    case .SIMToolkitNegativeACK:
      return "sIMToolkitNegativeACK"
    case .SIMToolkitPositiveACK:
      return "sIMToolkitPositiveACK"
    case .SIMToolkitSMS:
      return "sIMToolkitSMS"
    case .Tink:
      return "tink"
    case .CtBusy:
      return "ctBusy"
    case .CtCongestion:
      return "ctCongestion"
    case .CtPathAck:
      return "ctPathAck"
    case .CtError:
      return "ctError"
    case .CtCallWaiting:
      return "ctCallWaiting"
    case .CtKeytone2:
      return "ctKeytone2"
    case .Lock:
      return "lock"
    case .Unlock:
      return "unlock"
    case .TinkB:
      return "tinkB"
    case .Tock:
      return "tock"
    case .TockB:
      return "tockB"
    case .BeepBeep:
      return "beepBeep"
    case .RingerChanged:
      return "ringerChanged"
    case .PhotoShutter:
      return "photoShutter"
    case .Shake:
      return "shake"
    case .LongLowShortHigh:
      return "longLowShortHigh"
    case .ShortDoubleHigh:
      return "shortDoubleHigh"
    case .ShortLowHigh:
      return "shortLowHigh"
    case .ShortDoubleLow:
      return "shortDoubleLow"
    case .ShortDoubleLowB:
      return "shortDoubleLowB"
    case .Middle9ShortDoubleLow:
      return "middle9ShortDoubleLow"
    case .VoicemailC:
      return "voicemailC"
    case .ReceivedMessageB:
      return "receivedMessageB"
    case .NewMailB:
      return "newMailB"
    case .MailSentB:
      return "mailSentB"
    case .AlarmB:
      return "alarmB"
    case .LockB:
      return "lockB"
    case .TockC:
      return "tockC"
    case .SmsReceived1C:
      return "smsReceived1C"
    case .SmsReceived2B:
      return "smsReceived2B"
    case .SmsReceived3B:
      return "smsReceived3B"
    case .SmsReceived4B:
      return "smsReceived4B"
    case .SmsReceived1D:
      return "smsReceived1D"
    case .SmsReceived5D:
      return "smsReceived5D"
    case .SmsReceived6D:
      return "smsReceived6D"
    case .VoicemailD:
      return "voicemailD"
    case .AnticipateB:
      return "anticipateB"
    case .BloomB:
      return "bloomB"
    case .CalypsoB:
      return "calypsoB"
    case .ChooChooB:
      return "chooChooB"
    case .DescentB:
      return "descentB"
    case .FanfareB:
      return "fanfareB"
    case .LadderB:
      return "ladderB"
    case .MinuetB:
      return "minuetB"
    case .NewsFlashB:
      return "newsFlashB"
    case .NoirB:
      return "noirB"
    case .SherwoodForestB:
      return "sherwoodForestB"
    case .SpellB:
      return "spellB"
    case .SuspenseB:
      return "suspenseB"
    case .TelegraphB:
      return "telegraphB"
    case .TiptoesB:
      return "tiptoesB"
    case .TypewritersB:
      return "typewritersB"
    case .UpdateB:
      return "updateB"
    }
  }
  
  func soundID() -> (Int)
  {
    switch self
    {
    case .NewMail:
      return 1000
    case .MailSent:
      return 1001
    case .Voicemail:
      return 1002
    case .ReceivedMessage:
      return 1003
    case .SentMessage:
      return 1004
    case .Alarm:
      return 1005
    case .LowPower:
      return 1006
    case .SmsReceived1:
      return 1007
    case .SmsReceived2:
      return 1008
    case .SmsReceived3:
      return 1009
    case .SmsReceived4:
      return 1010
    case .SmsReceived1B:
      return 1012
    case .SmsReceived5B:
      return 1013
    case .SmsReceived6B:
      return 1014
    case .VoicemailB:
      return 1015
    case .TweetSent:
      return 1016
    case .Anticipate:
      return 1020
    case .Bloom:
      return 1021
    case .Calypso:
      return 1022
    case .ChooChoo:
      return 1023
    case .Descent:
      return 1024
    case .Fanfare:
      return 1025
    case .Ladder:
      return 1026
    case .Minuet:
      return 1027
    case .NewsFlash:
      return 1028
    case .Noir:
      return 1029
    case .SherwoodForest:
      return 1030
    case .Spell:
      return 1031
    case .Suspense:
      return 1032
    case .Telegraph:
      return 1033
    case .Tiptoes:
      return 1034
    case .Typewriters:
      return 1035
    case .Update:
      return 1036
    case .Ussd:
      return 1050
    case .SIMToolkitCallDropped:
      return 1051
    case .SIMToolkitGeneralBeep:
      return 1052
    case .SIMToolkitNegativeACK:
      return 1053
    case .SIMToolkitPositiveACK:
      return 1054
    case .SIMToolkitSMS:
      return 1055
    case .Tink:
      return 1057
    case .CtBusy:
      return 1070
    case .CtCongestion:
      return 1071
    case .CtPathAck:
      return 1072
    case .CtError:
      return 1073
    case .CtCallWaiting:
      return 1074
    case .CtKeytone2:
      return 1075
    case .Lock:
      return 1100
    case .Unlock:
      return 1101
    case .TinkB:
      return 1103
    case .Tock:
      return 1104
    case .TockB:
      return 1105
    case .BeepBeep:
      return 1106
    case .RingerChanged:
      return 1107
    case .PhotoShutter:
      return 1108
    case .Shake:
      return 1109
    case .LongLowShortHigh:
      return 1254
    case .ShortDoubleHigh:
      return 1255
    case .ShortLowHigh:
      return 1256
    case .ShortDoubleLow:
      return 1257
    case .ShortDoubleLowB:
      return 1258
    case .Middle9ShortDoubleLow:
      return 1259
    case .VoicemailC:
      return 1300
    case .ReceivedMessageB:
      return 1301
    case .NewMailB:
      return 1302
    case .MailSentB:
      return 1303
    case .AlarmB:
      return 1304
    case .LockB:
      return 1305
    case .TockC:
      return 1306
    case .SmsReceived1C:
      return 1307
    case .SmsReceived2B:
      return 1308
    case .SmsReceived3B:
      return 1309
    case .SmsReceived4B:
      return 1310
    case .SmsReceived1D:
      return 1312
    case .SmsReceived5D:
      return 1313
    case .SmsReceived6D:
      return 1314
    case .VoicemailD:
      return 1315
    case .AnticipateB:
      return 1320
    case .BloomB:
      return 1321
    case .CalypsoB:
      return 1322
    case .ChooChooB:
      return 1323
    case .DescentB:
      return 1324
    case .FanfareB:
      return 1325
    case .LadderB:
      return 1326
    case .MinuetB:
      return 1327
    case .NewsFlashB:
      return 1328
    case .NoirB:
      return 1329
    case .SherwoodForestB:
      return 1330
    case .SpellB:
      return 1331
    case .SuspenseB:
      return 1332
    case .TelegraphB:
      return 1333
    case .TiptoesB:
      return 1334
    case .TypewritersB:
      return 1335
    case .UpdateB:
      return 1336
    }
  }
  
  func compare(typeOther: AlertTone) -> (Bool)
  {
    return self.rawValue == typeOther.rawValue
  }
}





class Contract
{
  var title: String
  var type: Type
  var monetaryValue: Double
  var includeTip = false
  var tip: Int
  var includeInterest = false
  var interest: Double
  var lenders: SortableDictionary<String, Double>
  var lenderShares: Shares!
  var borrowers: SortableDictionary<String, Double>
  var borrowerShares: Shares!
  var useAlert: Bool
  var alertDate: NSDate
  var alertTime: NSDate
  var alertTone: AlertTone
  var alertNagRate: AlertNagRate
  var repeatAlert: Bool
  var alertRepeatType: AlertRepeatType
  var alertRepeatPattern: Any
  var alertRepeatInterval: Any
  var alertRepeatRate: Int
  var repeatFromCompleation: Bool
  var alertRepeatDate: NSDate
  var autoCompleteAlert: Bool
  
  var photo: [String]
  var video: [String]
  var sound: [String]
  var tags: [String]
  var dateCreated: NSDate
  var dateDue: NSDate
  var notes: String
  var simplifyGroupDebts: Bool
//  var locationCreated: AnyObject
//  var locationDue: AnyObject
  var priority: Int
  var isStarred: Bool
  var incompleteContractReminder: NSDate
  var reoccurringContractRate: NSTimeInterval
  var reoccurringContractDurration: NSDate
  var remindContractees: SortableDictionary<String, NSDate>
  var itemDescription: String
  var itemConditionReceived: String
  var itemConditionReturning: String
  var contractExpectationsMinimum: String
  var contractExpectationsMaximum: String
  
  
  init(title: String = "", photo: [String] = [], video: [String] = [], sound: [String] = [],remindDate: NSDate = NSDate(), remindTime: NSDate = NSDate(), remindTimeSpan: NSTimeInterval = NSTimeInterval(), useTimeSpan: Bool = false, type: Type = Type.Money, lenders: SortableDictionary<String, Double> = SortableDictionary(), borrowers: SortableDictionary<String, Double> = SortableDictionary(), lenderShares: Shares = Shares.Equal, borrowerShares: Shares = Shares.Equal, monetaryValue: Double = 0, includeTip: Bool = false, tip: Int = 15, includeInterest: Bool = false, interest: Double = 0, useAlert: Bool = false, alertDate: NSDate = NSDate(), alertTime: NSDate = NSDate(), alertTone: AlertTone = AlertTone(rawValue: 0)!, alertNagRate: AlertNagRate = AlertNagRate.Once, autoRepeatAlert: Bool = false, alertRepeatPattern: Any = Int(1), alertRepeatInterval: Any = TimeInterval.Day, alertRepeatRate: Int = 1, alertRepeatType: AlertRepeatType = AlertRepeatType.Simple, repeatFromCompleation: Bool = false, alertRepeatDate: NSDate = NSDate(), autoComplete: Bool = true,
    
    tags: [String] = [], dateCreated: NSDate = NSDate(), dateDue: NSDate = NSDate(), notes: String = "", simplifyGroupDebts: Bool = false,
//    locationCreated: AnyObject, locationDue: AnyObject,
    priority: Int = 0, isStarred: Bool = false, incompleteContractReminder: NSDate = NSDate(), reoccurringContractRate: NSTimeInterval = NSTimeInterval(), reoccurringContractDurration: NSDate = NSDate(), remindContractees: SortableDictionary<String, NSDate> = SortableDictionary(), itemDescription: String = "", itemConditionReceived: String = "", itemConditionReturning: String = "", contractExpectationsMinimum: String = "", contractExpectationsMaximum: String = "")
  {
    self.title = title
    self.photo = photo
    self.video = video
    self.sound = sound
    self.alertDate = remindDate
    self.alertTime = remindTime
    self.alertRepeatDate = alertRepeatDate
    self.repeatAlert = useTimeSpan
    self.type = type
    self.lenders = lenders
    self.borrowers = borrowers
    self.lenderShares = lenderShares
    self.borrowerShares = borrowerShares
    self.monetaryValue = monetaryValue
    self.includeTip = includeTip
    self.tip = tip
    self.includeInterest = includeInterest
    self.interest = interest
    self.useAlert = useAlert
    self.alertDate = alertDate
    self.alertTime = alertTime
    self.alertTone = alertTone
    self.alertNagRate = alertNagRate
    self.repeatAlert = autoRepeatAlert
    self.alertRepeatPattern = alertRepeatPattern
    self.alertRepeatInterval = alertRepeatInterval
    self.alertRepeatRate = alertRepeatRate
    self.alertRepeatType = alertRepeatType
    self.repeatFromCompleation = repeatFromCompleation
    self.alertRepeatDate = alertRepeatDate
    self.autoCompleteAlert = autoComplete
    
    self.tags = tags
    self.dateCreated = dateCreated
    self.dateDue = dateDue
    self.notes = notes
    self.simplifyGroupDebts = simplifyGroupDebts
//    self.locationCreated = locationCreated
//    self.locationDue = locationDue
    self.priority = priority
    self.isStarred = isStarred
    self.incompleteContractReminder = incompleteContractReminder
    self.reoccurringContractRate = reoccurringContractRate
    self.reoccurringContractDurration = reoccurringContractDurration
    self.remindContractees = remindContractees
    self.itemDescription = itemDescription
    self.itemConditionReceived = itemConditionReceived
    self.itemConditionReturning = itemConditionReturning
    self.contractExpectationsMinimum = contractExpectationsMinimum
    self.contractExpectationsMaximum = contractExpectationsMaximum
  }
  
  func overWrite(contract: Contract)
  {
    title  = contract.title
    photo  = contract.photo
    video  = contract.video
    sound  = contract.sound
    alertDate  = contract.alertDate
    alertTime  = contract.alertTime
    alertRepeatDate  = contract.alertRepeatDate
    repeatAlert  = contract.repeatAlert
    type  = contract.type
    lenders  = contract.lenders
    borrowers  = contract.borrowers
    lenderShares = contract.lenderShares
    borrowerShares = contract.borrowerShares
    monetaryValue  = contract.monetaryValue
    tip = contract.tip
    useAlert = contract.useAlert
    alertDate = contract.alertDate
    alertTime = contract.alertTime
    alertTone = contract.alertTone
    alertNagRate = contract.alertNagRate
    repeatAlert = contract.repeatAlert
    alertRepeatPattern = contract.alertRepeatPattern
    alertRepeatInterval = contract.alertRepeatInterval
    alertRepeatRate = contract.alertRepeatRate
    alertRepeatType = contract.alertRepeatType
    repeatFromCompleation = contract.repeatFromCompleation
    alertRepeatDate = contract.alertRepeatDate
    autoCompleteAlert = contract.autoCompleteAlert
    
    tags  = contract.tags
    dateCreated  = contract.dateCreated
    dateDue  = contract.dateDue
    notes  = contract.notes
    simplifyGroupDebts  = contract.simplifyGroupDebts
//    locationCreated  = contract.locationCreated
//    locationDue  = contract.locationDue
    priority  = contract.priority
    isStarred  = contract.isStarred
    incompleteContractReminder  = contract.incompleteContractReminder
    reoccurringContractRate  = contract.reoccurringContractRate
    reoccurringContractDurration  = contract.reoccurringContractDurration
    remindContractees  = contract.remindContractees
    itemDescription  = contract.itemDescription
    itemConditionReceived  = contract.itemConditionReceived
    itemConditionReturning  = contract.itemConditionReturning
    contractExpectationsMinimum  = contract.contractExpectationsMinimum
    contractExpectationsMaximum  = contract.contractExpectationsMaximum
  }
}





protocol Segueable
{
  func performSegue(#segueFrom: String, segueTo: String)
}





protocol MonetaryValue
{
  var monetaryValue: UITextField! { get }
}




protocol Focus
{
  func setFocus()
  func clearFocus()
}





protocol MonetaryCell
{
  var monetaryLabel: UILabel! { get }
}






protocol PartPercentageCell: MonetaryCell
{
  var monetaryShare: UILabel! { get }
}





protocol EditMonetaryCell: Focus
{
  var monetaryValue: UITextField! { get }
}





protocol EditPartCell: MonetaryCell, Focus
{
  var monetaryShare: UITextField! { get }
}





protocol EditPercentagesCell: PercentagePicker, MonetaryCell { }





protocol PickerCell
{
  weak var pickerPreLabel: UILabel! { get set }
  weak var pickerPostLabel: UILabel! { get set }
  weak var picker: UIPickerView! { get set }
  weak var pickerWidthConstraint: NSLayoutConstraint! { get set }
}





protocol PercentagePicker: PickerCell
{
  var saved: (onesDigit: Int!, tensDigit: Int!, hundredsDigit: Int!) { get set }
  var current: (onesDigit: Int!, tensDigit: Int!, hundredsDigit: Int!) { get set }
}





protocol SwitchCell
{
  weak var switchLabel: UILabel! { get set }
  weak var toggle: UISwitch! { get set }
  
  func flipToggle(sender: UISwitch)
}





protocol PickerSwitchCell: PickerCell, SwitchCell { }
