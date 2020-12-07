//
//  Models.swift
//  heyhey
//
//  Created by Vlad Tretiak on 05.12.2020.
//

import Foundation

struct DataModel: Decodable {
   let id: String
   let rate: Int
   let text: String
   let id_user: String
   let id_entry: String
}

// MARK: - Registration
struct Registration: Decodable {
    let success: Bool?
    let token: String?
    let message: String?
}

// MARK: - PrdoductModel
struct ProductModel: Decodable {
    let id: Int
    var img: String?
    let title, text: String?
}

// MARK: - CurrentProductModel
struct CurrentProductModel: Codable {
    let id: Int
    let product: Int?
    let createdBy: CreatedBy?
    let rate: Int?
    let text: String?

    enum CodingKeys: String, CodingKey {
        case id, product
        case createdBy = "created_by"
        case rate, text
    }
}

// MARK: - CreatedBy
struct CreatedBy: Codable {
    let id: Int
    let username: String
}


struct PostResponse: Codable{
    let reviewId: Int?
    
    enum CodingKeys: String, CodingKey {
        case reviewId = "review_id"
    }
}
