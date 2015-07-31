//
//  DetailViewController.swift
//  SkyRunner
//
//  Created by Peter Huang on 7/29/15.
//  Copyright (c) 2015 Peter Huang. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import HealthKit

class DetailViewController: UIViewController {
    
    // MARK: - Constants
    struct StoryBoardConstants {
        static let DiscardRun = "Discard Run"
    }
    
    struct LabelConstants {
        static let InvalidValue = "N/A"
    }
    
    struct MapConstants {
        static let LatitudeDelta = 1.1
        static let LongtitudeDelta = 1.1
    }
    
    // MARK: - Variables
    var managedObjectContext: NSManagedObjectContext?
    var skyRun: SkyRun?
    var colorfulPolylineGenerator = ColorfulPolylineGenerator()
    
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    
    // MARK: - IBActions
    @IBAction func saveRun(sender: UIButton) {
        saveSkyRun()
        goBackToHomeView()
    }
    
    @IBAction func discardRun(sender: UIButton) {
        goBackToHomeView()
    }
    
    // MARK: - Override super methods
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateLabelUI()
        loadRunMap()
    }
    
    // MARK: - Private methods -- Unwind Segue
    private func goBackToHomeView() {
        performSegueWithIdentifier(StoryBoardConstants.DiscardRun, sender: nil)
    }
    
    // MARK: - Private methods -- Core Data
    private func saveSkyRun() {
        if let context = managedObjectContext {
            
            // Note: please do NOT use:
            // "let savedRun = NSEntityDescription.insertNewObjectForEntityForName("Run",inManagedObjectContext: context) as! Run"
            // The reason is that currently Swift has one bug, for product target, above code works just fine
            // But for test product, above code returns nil
            
            // Uncomment following lines and try to debug for unit test & product target
            //let test1 = NSEntityDescription.insertNewObjectForEntityForName("Run", inManagedObjectContext: context)!
            //let test2 = test1 as? NSManagedObject
            //let test3 = test2 as? Run // Gets normal object for product target, but nil for unit test
            
            // Instead, we add one convenience init in model class
            let savedRun = Run(context: context)
            
            savedRun.distance = skyRun!.distance
            savedRun.duration = skyRun!.duration
            savedRun.timestamp = skyRun!.timestamp!
            
            var savedLocations = [Location]()
            for location in skyRun!.locations {
                let savedLocation = Location(context: context)
                savedLocation.timestamp = location.timestamp
                savedLocation.latitude = location.coordinate.latitude
                savedLocation.longitude = location.coordinate.longitude
                savedLocation.run = savedRun
                savedLocations.append(savedLocation)
            }
            
            savedRun.locations = NSSet(array: savedLocations)
            
            var error: NSError?
            let success = context.save(&error)
            if !success {
                println("Failed to save the run")
            }
        }
    }
    
    // MARK: - Private methods -- Update labels
    private func updateLabelUI() {
        updateDistanceLabel()
        updateDateLabel()
        updateTimeLabel()
        updatePaceLabel()
    }
    
    private func updateDistanceLabel() {
        if let theRun = skyRun {
            distanceLabel.text = "Distance: " + theRun.distance.description + " m"
        }
        else {
            distanceLabel.text = "Distance: " + LabelConstants.InvalidValue
        }
    }
    
    private func updateDateLabel() {
        if let theRun = skyRun {
            if let dateString = theRun.timestamp?.description {
                dateLabel.text = "Date: " + dateString
            }
        }
        else {
            dateLabel.text = "Date: " + LabelConstants.InvalidValue
        }
    }
    
    private func updateTimeLabel() {
        if let theRun = skyRun {
            timeLabel.text = "Duration: " + theRun.duration.description + " s"
        }
        else {
            timeLabel.text = "Duration: " + LabelConstants.InvalidValue
        }
    }
    
    private func updatePaceLabel() {
        if let theRun = skyRun {
            let paceUnit = HKUnit.meterUnit().unitDividedByUnit(HKUnit.secondUnit())
            let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: theRun.distance / theRun.duration)
            paceLabel.text = "Pace: " + paceQuantity.description
        }
        else {
            paceLabel.text = "Pace: " + LabelConstants.InvalidValue
        }
    }
    
    // MARK: - Private methods -- Show map
    private func loadRunMap() {
        updateMapRegion()
        removeOverlays()
        if canAddOverlays() {
            addOverlays()
        }
    }
    
    private func updateMapRegion() {
        mapView.setRegion(mapRegion(), animated: true)
    }
    
    private func mapRegion() -> MKCoordinateRegion {
        if let regionOfRunLocations = regionOfLocations(skyRun?.locations) {
            let regionCenter = centerOfRegion(regionOfRunLocations)
            let regionSpan = spanOfRegion(regionOfRunLocations)
            return MKCoordinateRegion(center: regionCenter, span: regionSpan)
        }
        
        return mapView.region
    }
    
    private func regionOfLocations(locations: [CLLocation]?) -> (minLat: Double, minLng: Double, maxLat: Double, maxLng: Double)? {
        if let validLocations = locations {
            if validLocations.count == 0 {
                return nil
            }
            
            let firstLocation = validLocations[0]
            
            var minLat = firstLocation.coordinate.latitude
            var minLng = firstLocation.coordinate.longitude
            var maxLat = minLat
            var maxLng = minLng
            
            for location in validLocations {
                minLat = min(minLat, location.coordinate.latitude)
                minLng = min(minLng, location.coordinate.longitude)
                maxLat = max(maxLat, location.coordinate.latitude)
                maxLng = max(maxLng, location.coordinate.longitude)
            }
            
            return (minLat, minLng, maxLat, maxLng)

        }
        else {
            return nil
        }
    }
    
    private func centerOfRegion(region: (minLat: Double, minLng: Double, maxLat: Double, maxLng: Double)) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: (region.minLat + region.maxLat) / 2, longitude: (region.minLng + region.maxLng) / 2)
    }
    
    private func spanOfRegion(region: (minLat: Double, minLng: Double, maxLat: Double, maxLng: Double)) -> MKCoordinateSpan {
        return MKCoordinateSpan(latitudeDelta: (region.maxLat - region.minLat) * MapConstants.LatitudeDelta, longitudeDelta: (region.maxLng - region.minLng) * MapConstants.LongtitudeDelta)
    }
    
    private func removeOverlays() {
        if let existingOverlays = mapView.overlays {
            mapView.removeOverlays(existingOverlays)
        }
    }
    
    private func canAddOverlays() -> Bool {
        return skyRun?.locations.count > 1
    }
    
    private func addOverlays() {
        mapView.addOverlays(overlaysForRun())
    }
    
    private func overlaysForRun() -> [ColorfulPolyline] {
        let colorfulOverlays = colorfulPolylineGenerator.produceColorfulPolylinesForLocations(skyRun!.locations)
        return colorfulOverlays
    }
    
}

// MARK: - MKMapViewDelegate
extension DetailViewController: MKMapViewDelegate {
    struct MapOverlayConstants {
        static let MK_LineWidth: CGFloat = 4.0
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if !overlay.isKindOfClass(ColorfulPolyline) {
            return nil
        }
        
        let polyline = overlay as! ColorfulPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        
        renderer.strokeColor = polyline.color
        renderer.lineWidth = MapOverlayConstants.MK_LineWidth
        
        return renderer
    }
}
