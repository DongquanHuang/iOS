//
//  HomeViewController.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/23/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    var managedObjectContext: NSManagedObjectContext?
    
    struct StoryBoardContants {
        static let NewRunSegue = "New Run"
        static let ShowBadgesSegue = "Show Badges"
    }
    
    @IBAction func startNewRun(sender: UIButton) {
        performSegueWithIdentifier(StoryBoardContants.NewRunSegue, sender: sender)
    }
    
    
    @IBAction func showBadges(sender: UIButton) {
        performSegueWithIdentifier(StoryBoardContants.ShowBadgesSegue, sender: sender)
    }
    
    @IBAction func unwindSegueToHomeViewController(segue:UIStoryboardSegue) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryBoardContants.NewRunSegue {
            let newRunVC = segue.destinationViewController as? NewRunViewController
            newRunVC?.managedObjectContext = managedObjectContext
        }
        else if segue.identifier == StoryBoardContants.ShowBadgesSegue {
            let badgesTVC = segue.destinationViewController as? BadgesTableViewController
            badgesTVC?.managedObjectContext = managedObjectContext
        }
    }
}
