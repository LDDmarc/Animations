//
//  GeometryEffectAnimations.swift
//  Animations
//
//  Created by Дарья Леонова on 19.07.2022.
//

import SwiftUI

struct GeometryEffectAnimations: View {
    var body: some View {
        ScrollView {
            VStack {
                ColoredLabels()
                CardView()
                SimpleCardView()
            }
        }
        .navigationTitle("GeometryEffect")
    }
}

struct GeometryEffectAnimations_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GeometryEffectAnimations()
        }
    }
}

struct SkewedOffset: GeometryEffect {
    enum Direction {
        case left
        case right
    }
    var offset: CGFloat
    var percentage: CGFloat
    let direction: Direction

    private let skewPercentage = 0.2
    private let defaultSkew = 0.5
    private var goingRight: Bool {
        direction == .right
    }
    private var skewScale: CGFloat {
        1 / skewPercentage
    }

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(offset, percentage) }
        set {
            offset = newValue.first
            percentage = newValue.second
        }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        var skew: CGFloat

        if percentage < skewPercentage {
            skew = (percentage * skewScale) * defaultSkew * (goingRight ? -1 : 1)
        } else if percentage > 1 - skewPercentage {
            skew = ((1 - percentage) * skewScale) * defaultSkew * (goingRight ? -1 : 1)
        } else {
            skew = defaultSkew * (goingRight ? -1 : 1)
        }

        return ProjectionTransform(CGAffineTransform(a: 1, b: 0, c: skew, d: 1, tx: offset, ty: 0))
    }
}

struct ColoredLabels: View {
    @State private var isMooved = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Skew labels")
                Spacer()
            }.padding(.horizontal)
            
            LabelView(
                text: "Text Bul Bul",
                offset: isMooved ? 120 : -120,
                pct: isMooved ? 1 : 0,
                backgroundColor: .red
            )
            .animation(.easeInOut(duration: 1), value: isMooved)
            
            LabelView(
                text: "Text Bul Bul",
                offset: isMooved ? 120 : -120,
                pct: isMooved ? 1 : 0,
                backgroundColor: .green
            )
            .animation(.easeInOut(duration: 1).delay(0.1), value: isMooved)
            
            LabelView(
                text: "Text Bul Bul",
                offset: isMooved ? 120 : -120,
                pct: isMooved ? 1 : 0,
                backgroundColor: .blue
            )
            .animation(.easeInOut(duration: 1).delay(0.2), value: isMooved)
            
            LabelView(
                text: "Text Bul Bul",
                offset: isMooved ? 120 : -120,
                pct: isMooved ? 1 : 0,
                backgroundColor: .purple
            )
            .animation(.easeInOut(duration: 1).delay(0.3), value: isMooved)
            
            LabelView(
                text: "Text Bul Bul",
                offset: isMooved ? 120 : -120,
                pct: isMooved ? 1 : 0,
                backgroundColor: .orange
            )
            .animation(.easeInOut(duration: 1).delay(0.4), value: isMooved)
        }
        .onTapGesture {
            isMooved.toggle()
        }
    }
}

struct LabelView: View {
    let text: String
    var offset: CGFloat
    var pct: CGFloat
    let backgroundColor: Color

    var body: some View {
        Text(text)
            .font(.headline)
            .padding(5)
            .background(RoundedRectangle(cornerRadius: 5).foregroundColor(backgroundColor))
            .foregroundColor(Color.black)
            .modifier(SkewedOffset(
                offset: offset,
                percentage: pct,
                direction: offset > 0 ? .right : .left
            ))
    }
}

struct FlippEffect: GeometryEffect {
    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }
    
    @Binding var flipped: Bool
    var angle: Double
    let axis: (x: CGFloat, y: CGFloat)
        
    func effectValue(size: CGSize) -> ProjectionTransform {
        // We schedule the change to be done after the view has finished drawing,
        // otherwise, we would receive a runtime error, indicating we are changing
        // the state while the view is being drawn.
        DispatchQueue.main.async {
            self.flipped = self.angle >= 90 && self.angle < 270
        }
        
        let a = CGFloat(Angle(degrees: angle).radians)
        
        var transform3d = CATransform3DIdentity;
        transform3d.m34 = -1/max(size.width, size.height)
        
        transform3d = CATransform3DRotate(transform3d, a, axis.x, axis.y, 0)
        transform3d = CATransform3DTranslate(transform3d, -size.width/2.0, -size.height/2.0, 0)
        
        let affineTransform = ProjectionTransform(CGAffineTransform(
            translationX: size.width/2.0,
            y: size.height / 2.0
        ))
        
        return ProjectionTransform(transform3d).concatenating(affineTransform)
    }
}

struct CardView: View {
    @State private var flipped = false
    @State private var animate3d = false
    @State private var rotate = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Flip card")
                Spacer()
            }.padding(.horizontal)
            
            Image(flipped ? "bird" : "card")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 250, height: 360)
                .cornerRadius(10)
                .modifier(FlippEffect(
                    flipped: $flipped,
                    angle: animate3d ? 360 : 0,
                    axis: (x: 0, y: 1)
                ))
        }
        .onTapGesture {
            withAnimation(Animation.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                self.animate3d = true
            }
        }
    }
}

struct SimpleCardView: View {
    @State private var flipped = false
    
    var body: some View {
        let degrees = flipped ? 180.0 : 0.0
        VStack {
            HStack {
                Text("Flip card rotation3DEffect")
                Spacer()
            }.padding(.horizontal)
            
            ZStack {
                bird
                    .rotation3DEffect(Angle(degrees: degrees), axis: (x: 0, y: 1, z: 0))
                    .opacity(degrees < 90 ? 0.0 : 1.0)
                card
                    .rotation3DEffect(Angle(degrees: degrees - 180.0), axis: (x: 0, y: 1, z: 0))
                    .opacity(degrees < 90 ? 1.0 : 0.0)
            }
        }
        .onTapGesture {
            withAnimation(Animation.linear(duration: 4.0)) {
                flipped.toggle()
            }
        }
    }
    
    var bird: some View {
        Image("bird")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 250, height: 360)
            .cornerRadius(10)
    }
    var card: some View {
        Image("card")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 250, height: 360)
            .cornerRadius(10)
    }
}
