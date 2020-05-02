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

