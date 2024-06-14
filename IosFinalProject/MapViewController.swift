//
//  MapViewController.swift
//  IosFinalProject
//
//  Created by 황윤구 on 6/14/24.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MapView 초기화 및 설정
//        mapView = MKMapView(frame: self.view.frame)
        mapView.delegate = self
//        self.view.addSubview(mapView)
        
        // 위치 관리자 초기화 및 설정
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // 두 지점의 좌표 설정
        let sourceLocation = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780) // 서울
        let destinationLocation = CLLocationCoordinate2D(latitude: 37.5803, longitude: 127.0456) // 부산
        
        // 경로 계산
        calculateRoute(from: sourceLocation, to: destinationLocation)
    }
    
    func calculateRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            
            // 첫 번째 경로 가져오기
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            // 경로의 길이
            let distance = route.distance
            print("Distance: \(distance) meters")
            
            // 경로 시각화를 위해 지도 영역 조정
            var rect = route.polyline.boundingMapRect
            rect = self.mapView.mapRectThatFits(rect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    // MKMapViewDelegate 메서드
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
