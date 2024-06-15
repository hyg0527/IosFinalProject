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

        resizeMap()
        
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
            addMarker(at: coordinate)
        }
    }
    
    func addMarker(at coordinate: CLLocationCoordinate2D) {
        if annotations.count >= 2 { return } // 최대 두 개의 마커만 추가
        
        // 마커 제목 설정
        let title: String
        if annotations.isEmpty {
            title = "출발지"
        } else {
            title = "도착지"
        }

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        
        mapView.addAnnotation(annotation)
        mapView.deselectAnnotation(annotation, animated: false) // 선택 상태 해제
        annotations.append(annotation) // 배열에 추가
    }
    
    func calculateRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .walking
        
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
    
    func resizeMap() {
        // 중심 좌표 설정 (서울)
        let centerCoordinate = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
        
        // 축척 비율 설정: latitudeDelta와 longitudeDelta 값이 작을수록 확대, 값이 클수록 축소
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        // 지도 영역 설정
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        
        // mapView에 설정한 region을 적용
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func setRoute(_ sender: UIButton) {
        
        for annotation in annotations {
            if annotation.title == "출발지" {
                depart = annotation.coordinate
            } else if annotation.title == "도착지" {
                arrive = annotation.coordinate
            }
        }
        calculateRoute(from: depart!, to: arrive!)
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
