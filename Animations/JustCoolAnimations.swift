//
//  JustCoolAnimations.swift
//  Animations
//
//  Created by Дарья Леонова on 23.07.2022.
//

import SwiftUI

struct JustCoolAnimations: View {
    var body: some View {
        ScrollView {
            VStack {
                FlowerBlend()
            }
            .navigationTitle("JustCoolAnimations")
        }
    }
}

struct JustCoolAnimations_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            JustCoolAnimations()
        }
    }
}


struct FlowerBlend: View {
    @State private var angle = 0.0
    @State private var scale: CGFloat = 0.2
    
    var body: some View {
        VStack {
            HStack {
                Text("FlowerBlend")
                Spacer()
            }.padding(.horizontal)
            
            ZStack(alignment: .center) {
                ForEach(0..<6) { item in
                    Circle()
                        .frame(width: 100, height: 100, alignment: .center)
                        .foregroundColor(Color(uiColor: .systemTeal))
                        .offset(y: -50)
                        .rotationEffect(.degrees(Double(item) * angle))
                        .scaleEffect(scale)
                        .blendMode(.difference)
                        .animation(
                            .easeInOut(duration: 4)
                            .delay(0.75)
                            .repeatForever(autoreverses: true),
                            value: scale
                        )
                        .onAppear {
                            angle = 60.0
                            scale = 1
                        }
                }
            }
        }
    }
}
