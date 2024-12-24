//
//  Turtle.swift
//  TurtleBuilder
//
//  Created by Jason Jobe on 12/24/24.
//
import SwiftUI

protocol Turtle {
    var pen: Pen { get set }
    func render(in rect: CGRect)
}

extension Turtle {
    
    func move(to pt: UnitPoint) {
        pen.move(to: pt)
    }
    
    func line(to e: UnitPoint, width: CGFloat = 1) {
        pen.line(to: e, width: width)
    }
    
    func fill<S: Shape>(_ shape: S, style: any ShapeStyle) {
        pen.fill(shape, style: style)
    }
    
    // MARK: String/Text
    typealias GCText = GraphicsContext.ResolvedText
    
    func place(_ str: String, _ anchor: UnitPoint, at pin: UnitPoint) {
        pen.place(str, anchor, at: pin)
    }
    
    func place(_ resolved: GCText, _ anchor: UnitPoint, at pin: UnitPoint) {
        pen.place(resolved, anchor, at: pin)
    }
    
    // MARK: Shapes
    func place<S: Shape>(
        _ shape: S,
        anchor: UnitPoint = .center,
        in sz: CGSize,
        at pt: UnitPoint? = nil,
        rotation: Angle = .zero
    ) {
        pen.place(shape, anchor: anchor, in: sz, at: pt, rotation: rotation)
    }
}

struct TurtleView: View {
    var turtle: Turtle
        
    var body: some View {
        Canvas { ctx, size in
            var t = turtle
            t.pen = Pen(ctx: ctx, box: size)
            t.render(in: CGRect(origin: .zero, size: size))
        }
    }
}

struct DemoTurtle: Turtle {
    var pen: Pen = Pen()
    
    func render(in rect: CGRect) {
        move(to: .center)
        line(to: .trailing)
        place("Tops", .bottom, at: .center)
        
        var ap: UnitPoint = .center
        ap += -0.2
        
        place("Bottom", .center, at: ap)
        place(.rect(cornerRadius: 8), anchor: .center, in: 50..50, at: .center, rotation: .degrees(45))
        place(.circle, in: 20..20, at: .center)
        
        move(to: .center)
        pen.foregroundStyle = .red
        line(to: .angle(.degrees(-20)))
        pen.fillStyle = .cyan
        move(to: .center)
        place(.circle, in: 20..20)
        //        line(to: .angle(.degrees(180)))
        pen.line(facing: .west + .degrees(0), length: 0.25)
        //        line(to: .angle(.degrees(-20)))
    }
}

#Preview {
    TurtleView(turtle: DemoTurtle())
        .foregroundStyle(.white)
        .font(.headline)
        .background(.orange.opacity(0.8))
        .frame(width: 200, height: 200)
}
