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
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if !self.mapView.drapeEngineCreated {
      self.mapView.createDrapeEngine()
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.registerNotifications()
    
    let firstLaunchChecker = FirstLaunchChecker(
      userDefaults: .standard,
      key: K.UserDefaultsKey.firstLaunchKey)
    
    if firstLaunchChecker.isFirstLaunch {
      CRZFrameworkAdapter.sharedFramework().switchMyPositionNextMode()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.unregisterNotifications()
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
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(onProcessUserPositionModePendingPositionNotification(_:)),
      name: NSNotification.Name.CRZFrameworkUserPositionModePendingPosition,
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(onProcessUserPositionModeNotFollowNoPositionNotification(_:)),
      name: NSNotification.Name.CRZFrameworkUserPositionModeNotFollowNoPosition,
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(onProcessUserPositionModeNotFollowNotification(_:)),
      name: NSNotification.Name.CRZFrameworkUserPositionModeNotFollow,
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(onProcessUserPositionModeFollowNotification(_:)),
      name: NSNotification.Name.CRZFrameworkUserPositionModeFollow,
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(onProcessUserPositionModeFollowAndRotateNotification(_:)),
      name: NSNotification.Name.CRZFrameworkUserPositionModeFollowAndRotate,
      object: nil)
  }
  
  private func unregisterNotifications() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc private func onSceneDidDisconnectNotification(
    _ notification: NSNotification)
  {
    self.mapView.deallocateNative()
  }
  
  @objc private func onSceneDidActivateNotification(
    _ notification: NSNotification)
  {
    self.mapView.setPresentAvailable(true)
  }

  @objc private func onSceneWillDeactivateNotification(
    _ notification: NSNotification)
  {
    self.mapView.setPresentAvailable(false)
  }
  
  @objc private func onProcessUserPositionModePendingPositionNotification(
    _ notification: NSNotification)
  {
    print("CRZ_LOGGER: \(#function)")
  }
  
  @objc private func onProcessUserPositionModeNotFollowNoPositionNotification(
    _ notification: NSNotification)
  {
    print("CRZ_LOGGER: \(#function)")
  }

  @objc private func onProcessUserPositionModeNotFollowNotification(
    _ notification: NSNotification)
  {
    print("CRZ_LOGGER: \(#function)")
  }

  @objc private func onProcessUserPositionModeFollowNotification(
    _ notification: NSNotification)
  {
    print("CRZ_LOGGER: \(#function)")
  }

  @objc private func onProcessUserPositionModeFollowAndRotateNotification(
    _ notification: NSNotification)
  {
    print("CRZ_LOGGER: \(#function)")
  }
}

