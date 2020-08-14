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
  @IBOutlet private weak var bottomMenuView: BottomMenuView!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.mapView.setPresentAvailable(true)
    self.bottomMenuView.delegate = self
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
    
    let framework = CRZFramework.shared()
    if firstLaunchChecker.isFirstLaunch {
      framework.switchMyPositionNextMode()
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
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(onProcessViewportAngleChangedNotification(_:)),
      name: NSNotification.Name.CRZFrameworkViewportAngleChanged,
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
    self.bottomMenuView.locationStatus = .pending
  }
  
  @objc private func onProcessUserPositionModeNotFollowNoPositionNotification(
    _ notification: NSNotification)
  {
    print("CRZ_LOGGER: \(#function)")
  }

  @objc private func onProcessUserPositionModeNotFollowNotification(
    _ notification: NSNotification)
  {
    self.bottomMenuView.locationStatus = .notFollow
  }

  @objc private func onProcessUserPositionModeFollowNotification(
    _ notification: NSNotification)
  {
    self.bottomMenuView.locationStatus = .follow
  }

  @objc private func onProcessUserPositionModeFollowAndRotateNotification(
    _ notification: NSNotification)
  {
    print("CRZ_LOGGER: \(#function)")
  }
  
  @objc private func onProcessViewportAngleChangedNotification(
    _ notification: NSNotification)
  {
    if let number = notification.userInfo?["angle"] as? NSNumber {
      self.bottomMenuView.processRotation(angle: number.doubleValue)
    }
  }
}

// MARK: - BottomMenuViewDelegate

extension MapViewController: BottomMenuViewDelegate {
  func bottomMenuViewDidTapSearchButton(_ bottomMenuView: BottomMenuView) {
    print("CRZ_LOGGER: \(#function)")
  }
  
  func bottomMenuViewDidTapCompassButton(_ bottomMenuView: BottomMenuView) {
    CRZFramework.shared().compassTapped()
  }
  
  func bottomMenuViewDidTapLocationButton(_ bottomMenuView: BottomMenuView) {
    CRZFramework.shared().switchMyPositionNextMode()
  }
  
  func bottomMenuViewDidTapMenuButton(_ bottomMenuView: BottomMenuView) {
    print("CRZ_LOGGER: \(#function)")
  }
}
