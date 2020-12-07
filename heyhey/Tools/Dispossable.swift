//
//  Dispossable.swift
//  heyhey
//
//  Created by Vlad Tretiak on 06.12.2020.
//

import Foundation

public protocol Dispossable {
  func dispose()
}

class DispossableBlock: Dispossable {
  let block: () -> Void
  
  init(block: @escaping () -> Void) {
    self.block = block
  }
  
  func dispose() {
    block()
  }
  
  deinit {
    dispose()
  }
  
}
