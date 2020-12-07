//
//  Router.swift
//  heyhey
//
//  Created by Vlad Tretiak on 04.12.2020.
//

import Foundation

enum Router {
    
    case login(userName: String, userPass: String)
    case registration(userName: String, userPass: String)
    case getProducts
    case getCurrentProduct(path: String)
    case postComment(path: String, comment: String, rate: Int)
    
    var header: [String: String]? {
        switch self {
        case .postComment:
            guard let token = accessToken, token != preview else { return nil }
            return ["Authorization": "Token \(token)"]
        default:
            return nil
        }
        //        guard let token = accessToken, token != preview else { return nil }
        //            return ["Authorization": "Token \(token)"]
    }
    
    var accessToken: String? {
        DAKeychain.shared[tokenKey]
    }
    
    var httpBody: Data? {
        switch self {
        case .registration, .login, .postComment:
            guard let data = try? JSONSerialization.data(withJSONObject: self.body, options: .prettyPrinted) else {
                return nil
            }
            return data
        default :
            return nil
        }
    }
    
    var body: [String: Any] {
        switch self {
        case .registration(let userName, let userPass), .login(let userName, let userPass):
            return ["username" : userName, "password": userPass]
        case .postComment(_, let comment, let rate):
            return ["rate" : rate, "text": comment]
        default:
            return [:]
        }
    }
    
    var scheme: String {
        return "https"
    }
    
    var host: String {
        return "smktesting.herokuapp.com"
    }
    
    var path: String {
        switch self {
        case .registration:
            return "/api/register/"
        case .login:
            return "/api/login/"
        case .getProducts:
            return "/api/products/"
        case .getCurrentProduct(let path):
            return "/api/reviews/\(path)"
        case .postComment(let path, _, _):
            return "/api/reviews/\(path)"
        }
    }
    
    var parameters: [URLQueryItem] {
        return []
    }
    
    var method: String {
        switch self {
        case .getProducts, .getCurrentProduct:
            return "GET"
        case .registration, .login, .postComment:
            return "POST"
        }
    }
}
