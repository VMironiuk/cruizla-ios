//
//  ZoomButtonsView.swift
//  Cruizla
//
//  Created by Vladimir Mironiuk on 23.07.2020.
//  Copyright © 2020 Vladimir Mironiuk. All rights reserved.
//

import UIKit

class ZoomButtonsView: UIView {
  
  // MARK: - Properties
  
  @IBOutlet private var contentView: UIView!
  
  // MARK: - Lifecycle
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.commonInit()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.commonInit()
  }
  
  // MARK: - Actions
  
  @IBAction func zoomInButtonTapped(_ sender: UIButton) {
    CRZFramework.shared().zoomIn()
  }
  
  @IBAction func zoomOutButtonTapped(_ sender: UIButton) {
    CRZFramework.shared().zoomOut()
  }
  
  // MARK: - Private
  
  private func commonInit() {
    self.backgroundColor = .clear
    self.translatesAutoresizingMaskIntoConstraints = false
    Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
    self.contentView.frame = self.bounds
    self.addSubview(self.contentView)
  }
}
