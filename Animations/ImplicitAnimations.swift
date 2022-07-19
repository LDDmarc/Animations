//
//  ImplicitAnimations.swift
//  Animations
//
//  Created by Дарья Леонова on 19.07.2022.
//

import SwiftUI

struct ImplicitAnimations: View {
    var body: some View {
        ScrollView {
            VStack {
                ScaleOpacity()
                Polygons()
                ClockView()
            }
            .navigationTitle("Implicit")
        }
    }
}

struct ImplicitAnimations_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ImplicitAnimations()
        }
    }
}

struct ScaleOpacity: View {
    @State private var double = false
    @State private var op = false
    
    var body: some View {
        VStack {
            HStack {
                Text("ScaleOpacity")
                Spacer()
            }.padding(.horizontal)
            
            Image("peach")
                .scaleEffect(double ? 2 : 1)
                .opacity(op ? 0.2 : 1)
                .animation(.easeInOut(duration: 1), value: double)
                .animation(.easeInOut(duration: 1), value: op)
                .onTapGesture {
                    double.toggle()
                    op.toggle()
            }
        }
    }
}

struct PolygonShape: Shape {
    var sides: Int
    private var sidesAsDouble: Double
    var animatableData: Double {
        get { sidesAsDouble }
        set { sidesAsDouble = newValue }
    }
    
    init(sides: Int) {
        self.sides = sides
        self.sidesAsDouble = Double(sides)
    }
    
    func path(in rect: CGRect) -> Path {
        let hypotenuse = Double(min(rect.size.width, rect.size.height)) / 2.0
        let center = CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0)
        
        var path = Path()
        let extra: Int = sidesAsDouble != Double(Int(sidesAsDouble)) ? 1 : 0
        
        for i in 0..<Int(sidesAsDouble) + extra {
            let angle = (Double(i) * (360.0 / sidesAsDouble)) * Double.pi / 180
            let pt = CGPoint(x: center.x + CGFloat(cos(angle) * hypotenuse), y: center.y + CGFloat(sin(angle) * hypotenuse))
            
            if i == 0 {
                path.move(to: pt) // move to first vertex
            } else {
                path.addLine(to: pt) // draw line to next vertex
            }
        }
        
        path.closeSubpath()
        
        return path
    }
}

struct Polygons: View {
    @State private var sides = 3
    private var sidesArray = [2, 3, 4, 7, 30]
    
    var body: some View {
        VStack {
            HStack {
                Text("Polygons")
                Spacer()
            }.padding(.horizontal)
            PolygonShape(sides: sides)
                .stroke(.indigo, lineWidth: 3)
                .animation(.easeInOut(duration: 1.0), value: sides)
                .frame(minWidth: 200, minHeight: 200)
                .padding()
            
            Text("\(Int(sides)) sides").font(.headline)
            
            HStack(spacing: 20) {
                ForEach(sidesArray, id: \.self) { side in
                    Button {
                        sides = side
                    } label: {
                        Text("\(side)")
                            .padding()
                            .background(.green)
                            .cornerRadius(5)
                    }
                }
            }
        }
    }
}

struct ClockTime: Hashable {
    let id = UUID().uuidString
    var hours: Int      // Hour needle should jump by integer numbers
    var minutes: Int    // Minute needle should jump by integer numbers
    var seconds: Double // Second needle should move smoothly
    
    // Initializer with hour, minute and seconds
    init(_ h: Int, _ m: Int, _ s: Double) {
        self.hours = h
        self.minutes = m
        self.seconds = s
    }
    
    // Initializer with total of seconds
    init(_ seconds: Double) {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) - (h * 3600)) / 60
        let s = seconds - Double((h * 3600) + (m * 60))
        
        self.hours = h
        self.minutes = m
        self.seconds = s
    }
    
    // compute number of seconds
    var asSeconds: Double {
        return Double(self.hours * 3600 + self.minutes * 60) + self.seconds
    }
    
    // show as string
    func asString() -> String {
        return String(format: "%2i", self.hours) + ":" + String(format: "%02i", self.minutes) + ":" + String(format: "%02f", self.seconds)
    }
    

}

extension ClockTime: VectorArithmetic {
    static var zero: ClockTime {
        ClockTime(0, 0, 0)
    }
    
