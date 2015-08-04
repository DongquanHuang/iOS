//
//  NewRunViewController.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/23/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import MapKit
import HealthKit
import CoreData

class NewRunViewController: UIViewController {
    
    // MARK: - Constants
    struct StoryBoardConstants {
        static let ShowRunDetail = "Show Run Detail"
        static let CancelRun = "Cancel Run"
    }
    
    struct NumberDecimalPlaceConstants {
        static let DecimalPlaceConstants = 3
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var nextBadgeToEarnImageView: UIImageView!
    @IBOutlet weak var nextBadgeToEarnLabel: UILabel!
    
    // MARK: - Variables
    var managedObjectContext: NSManagedObjectContext?
    var timer: NSTimer?
    var locationManager: LocationManager?
    var skyRun = SkyRun()
    var timestamp = NSDate()
    var nextBadgeProvider: NextBadgeDataProvider = BadgeEarnStatusMgr()
    
    // MARK: - Override super class methods
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        prepareUIForNewRun()
    }
    
    override func viewWillDisappear(animated: Bool) {
        stopTimer()
        stopLocationUpdate()
        super.viewWillDisappear(animated)
    }
    
    // MARK: - IBActions
    @IBAction func startRun(sender: UIButton) {
        prepareUIForRunning()
        skyRun.timestamp = NSDate(timeIntervalSince1970: timestamp.timeIntervalSince1970)
        startTimer()
        startLocationUpdate()
    }
    
    @IBAction func stopRun(sender: UIButton) {
        stopTimer()
        stopLocationUpdate()
        performSegueWithIdentifier(StoryBoardConstants.ShowRunDetail, sender: sender)
    }
    
    @IBAction func cancelRun(sender: UIButton) {
        performSegueWithIdentifier(StoryBoardConstants.CancelRun, sender: sender)
    }
    
    // MARK: - Prepare segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryBoardConstants.ShowRunDetail {
            let detailVC = segue.destinationViewController as? DetailViewController
            detailVC?.managedObjectContext = managedObjectContext
            detailVC?.skyRun = skyRun
        }
    }
    
    // MARK: - Private methods -- UI elements
    private func prepareUIForNewRun() {
        preparePromptLabelUIForNewRun()
        prepareButtonUIForNewRun()
        prepareAchievementUIForNewRun()
    }
    
    private func preparePromptLabelUIForNewRun() {
        promptLabel.hidden = false
        distanceLabel.hidden = true
        timeLabel.hidden = true
        paceLabel.hidden = true
    }
    
    private func prepareButtonUIForNewRun() {
        startButton.hidden = false
        stopButton.hidden = true
        cancelButton.hidden = false
    }
    
    private func prepareAchievementUIForNewRun() {
        nextBadgeToEarnImageView.hidden = true
        nextBadgeToEarnLabel.hidden = true
    }
    
    private func prepareUIForRunning() {
        preparePromptLabelUIForRunning()
        prepareButtonUIForRunning()
        prepareAchievementUIForRunning()
    }
    
    private func preparePromptLabelUIForRunning() {
        promptLabel.hidden = true
        distanceLabel.hidden = false
        timeLabel.hidden = false
        paceLabel.hidden = false
    }
    
    private func prepareButtonUIForRunning() {
        startButton.hidden = true
        cancelButton.hidden = true
        stopButton.hidden = false
    }
    
    private func prepareAchievementUIForRunning() {
        nextBadgeToEarnImageView.hidden = false
        nextBadgeToEarnLabel.hidden = false
    }
    
    // MARK: - Private methods -- Using HealthKit to update labels
    private func updateDistanceLabel() {
        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: skyRun.distance)
        distanceLabel.text = "Distance: " + distanceQuantity.description
    }
    
    private func updateTimeLabel() {
        let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: skyRun.duration)
        timeLabel.text = "Time: " + secondsQuantity.description
    }
    
    private func updatePaceLabel() {
        let paceUnit = HKUnit.meterUnit().unitDividedByUnit(HKUnit.secondUnit())
        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: skyRun.distance / skyRun.duration)
        paceLabel.text = "Pace: " + paceQuantity.description
    }

    // MARK: - Private methods -- Timer
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1,
            target: self,
            selector: "eachSecond:",
            userInfo: nil,
            repeats: true)
    }
    
    func eachSecond(timer: NSTimer) {
        increaseSeconds()
        
        updateDistanceLabel()
        updateTimeLabel()
        updatePaceLabel()
    }
    
    private func increaseSeconds() {
        skyRun.duration += 1.0
    }
    
    // MARK: - Private methods -- Location Manager
    private func stopLocationUpdate() {
        locationManager?.stopLocationUpdate()
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    private func startLocationUpdate() {
        if locationManager == nil {
            locationManager = LocationManager()
        }
        locationManager?.delegate = self
        locationManager?.startLocationUpdate()
    }
}

