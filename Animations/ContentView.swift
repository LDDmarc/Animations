//
//  ContentView.swift
//  Animations
//
//  Created by Дарья Леонова on 19.07.2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                ImplicitAnimations()
            }
            .tabItem {
                Text("ImplicitAnimations")
            }
            
            NavigationView {
                GeometryEffectAnimations()
            }
            .tabItem {
                Text("GeometryEffect")
            }
            
            NavigationView {
                JustCoolAnimations()
            }
            .tabItem {
                Text("Cool ones")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