    var magnitudeSquared: Double {
        asSeconds * asSeconds
    }
    
    static func -= (lhs: inout ClockTime, rhs: ClockTime) {
        lhs = lhs - rhs
    }
    
    static func - (lhs: ClockTime, rhs: ClockTime) -> ClockTime {
        ClockTime(lhs.asSeconds - rhs.asSeconds)
    }
    
    static func += (lhs: inout ClockTime, rhs: ClockTime) {
        lhs = lhs + rhs
    }
    
    static func + (lhs: ClockTime, rhs: ClockTime) -> ClockTime {
        ClockTime(lhs.asSeconds + rhs.asSeconds)
    }
    
    mutating func scale(by rhs: Double) {
        var s = Double(asSeconds)
        s.scale(by: rhs)
        
        let ct = ClockTime(s)
        self.hours = ct.hours
        self.minutes = ct.minutes
        self.seconds = ct.seconds
    }
}

struct ClockShape: Shape {
    var clockTime: ClockTime
    
    var animatableData: ClockTime {
        get { clockTime }
        set { clockTime = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let radius = min(rect.size.width / 2.0, rect.size.height / 2.0)
        let center = CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0)
        
        let hHypotenuse = Double(radius) * 0.5 // hour needle length
        let mHypotenuse = Double(radius) * 0.7 // minute needle length
        let sHypotenuse = Double(radius) * 0.9 // second needle length
        
        let hAngle: Angle = .degrees(Double(clockTime.hours) / 12 * 360 - 90)
        let mAngle: Angle = .degrees(Double(clockTime.minutes) / 60 * 360 - 90)
        let sAngle: Angle = .degrees(Double(clockTime.seconds) / 60 * 360 - 90)
        
        let hourNeedle = CGPoint(x: center.x + CGFloat(cos(hAngle.radians) * hHypotenuse), y: center.y + CGFloat(sin(hAngle.radians) * hHypotenuse))
        let minuteNeedle = CGPoint(x: center.x + CGFloat(cos(mAngle.radians) * mHypotenuse), y: center.y + CGFloat(sin(mAngle.radians) * mHypotenuse))
        let secondNeedle = CGPoint(x: center.x + CGFloat(cos(sAngle.radians) * sHypotenuse), y: center.y + CGFloat(sin(sAngle.radians) * sHypotenuse))
        
        path.addArc(center: center, radius: radius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)

        path.move(to: center)
        path.addLine(to: hourNeedle)
        path = path.strokedPath(StrokeStyle(lineWidth: 2.0))

        path.move(to: center)
        path.addLine(to: minuteNeedle)
        path = path.strokedPath(StrokeStyle(lineWidth: 2.0))

        path.move(to: center)
        path.addLine(to: secondNeedle)
        path = path.strokedPath(StrokeStyle(lineWidth: 1.0))
        
        return path
    }
}

struct MyButton: View {
    let label: String
    var font: Font = .title
    var textColor: Color = .white
    let action: () -> ()
    
    var body: some View {
        Button(action: {
            self.action()
        }, label: {
            Text(label)
                .font(font)
                .padding(10)
                .frame(width: 70)
                .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.green).shadow(radius: 2))
                .foregroundColor(textColor)
            
        })
    }
}

struct ClockView: View {
    @State private var time: ClockTime = ClockTime(9, 50, 5)
    @State private var duration: Double = 2.0
    
    private var times: [ClockTime] = [
        ClockTime(9, 51, 45),
        ClockTime(9, 51, 15),
        ClockTime(9, 52, 15),
        ClockTime(10, 01, 45)
    ]
    
    var body: some View {
        VStack {
            HStack {
                Text("ClockView")
                Spacer()
            }.padding(.horizontal)
            
            ClockShape(clockTime: time)
                .stroke(Color.blue, lineWidth: 2)
                .padding(20)
                .animation(.easeInOut(duration: duration), value: time)
                .frame(minWidth: 200, minHeight: 200)
            
            
            Text("\(time.asString())")

            HStack(spacing: 20) {
                ForEach(times, id: \.self) { time in
                    MyButton(label: time.asString(), font: .footnote, textColor: .black) {
                        self.duration = 2.0
                        self.time = time
                    }
                }
            }
        }
    }
}
