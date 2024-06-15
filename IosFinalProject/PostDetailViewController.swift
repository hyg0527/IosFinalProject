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
    var annotations: [MKPointAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.isUserInteractionEnabled = false
        mapView.delegate = self
        resizeMap()
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
        
//        addMarker2(depart: depart2D!, arrive: arrive2D!)
        
        addMarker(at: depart2D!)
        addMarker(at: arrive2D!)
        calculateRoute(from: depart2D!, to: arrive2D!)
    }
    
    func convertCoordTo2D(coord: GeoPoint) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
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
//        mapView.deselectAnnotation(annotation, animated: false) // 선택 상태 해제
//        annotations.append(annotation) // 배열에 추가
    }
    
    func addMarker2(depart: CLLocationCoordinate2D, arrive: CLLocationCoordinate2D) {
        
        let departAnnotation = MKPointAnnotation()
        departAnnotation.coordinate = depart
        departAnnotation.title = "출발지"
        let arriveAnnotation = MKPointAnnotation()
        arriveAnnotation.coordinate = arrive
        arriveAnnotation.title = "도착지"
        
        mapView.addAnnotation(departAnnotation)
        mapView.addAnnotation(arriveAnnotation)
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
            self.distanceLabel.text = "거리: \(distance)m"
            
            // 경로 시각화를 위해 지도 영역 조정
            var rect = route.polyline.boundingMapRect
            rect = self.mapView.mapRectThatFits(rect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
//        let directions = MKDirections(request: directionRequest)
//                directions.calculate { [weak self] (response, error) in
//                    guard let self = self else { return }
//                    if let error = error {
//                        print("Error calculating route: \(error)")
//                        return
//                    }
//                    
//                    guard let route = response?.routes.first else { return }
//                    
//                    DispatchQueue.main.async {
//                        self.mapView.addOverlay(route.polyline, level: .aboveRoads)
//                        
//                        var rect = route.polyline.boundingMapRect
//                        rect = self.mapView.mapRectThatFits(rect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
//                        self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
//                    }
//                    
//                    let distance = route.distance
//                    distanceLabel.text = "거리: \(distance)m"
//                }
    }
    
    func resizeMap() {
        // 중심 좌표 설정 (서울)
        let centerCoordinate = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
        
        // 축척 비율 설정: latitudeDelta와 longitudeDelta 값이 작을수록 확대, 값이 클수록 축소
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        // 지도 영역 설정
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        
        // mapView에 설정한 region을 적용
        mapView.setRegion(region, animated: false)
    }
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
