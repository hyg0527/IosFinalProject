//
//  PostDetailViewController.swift
//  IosFinalProject
//
//  Created by 황윤구 on 6/14/24.
//

import UIKit
import MapKit
import FirebaseFirestore

class PostDetailViewController: UIViewController {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var titleDetail: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    var post: Post?
    var postImage: UIImage?
    var depart2D: CLLocationCoordinate2D?
    var arrive2D: CLLocationCoordinate2D?
    
    var mapInstance = Map()
    var annotations: [MKPointAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.isUserInteractionEnabled = false
        mapView.delegate = self
        mapInstance.resizeMap(map: mapView)
        loadPostData()
    }
    
    func loadPostData() {
        if let post = post {
            userName.text = "작성자: " + post.user
            titleDetail.text = post.title
            comment.text = post.comment
            
        }
        if let image = postImage {
            imageView.image = image.resized(to: CGSize(width: 300, height: 200))
        }
        
        loadMapData()
    }
    
    func loadMapData() {
        depart2D = convertCoordTo2D(coord: post!.depart)
        arrive2D = convertCoordTo2D(coord: post!.arrive)
        
        mapInstance.addMarker2(mapView: mapView, depart: depart2D!, arrive: arrive2D!)
        
        mapInstance.calculateRoute(mapView: mapView, from: depart2D!, to: arrive2D!) { distance in
            if let distance = distance {
                self.distanceLabel.text = "거리: \(distance)m"
            } else {
                print("Failed to calculate route distance")
            }
        }
    }
    
    func convertCoordTo2D(coord: GeoPoint) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
    }
    
//    func calculateRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
//        let sourcePlacemark = MKPlacemark(coordinate: source)
//        let destinationPlacemark = MKPlacemark(coordinate: destination)
//        
//        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
//        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
//        
//        let directionRequest = MKDirections.Request()
//        directionRequest.source = sourceMapItem
//        directionRequest.destination = destinationMapItem
//        directionRequest.transportType = .walking
//        
////        let directions = MKDirections(request: directionRequest)
////                directions.calculate { [weak self] (response, error) in
////                    guard let self = self else { return }
////                    if let error = error {
////                        print("Error calculating route: \(error)")
////                        return
////                    }
////                    
////                    guard let route = response?.routes.first else { return }
////                    
////                    DispatchQueue.main.async {
////                        self.mapView.addOverlay(route.polyline, level: .aboveRoads)
////                        
////                        var rect = route.polyline.boundingMapRect
////                        rect = self.mapView.mapRectThatFits(rect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
////                        self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
////                    }
////                    
////                    let distance = route.distance
////                    distanceLabel.text = "거리: \(distance)m"
////                }
//    }
}

extension PostDetailViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor.red
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer()
    }
}
