//
//  MapView.swift
//  Cruizla
//
//  Created by Vladimir Mironiuk on 26.10.2019.
//  Copyright © 2019 Vladimir Mironiuk. All rights reserved.
//

import SwiftUI

struct MapView: UIViewRepresentable {
  private var glView: EAGLView = EAGLView(frame: .zero)
  
  func makeUIView(context: Context) -> EAGLView {
    glView
  }
  
  func updateUIView(_ uiView: EAGLView, context: Context) {
    if !uiView.drapeEngineCreated {
      uiView.createDrapeEngine()
    }
  }
}

struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView()
  }
}
