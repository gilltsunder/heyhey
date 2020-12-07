//
//  NetworkService.swift
//  heyhey
//
//  Created by Vlad Tretiak on 04.12.2020.
//

import Foundation


class NetworkService {
    
    func request<T: Decodable>(router: Router, model: T.Type, completion: @escaping (T?) -> ()) {
        
        var components = URLComponents()
        components.scheme = router.scheme
        components.host = router.host
        components.path = router.path
        components.queryItems = router.parameters
        
        let session = URLSession(configuration: .default)
        guard let url = components.url else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = router.header
        urlRequest.httpMethod = router.method
        urlRequest.httpBody = router.httpBody
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let dataTask = session.dataTask(with: urlRequest) { data, response, error in
            
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            guard response != nil else {
                print("no response")
                return
            }
            guard let data = data else {
                print("no data")
                return
            }
            
            let decode = self.decodeJSON(type: model.self, from: data)
            guard let object = decode else { return }
            DispatchQueue.main.async {
                completion(object)
            }
        }
        dataTask.resume()
    }
    
    private func decodeJSON<T: Decodable>(type: T.Type, from: Data?) -> T? {
        let decoder = JSONDecoder()
        guard let data = from else { return nil }
        
        do {
            let objects = try decoder.decode(type.self, from: data)
            return objects
        } catch let jsonError {
            print("Failed to decode JSON", jsonError)
            return nil
        }
    }
}
