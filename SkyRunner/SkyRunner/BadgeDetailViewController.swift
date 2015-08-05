//
//  BadgeDetailViewController.swift
//  SkyRunner
//
//  Created by Peter Huang on 8/5/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit

class BadgeDetailViewController: UIViewController {
    
    // MARK: - Constants
    struct NumberDecimalPlaceConstants {
        static let DecimalPlaceConstants = 3
    }
    
    struct AchievementConstants {
        static let SilverSpeedFactor = 1.05
        static let GoldSpeedFactor = 1.1
    }
    
    // MARK: - Variables
    var badgeEarnStatus: BadgeEarnStatus?
    
    // MARK: - IBOutlets
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var badgeNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var earnRunLabel: UILabel!
    @IBOutlet weak var bestRunLabel: UILabel!
    @IBOutlet weak var silverRunLabel: UILabel!
    @IBOutlet weak var goldRunLabel: UILabel!
    @IBOutlet weak var silverImageView: UIImageView!
    @IBOutlet weak var goldImageView: UIImageView!
    
    // MARK: - Override methods
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureView()
    }
    
    // MARK: - IBActions
    @IBAction func showInfo(sender: UIButton) {
    }
    
    // MARK: - Private methods
    private func configureView() {
        if badgeEarnStatus == nil {
            return
        }
        
        configureBadgeImageView()
        configureLabels()
        configureAchievementImageViews()
    }
    
    private func configureBadgeImageView() {
        badgeImageView.image = UIImage(named: badgeEarnStatus!.badge!.imageName!)
    }
    
    private func configureLabels() {
        configureBadgeNameLabel()
        configureDistanceLabel()
        configureEarnRunLabel()
        configureSilverRunLabel()
        configureGoldRunLabel()
    }
    
    private func configureAchievementImageViews() {
        configureSilverAchievementImageView()
        configureGoldAchievementImageView()
    }
    
    private func configureBadgeNameLabel() {
        badgeNameLabel.text = badgeEarnStatus?.badge?.name
    }
    
    private func configureDistanceLabel() {
        distanceLabel.text = "Distance: " + badgeEarnStatus!.badge!.distance!.round(NumberDecimalPlaceConstants.DecimalPlaceConstants).description
    }
    
    private func configureEarnRunLabel() {
        let timestamp = badgeEarnStatus!.earnRun!.timestamp
        let dateString = timeFormatter().stringFromDate(timestamp)
        
        earnRunLabel.text = "Earned: " + dateString
    }
    
    private func configureSilverRunLabel() {
        let silverSpeed = (earnRunSpeed() * AchievementConstants.SilverSpeedFactor).round(NumberDecimalPlaceConstants.DecimalPlaceConstants)
        silverRunLabel.text = "Silver: " + "Run " + silverSpeed.description + " m/s to earn"
    }
    
    private func configureGoldRunLabel() {
        let goldSpeed = (earnRunSpeed() * AchievementConstants.GoldSpeedFactor).round(NumberDecimalPlaceConstants.DecimalPlaceConstants)
        goldRunLabel.text = "Gold: " + "Run " + goldSpeed.description + " m/s to earn"
    }
    
    private func configureSilverAchievementImageView() {
        if badgeEarnStatus?.silverRun != nil {
            silverImageView.hidden = false
        }
        else {
            silverImageView.hidden = true
        }
    }
    
    private func configureGoldAchievementImageView() {
        if badgeEarnStatus?.goldRun != nil {
            goldImageView.hidden = false
        }
        else {
            goldImageView.hidden = true
        }
    }
    
    private func timeFormatter() -> NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .MediumStyle
        
        return formatter
    }
    
    private func earnRunSpeed() -> Double {
        if let earnRun = badgeEarnStatus?.earnRun {
            return earnRun.distance / earnRun.duration
        }
        
        return 0.0
    }
}
