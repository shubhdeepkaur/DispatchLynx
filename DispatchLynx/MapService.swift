//
//  MapService.swift
//  DispatchLynx
//
//  Created by Shubhdeep Kaur on 11/24/25.
//
import Foundation
import CoreLocation

class MapService: ObservableObject {
    func geocodeAddress(_ address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Try multiple free geocoding services, trickiest part for me
        let services = [
            "https://nominatim.openstreetmap.org/search?format=json&q=\(encodedAddress)",
            "https://geocode.maps.co/search?q=\(encodedAddress)"
        ]
        
        tryNextService(services: services, index: 0, completion: completion)
    }
    
    private func tryNextService(services: [String], index: Int, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        guard index < services.count else {
            completion(nil)
            return
        }
        
        guard let url = URL(string: services[index]) else {
            tryNextService(services: services, index: index + 1, completion: completion)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("DispatchLynx/1.0", forHTTPHeaderField: "User-Agent")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                       let firstResult = jsonArray.first,
                       let latString = firstResult["lat"] as? String,
                       let lonString = firstResult["lon"] as? String,
                       let lat = Double(latString),
                       let lon = Double(lonString) {
                        
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        DispatchQueue.main.async {
                            completion(coordinate)
                        }
                        return
                    }
                } catch {
                }
            }
            self.tryNextService(services: services, index: index + 1, completion: completion)
        }
        task.resume()
    }
}
