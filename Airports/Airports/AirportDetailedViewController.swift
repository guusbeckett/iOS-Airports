/*
*
* AirportDetailedViewController.swift
* Airports
* Created by Guus Beckett on 14/09/15.
*
*   Copyright © 2015 Reupload. All rights reserved.
*
*
* Licensed under the EUPL, Version 1.1 or – as soon they will be approved by the European Commission - subsequent versions of the EUPL (the "Licence");
* You may not use this work except in compliance with the Licence.
* You may obtain a copy of the Licence at:
*
* http://ec.europa.eu/idabc/eupl
*
* Unless required by applicable law or agreed to in writing, software distributed under the Licence is distributed on an "AS IS" basis,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the Licence for the specific language governing permissions and limitations under the Licence.
*/

import UIKit
import MapKit

class AirportDetailedViewController: UIViewController{
    
    @IBOutlet var airportName : UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var airportMap: MKMapView!
    @IBOutlet weak var speedSlider: UISlider!
    var airport : Airport?
    var location : CLLocationCoordinate2D?
    var geodesic : MKGeodesicPolyline?
    // Animation aeroplane properties
    var aeroplaneAnnotation = ImagePointAnnotation()
    var aeroplaneAnnotationPosition = 0
    var aeroplaneDirection : Double?
    var speed = 5
    
    
    override func viewWillAppear(animated: Bool) {
        // Do any setup before loading the view.
        airportName.text =  "From " + (airport?.name)! + " to Amsterdam" //Set text
        location = airport?.getLocation()
        
        let locationAmsterdam = CLLocationCoordinate2D(latitude: 52.3086013794, longitude: 4.76388978958)
        
        //Arraylist with the two airports (Amsterdam and the selected airport)
        var locations : [CLLocationCoordinate2D]    //Let swift know the arraylist will contain CLLocationCoordinate2D objects
        locations = [location!, locationAmsterdam]  //Populate the arraylist
        
        geodesic = MKGeodesicPolyline(coordinates: &locations[0], count: 2)             //Calculate route to Amsterdam
        airportMap.addOverlay(geodesic!)                                                //Add route to map
        airportMap.insertOverlay(geodesic!, aboveOverlay: airportMap.overlays.last!)    //Draw the route on the map
        
        
        //Calculate latutude and longitude delta
        let latitudeDelta = locationAmsterdam.latitude + (location?.latitude)!
        let longitudeDelta = locationAmsterdam.longitude + (location?.longitude)!
        
        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        let focusRegion = MKCoordinateRegion(center: (geodesic?.coordinate)!, span: span)
        self.airportMap.setRegion(focusRegion, animated: true) //Set the map to focus on the route

        // Animation annotation
        
        aeroplaneAnnotation.title = "Aeroplane"
        aeroplaneAnnotation.imageName = "aeroplane"
        
        
        // Add annotation for the selected airport
        let airportPin = ImagePointAnnotation()
        airportPin.coordinate = location!
        print(location!)
        airportPin.title = airport?.name
        
        airportPin.imageName = "airport"
        
        airportMap.addAnnotation(airportPin)
        
        
        
        // Add annotation for Amsterdam airport
        let airportPinAmsterdam = ImagePointAnnotation()
        airportPinAmsterdam.coordinate = locationAmsterdam
        airportPinAmsterdam.title = "Locatie Amsterdam"
        
        airportPinAmsterdam.imageName = "airport"
        
        // Add the airport annotations to the map
        airportMap.addAnnotation(airportPinAmsterdam)
        
        airportMap.addAnnotation(aeroplaneAnnotation)
        
        //Calculate distance between the two airports
        
        let distanceLocation = CLLocation(latitude: (location?.latitude)!, longitude: (location?.longitude)!)
        let distanceLocationAmsterdam = CLLocation(latitude: locationAmsterdam.latitude, longitude: locationAmsterdam.longitude)
        let distance = distanceLocation.distanceFromLocation(distanceLocationAmsterdam)
        distanceLabel.text = String(format: "%.2fkm", distance / 1000)
        
        // Animation function
        
        updateAeroplanePosition()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    //Geodesic line properties
    func mapView (mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKGeodesicPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 2
            return polylineRenderer
        }
        return nil
    }
    
    //Slider to change speed
    @IBAction func changeAeroplaneSpeed(sender: AnyObject) {
        speed = Int(speedSlider.value)
    }
    //Button to toggle map type (Satelite and "normal")
    @IBAction func toggleMapType(sender: AnyObject) {
        toggleMapTyp()
    }
    
    //function to toggle map type
    func toggleMapTyp() {
        if(airportMap.mapType == MKMapType.Hybrid){
                airportMap.mapType = MKMapType.Standard
        }
        else {
            airportMap.mapType = MKMapType.Hybrid
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Animation function, updates the aeroplane position for animation like effect
    func updateAeroplanePosition() {
        
        if (self.aeroplaneAnnotationPosition + speed >= self.geodesic?.pointCount) {
            return                      //When the destination is reached, stop moving
        }
        let previousMapPoint = self.geodesic!.points()[self.aeroplaneAnnotationPosition] // Rotation

        self.aeroplaneAnnotationPosition += speed // Move to the next position on the line
        
        let nextMapPoint = self.geodesic?.points()[self.aeroplaneAnnotationPosition]
        
        aeroplaneDirection = XXDirectionBetweenPoints(previousMapPoint, destinationPoint: nextMapPoint!) // Rotation
        
        self.aeroplaneAnnotation.coordinate = MKCoordinateForMapPoint(nextMapPoint!) //Move the annotation to the next position on the line
        
        airportMap.viewForAnnotation(aeroplaneAnnotation)?.transform = CGAffineTransformRotate(self.airportMap.transform, CGFloat(XXDegreesToRadians(self.aeroplaneDirection!))) //Rotation
        
        self.performSelector("updateAeroplanePosition", withObject: nil, afterDelay: 0.03) // Repeat function with 0.03 sec delay
    }
    
    func mapView (mapView: MKMapView!, viewForAnnotation annotation: MKPointAnnotation) -> MKAnnotationView {
        //Add image to annotation on the map
        let PinIdentifier = "Aeroplane"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(PinIdentifier)
        if ((annotationView) == nil) {
            annotationView = MKAnnotationView.init(annotation: annotation, reuseIdentifier: PinIdentifier)
        }
        if (annotation is ImagePointAnnotation) { //Check if the annotation contains an image
            let imageAnnotation = annotation as! ImagePointAnnotation
            annotationView?.image = UIImage(named: imageAnnotation.imageName)
        }
        
        return annotationView!
    }

    
    // Rotation calculation functions
    
    func XXDirectionBetweenPoints(sourcePoint: MKMapPoint, destinationPoint: MKMapPoint) -> CLLocationDirection {
        let x = destinationPoint.x - sourcePoint.x
        let y = destinationPoint.y - sourcePoint.y
        
        return fmod(XXRadiansToDegrees(atan2(y, x)), 360.0) + 90.0;
    }
    
    func XXRadiansToDegrees(radians: Double) -> Double {
        return radians * 180.0 / M_PI;
    }
    
    func XXDegreesToRadians(degrees: Double) -> Double {
        return degrees * M_PI / 180.0;
    }
    
}

// Custom annotation class to add image string
class ImagePointAnnotation: MKPointAnnotation {
    var imageName: String!
}
