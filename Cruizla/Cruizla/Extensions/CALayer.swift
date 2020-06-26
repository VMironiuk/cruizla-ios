//
//  CALayer.swift
//  Cruizla
//
//  Created by Vladimir Mironiuk on 26.06.2020.
//  Copyright © 2020 Vladimir Mironiuk. All rights reserved.
//

import QuartzCore

extension CALayer {
  
  // MARK: - IB Properties
  
  @IBInspectable var shadowColorIB: UIColor? {
    get {
      if let color = self.shadowColor {
        return UIColor(cgColor: color)
      }
      return nil
    }
    set {
      self.shadowColor = newValue?.cgColor
    }
  }
}
