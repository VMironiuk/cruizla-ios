//
//  BottomMenuView.swift
//  Cruizla
//
//  Created by Vladimir Mironiuk on 27.06.2020.
//  Copyright © 2020 Vladimir Mironiuk. All rights reserved.
//

import UIKit

class BottomMenuView: UIView {
  
  // MARK: - Properties
  
  @IBOutlet private var contentView: UIView!
  @IBOutlet weak var searchImageView: UIImageView!
  @IBOutlet weak var compassImageView: UIImageView!
  @IBOutlet weak var locationImageView: UIImageView!
  @IBOutlet weak var menuImageView: UIImageView!
  
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
  }
  
  @IBAction func compassButtonTapped(_ sender: UIButton) {
  }
  
  @IBAction func locationButtonTapped(_ sender: UIButton) {
  }
  
  @IBAction func menuButtonTapped(_ sender: UIButton) {
    self.highlightImageView(self.menuImageView)
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
