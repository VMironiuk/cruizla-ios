//
//  BottomMenuView.swift
//  Cruizla
//
//  Created by Vladimir Mironiuk on 27.06.2020.
//  Copyright © 2020 Vladimir Mironiuk. All rights reserved.
//

import UIKit

protocol BottomMenuViewDelegate: NSObjectProtocol {
  func bottomMenuViewDidTapSearchButton(_ bottomMenuView: BottomMenuView)
  func bottomMenuViewDidTapCompassButton(_ bottomMenuView: BottomMenuView)
  func bottomMenuViewDidTapLocationButton(_ bottomMenuView: BottomMenuView)
  func bottomMenuViewDidTapMenuButton(_ bottomMenuView: BottomMenuView)
}

class BottomMenuView: UIView {
  
  // MARK: - Properties
  
  @IBOutlet private var contentView: UIView!
  
  @IBOutlet private weak var searchImageView: UIImageView!
  @IBOutlet private weak var compassImageView: UIImageView!
  @IBOutlet private weak var locationImageView: UIImageView!
  @IBOutlet private weak var menuImageView: UIImageView!
  
  @IBOutlet private weak var searchButton: UIButton!
  @IBOutlet private weak var compassButton: UIButton!
  @IBOutlet private weak var locationButton: UIButton!
  @IBOutlet private weak var menuButton: UIButton!
  
  weak var delegate: BottomMenuViewDelegate?
  
  var isLocationFollowed: Bool = true {
    didSet {
      if self.isLocationFollowed == true {
        self.locationButton.isEnabled = false
        self.locationImageView.image = UIImage(systemName: "location")
        self.locationImageView.alpha = 0.5
      } else {
        self.locationButton.isEnabled = true
        self.locationImageView.image = UIImage(systemName: "scope")
        self.locationImageView.alpha = 1.0
      }
    }
  }
  
  // MARK: - Lifecycle
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.commonInit()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.commonInit()
  }
  
  @IBAction func searchButtonTapped(_ sender: UIButton) {
    self.highlightImageView(self.searchImageView)
    self.delegate?.bottomMenuViewDidTapSearchButton(self)
  }
  
  @IBAction func compassButtonTapped(_ sender: UIButton) {
    self.delegate?.bottomMenuViewDidTapCompassButton(self)
  }
  
  @IBAction func locationButtonTapped(_ sender: UIButton) {
    self.delegate?.bottomMenuViewDidTapLocationButton(self)
  }
  
  @IBAction func menuButtonTapped(_ sender: UIButton) {
    self.highlightImageView(self.menuImageView)
    self.delegate?.bottomMenuViewDidTapMenuButton(self)
  }
  
  // MARK: - Private
  
  private func commonInit() {
    self.backgroundColor = .clear
    self.translatesAutoresizingMaskIntoConstraints = false
    Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
    self.contentView.frame = self.bounds
    self.addSubview(self.contentView)
  }
  
  private func highlightImageView(_ imageView: UIImageView) {
    imageView.tintColor = .customButtonHighlighted
    UIView.animate(withDuration: 1.25, delay: 0, options: .curveEaseOut, animations: {
      imageView.tintColor = .customButtonNormal
    }, completion: nil)
  }
}
