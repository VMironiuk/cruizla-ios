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
    self.mapView.setPresentAvailable(true)
    self.registerNotifications()
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
  
  // MARK: - Private
  
  // MARK: - Notifications Handling
  
  private func registerNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(onSceneDidDisconnectNotification(_:)),
      name: UIScene.didDisconnectNotification,
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(onSceneDidActivateNotification(_:)),
      name: UIScene.didActivateNotification,
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(onSceneWillDeactivateNotification(_:)),
      name: UIScene.willDeactivateNotification,
      object: nil)
  }
  
  @objc private func onSceneDidDisconnectNotification(_ notification: NSNotification) {
    self.mapView.deallocateNative()
  }
  
  @objc private func onSceneDidActivateNotification(_ notification: NSNotification) {
    self.mapView.setPresentAvailable(true)
  }

  @objc private func onSceneWillDeactivateNotification(_ notification: NSNotification) {
    self.mapView.setPresentAvailable(false)
  }
}

