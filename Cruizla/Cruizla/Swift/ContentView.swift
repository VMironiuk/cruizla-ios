//
//  ContentView.swift
//  Cruizla
//
//  Created by Vladimir Mironiuk on 15.10.2019.
//  Copyright © 2019 Vladimir Mironiuk. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    MapView()
      .edgesIgnoringSafeArea(.all)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
