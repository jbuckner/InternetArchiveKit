//
//  Debouncer.swift
//  InternetArchiveKitExample
//
//  Created by Jason Buckner on 11/14/18.
//  Copyright © 2018 Jason Buckner. All rights reserved.
//

import Foundation

class Debouncer: NSObject {
  var callback: (() -> ())
  var delay: Double
  weak var timer: Timer?

  init(delay: Double, callback: @escaping (() -> ())) {
    self.delay = delay
    self.callback = callback
  }

  func call() {
    timer?.invalidate()
    let nextTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(fireNow), userInfo: nil, repeats: false)
    timer = nextTimer
  }

  @objc func fireNow() {
    self.callback()
  }
}
