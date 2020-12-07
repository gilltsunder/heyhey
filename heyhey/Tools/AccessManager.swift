//
//  AccessManager.swift
//  heyhey
//
//  Created by Vlad Tretiak on 07.12.2020.
//

import Foundation

class AccessManager {
    
    public static let shared = AccessManager()
    
    var isPreviewMode: Bool {
        let key = DAKeychain.shared[tokenKey]
        return key == preview
    }
}
