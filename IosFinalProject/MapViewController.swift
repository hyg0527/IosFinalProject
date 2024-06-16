//
//  MapViewController.swift
//  IosFinalProject
//
//  Created by 황윤구 on 6/14/24.
//

import UIKit
import MapKit
import CoreLocation

protocol SendCoordinate {
    func sendCord(depart: CLLocationCoordinate2D, arrive: CLLocationCoordinate2D)
}

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var routeBtn: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var mapInstance = Map()
    var locationManager: CLLocationManager!
    var annotations: [MKPointAnnotation] = []
    
    var coordDelegate: SendCoordinate?
    
    var depart: CLLocationCoordinate2D?
    var arrive: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MapView 초기화 및 설정
        mapView.delegate = self
        initMapView()
    }
    
    func initMapView() {
        // 위치 관리자 초기화 및 설정
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        mapInstance.resizeMap(map: mapView)
        
        let mapTapGesture = UITapGestureRecognizer(target: self, action: #selector(placeMarker))
        mapView.addGestureRecognizer(mapTapGesture)
    }
    
    @objc func placeMarker(_ sender: UITapGestureRecognizer) {
        // 탭핑한 위치의 좌표 얻기
        let locationInView = sender.location(in: mapView)
        let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
        
        // 현재 탭핑한 위치에 annotation이 있는지 확인
        let tappedAnnotations = mapView.annotations.filter { annotation in
            let point = mapView.convert(annotation.coordinate, toPointTo: mapView)
            let rect = CGRect(x: point.x - 30, y: point.y - 30, width: 60, height: 60)
            return rect.contains(locationInView)
        }
        
        if tappedAnnotations.isEmpty { // 마커 추가
            annotations = mapInstance.addMarker(array: annotations, mapView: mapView, at: coordinate)
        }
    }
    
    @IBAction func setRoute(_ sender: UIButton) {
        
        for annotation in annotations {
            if annotation.title == "출발지" {
                depart = annotation.coordinate
            } else if annotation.title == "도착지" {
                arrive = annotation.coordinate
            }
        }
        mapInstance.calculateRoute(mapView: mapView, from: depart!, to: arrive!) { distance in
            if let distance = distance {
                    print("거리: \(distance)m")
                } else {
                    print("거리 계산 오류")
                }
        }
        routeBtn.isEnabled = false
    }
    
    @IBAction func completeSetRoute(_ sender: UIBarButtonItem) {
        coordDelegate?.sendCord(depart: depart!, arrive: arrive!)
        self.navigationController?.popViewController(animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MKPointAnnotation {
            mapView.removeAnnotation(annotation)
            
            if let index = annotations.firstIndex(of: annotation) {
                annotations.remove(at: index)
                
            }
            updateMarkerTitles()
        }
    }
    
    // 마커 제목 업데이트 메서드
    func updateMarkerTitles() {
        // "출발지"와 "도착지" 마커의 상태를 확인
        let startMarkers = annotations.filter { $0.title == "출발지" }
        let destinationMarkers = annotations.filter { $0.title == "도착지" }
        
        // "출발지"가 없는 경우, 새로운 마커 추가 시 "출발지"로 설정
        if startMarkers.isEmpty && annotations.count < 2 {
            if let lastAdded = annotations.last {
                if lastAdded.title != "출발지" {
                    lastAdded.title = "출발지"
                }
            }
        }
    }
}
