//
//  UncoverVerticalSegue.swift
//  iOU
//
//  Created by Tateni Urio on 11/20/14.
//  Copyright (c) 2014 Tateni Urio. All rights reserved.
//

import UIKit // Needed to find UIStoryboardSegue and UIViewController
@objc(UncoverVerticalSegue) // Your app will crash if you don't add this line, remember: Swift is still in Beta.

class UncoverVerticalSegue: UIStoryboardSegue
{
  override func perform()
  {
    let sourceViewController = self.sourceViewController 
    let destinationViewController = self.destinationViewController 
    let duplicatedSourceView: UIView = sourceViewController.view.snapshotViewAfterScreenUpdates(false) // Create a screenshot of the old view.
    // We add a screenshot of the old view (Bottom) above the new one (Top), it looks like nothing changed.
    destinationViewController.view.addSubview(duplicatedSourceView)
    
    // Our main view is now destinationViewController.
    sourceViewController.presentViewController(destinationViewController, animated: false, completion:
      {
        UIView.animateWithDuration(0.33, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations:
          {
            () -> Void in
            // This is the block affected by the animation. Duration: 0,33s. Options: Ease-Out speed curve. We slide the old view's screenshot at the bottom of the screen.
            duplicatedSourceView.transform = CGAffineTransformMakeTranslation(0, duplicatedSourceView.frame.size.height)
          },
          completion:
          {
            (finished: Bool) -> Void in
            // The animation is finished, we removed the old view's screenshot.
            duplicatedSourceView.removeFromSuperview()
          })
    })
  }
}