//
//  Map.swift
//  IosFinalProject
//
//  Created by 황윤구 on 6/16/24.
//

import Foundation
import UIKit
import MapKit

class Map {
    func addMarker(array: [MKPointAnnotation], mapView: MKMapView, at coordinate: CLLocationCoordinate2D) -> [MKPointAnnotation] {
        var annotations = array
        if annotations.count >= 2 { return annotations } // 최대 두 개의 마커만 추가
        
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
        
        return annotations
    }
    
    func addMarker2(mapView: MKMapView, depart: CLLocationCoordinate2D, arrive: CLLocationCoordinate2D) {
        let departAnnotation = MKPointAnnotation()
        departAnnotation.coordinate = depart
        departAnnotation.title = "출발지"
        let arriveAnnotation = MKPointAnnotation()
        arriveAnnotation.coordinate = arrive
        arriveAnnotation.title = "도착지"
        
        mapView.addAnnotation(departAnnotation)
        mapView.addAnnotation(arriveAnnotation)
    }
    
    func calculateRoute(mapView: MKMapView, from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping (CLLocationDistance?) -> Void) {
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
                completion(nil)
                return
            }
            
            // 첫 번째 경로 가져오기
            let route = response.routes[0]
            mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            // 경로의 길이
            let distance = route.distance
            print("Distance: \(distance) meters")
            
            // 경로 시각화를 위해 지도 영역 조정
            var rect = route.polyline.boundingMapRect
            rect = mapView.mapRectThatFits(rect, edgePadding: UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30))
            mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            
            completion(distance)
        }
    }
    
    func resizeMap(map: MKMapView) {
        // 중심 좌표 설정 (서울)
        let centerCoordinate = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
        
        // 축척 비율 설정
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        // 지도 영역 설정
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        
        // mapView에 설정한 region 적용
        map.setRegion(region, animated: true)
    }
}
