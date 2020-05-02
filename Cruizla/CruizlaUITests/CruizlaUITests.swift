//
//  CruizlaUITests.swift
//  CruizlaUITests
//
//  Created by Vladimir Mironiuk on 9/7/19.
//  Copyright © 2019 Vladimir Mironiuk. All rights reserved.
//

import XCTest

class CruizlaUITests: XCTestCase {
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the
    // class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
    
    // UI tests must launch the application that they test. Doing this in setup will make sure it
    // happens for each test method.
    XCUIApplication().launch()
    
    // In UI tests it’s important to set the initial state - such as interface orientation -
    // required for your tests before they run. The setUp method is a good place to do this.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in
    // the class.
  }
  
  func testMapInteraction() {
    let element = XCUIApplication()
      .children(matching: .window).element(boundBy: 0)
      .children(matching: .other).element
      .children(matching: .other).element
      .children(matching: .other).element
      .children(matching: .other).element
    
    element.swipeLeft()
    element.swipeLeft()
    element.swipeRight()
    element.swipeRight()
    element.tap()
    element.tap()
  }
}
