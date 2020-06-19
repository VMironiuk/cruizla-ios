//
//  FirstLaunchChecker.swift
//  Cruizla
//
//  Created by Vladimir Mironiuk on 19.06.2020.
//  Copyright © 2020 Vladimir Mironiuk. All rights reserved.
//

import Foundation

// Checks whether the app was launched first time.
final class FirstLaunchChecker {
  
  // MARK: - Properties
  
  private let wasLauchedBefore: Bool
  
  var isFirstLaunch: Bool {
    !self.wasLauchedBefore
  }
  
  // MARK: - Lifecycle
  
  // Can be used for testing.
  // Example:
  //  let alwaysFirstLaunch = FirstLaunchChecker(
  //    getWasLaunchedBefore: { return false },
  //    setWasLaunchedBefore: { _ in })
  //
  //  if alwaysFirstLaunch.isFirstLaunch {
  //      // will always execute
  //  }
  init(getWasLaunchedBefore: () -> Bool, setWasLaunchedBefore: (Bool) -> ()) {
    self.wasLauchedBefore = getWasLaunchedBefore()
    if !self.wasLauchedBefore {
      setWasLaunchedBefore(true)
    }
  }
  
  // Can be used in production
  // Example:
  //  let firstLaunch = FirstLaunchChecker(
  //    userDefaults: .standard,
  //    key: "YOUR.KEY")
  //
  //  if firstLaunch.isFirstLaunch {
  //      // do things
  //  }
  convenience init(userDefaults: UserDefaults, key: String) {
    self.init(getWasLaunchedBefore: { () -> Bool in
      userDefaults.bool(forKey: key)
    }, setWasLaunchedBefore: {
      userDefaults.set($0, forKey: key)
    })
  }
}
