//
//  ViewController.swift
//  MyUIKit
//
//  Created by Vladimir Mironiuk on 15.02.2020.
//  Copyright © 2020 Vladimir Mironiuk. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
  
  // MARK: - Properties
  
  @IBOutlet weak var mapView: EAGLView!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setFocus(true)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if !self.mapView.drapeEngineCreated {
      self.mapView.createDrapeEngine()
    }
  }
  
  // MARK: - Map Navigation
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let safeEvent = event {
      CRZDrapeFrontendAdapter.shared().send(
        .touchDown, withTouches: touches, event: safeEvent, mapView: self.mapView)
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let safeEvent = event {
      CRZDrapeFrontendAdapter.shared().send(
        .touchMove, withTouches: nil, event: safeEvent, mapView: self.mapView)
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let safeEvent = event {
      CRZDrapeFrontendAdapter.shared().send(
        .touchUp, withTouches: touches, event: safeEvent, mapView: self.mapView)
    }
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let safeEvent = event {
      CRZDrapeFrontendAdapter.shared().send(
        .touchCancel, withTouches: touches, event: safeEvent, mapView: self.mapView)
    }
  }
  
  // MARK: - Public
  
  /**
   
   */
  func terminate() {
    self.mapView.deallocateNative()
  }
  
  /**
   
   */
  func setFocus(_ focus: Bool) {
    self.mapView.setPresentAvailable(focus)
  }
}