// MARK: - MapView Delegate
extension NewRunViewController: MKMapViewDelegate {
    struct MapOverlayConstants {
        static let MK_StrokeColor = UIColor.blueColor()
        static let MK_LineWidth: CGFloat = 4.0
        static let MK_LocationDistance = 500.0
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if !overlay.isKindOfClass(MKPolyline) {
            return nil
        }
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        
        renderer.strokeColor = MapOverlayConstants.MK_StrokeColor
        renderer.lineWidth = MapOverlayConstants.MK_LineWidth
        
        return renderer
    }
}

// MARK: - Location Manager Delegate
extension NewRunViewController: LocationManagerDelegate {
    func locationUpdated() {
        updateRunDistance()
        appendLocationToRun()
        updateRunPath()
        updateNextBadgeInformation()
    }
    
    private func updateRunDistance() {
        let twoLocations = lastTwoLocations()
        let distance = distanceBetweenTwoLocations(twoLocations)
        skyRun.distance += distance
    }
    
    private func appendLocationToRun() {
        if let lastLocation = locationManager?.locations.last {
            skyRun.appendLocation(lastLocation)
        }
    }
    
    private func updateRunPath() {
        if let twoLocations = lastTwoLocations() {
            var coords = [CLLocationCoordinate2D]()
            coords.append(twoLocations.secondLastLocation.coordinate)
            coords.append(twoLocations.lastLocation.coordinate)
            
            let region = MKCoordinateRegionMakeWithDistance(twoLocations.lastLocation.coordinate, MapOverlayConstants.MK_LocationDistance, MapOverlayConstants.MK_LocationDistance)
            mapView.setRegion(region, animated: true)
            
            mapView.addOverlay(MKPolyline(coordinates: &coords, count: coords.count))
        }
    }
    
    private func updateNextBadgeInformation() {
        if let nextBadge = nextBadgeProvider.nextBadge(skyRun.distance) {
            nextBadgeToEarnImageView.image = UIImage(named: nextBadge.imageName!)
            let distanceToGo = nextBadge.distance! - skyRun.distance
            nextBadgeToEarnLabel.text = "\(distanceToGo.round(NumberDecimalPlaceConstants.DecimalPlaceConstants)) m to \(nextBadge.name!)"
        }
    }
    
    private func lastTwoLocations() -> (lastLocation: CLLocation, secondLastLocation: CLLocation)? {
        if let locations = locationManager?.locations {
            if locations.count > 1 {
                return (locations[locations.count - 1], locations[locations.count - 2])
            }
        }
        
        return nil
    }
    
    private func distanceBetweenTwoLocations(locations: (lastLocation: CLLocation, secondLastLocation: CLLocation)?) -> Double {
        if let validLocations = locations {
            return validLocations.lastLocation.distanceFromLocation(validLocations.secondLastLocation)
        }
        return 0.0
    }
}
