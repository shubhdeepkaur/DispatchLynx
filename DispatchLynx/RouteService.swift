//
//  RouteService.swift
//  DispatchLynx
//
//  Created by Shubhdeep Kaur on 12/5/25.
//
import Foundation
import CoreLocation

struct RouteInfo {
    let distance: Double // in meters
    let duration: Double // in seconds
    let polyline: String // encoded route shape
    
    var distanceInMiles: Double {
        return distance * 0.000621371 // meters to miles
    }
    
    var durationInHours: Double {
        return duration / 3600 // seconds to hours
    }
    
    var formattedDistance: String {
        return String(format: "%.1f mi", distanceInMiles)
    }
    
    var formattedDuration: String {
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }
}

class RouteService: ObservableObject {
    private let apiKey = "5b3ce3597851110001cf6248e3ff6a8188c84a4e9ac34b4a8c5740d2"//from openrouteservice.org
    private let baseURL = "https://api.openrouteservice.org/v2/directions/driving-car"
    
    func calculateRoute(from pickupAddress: String, to dropoffAddress: String, completion: @escaping (RouteInfo?) -> Void) {
        // First geocode both addresses
        let mapService = MapService()
        
        mapService.geocodeAddress(pickupAddress) { pickupCoord in
            guard let pickupCoord = pickupCoord else {
                completion(nil)
                return
            }
            
            mapService.geocodeAddress(dropoffAddress) { dropoffCoord in
                guard let dropoffCoord = dropoffCoord else {
                    completion(nil)
                    return
                }
                
                // Now calculate route between coordinates
                self.calculateRouteBetweenCoordinates(
                    start: pickupCoord,
                    end: dropoffCoord,
                    completion: completion
                )
            }
        }
    }
    
    private func calculateRouteBetweenCoordinates(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, completion: @escaping (RouteInfo?) -> Void) {
        
        // 1. Use POST request with JSON body (recommended)
        guard let url = URL(string: baseURL) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("DispatchLynx/1.0", forHTTPHeaderField: "User-Agent")
        
        // 2. Create JSON request body
        let requestBody: [String: Any] = [
            "coordinates": [
                [start.longitude, start.latitude],
                [end.longitude, end.latitude]
            ],
            "instructions": false
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("Failed to create request body: \(error)")
            completion(nil)
            return
        }
        
        print("🌐 Making API request to OpenRouteService...")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Add DEBUG logging
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("❌ No data received")
                completion(nil)
                return
            }
            
            // Print response for debugging
            if let responseString = String(data: data, encoding: .utf8)?.prefix(500) {
                print("📦 Response: \(responseString)")
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    
                    // Check for errors
                    if let error = json["error"] as? [String: Any] {
                        print("❌ API Error: \(error)")
                        completion(nil)
                        return
                    }
                    
                    // Parse successful response
                    if let routes = json["routes"] as? [[String: Any]],
                       let firstRoute = routes.first,
                       let summary = firstRoute["summary"] as? [String: Any],
                       let distance = summary["distance"] as? Double,
                       let duration = summary["duration"] as? Double {
                        
                        print("✅ Route calculated: \(distance)m, \(duration)s")
                        
                        let routeInfo = RouteInfo(
                            distance: distance,
                            duration: duration,
                            polyline: "" // Can be empty for now
                        )
                        
                        DispatchQueue.main.async {
                            completion(routeInfo)
                        }
                    } else {
                        print("❌ Could not parse route data")
                        completion(nil)
                    }
                }
            } catch {
                print("❌ JSON error: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    private func encodeCoordinates(_ coordinates: [[Double]]) -> String {
        // Simple encoding for demo - in real app use proper polyline encoding
        return coordinates.map { "\($0[1]),\($0[0])" }.joined(separator: "|")
    }
}
