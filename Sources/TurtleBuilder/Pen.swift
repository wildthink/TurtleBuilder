//
//  Pen.swift
//  TurtleBuilder
//
//  Created by Jason Jobe on 12/23/24.
//
import SwiftUI

class Pen {
    var ctx: DrawingContext!
    var pos: CGPoint
    var box: CGRect
    var upos: UnitPoint { box[pos] }
    
    init(ctx: DrawingContext! = nil,
        pos: CGPoint = .zero,
        box: CGRect) {
        self.ctx = ctx
        self.pos = pos
        self.box = box
    }

    init(ctx: DrawingContext,
        pos: CGPoint = .zero,
        box: CGSize) {
        self.ctx = ctx
        self.pos = pos
        self.box = CGRect(origin: .zero, size: box)
    }
    
    init() {
        pos = .zero
        box = .zero
    }
    
    var font: Font? {
        get { _font ?? ctx.environment.font }
        set { _font = newValue }
    }
    var _font: Font?
    
    var foregroundStyle: any ShapeStyle = ForegroundStyle()
    var fillStyle: any ShapeStyle = FillShapeStyle()

    @discardableResult
    func move(to up: UnitPoint) -> Self {
        pos = CGPoint(x: box.width * up.x, y: box.height * up.y)
        return self
    }
    
    func place(_ str: String, _ anchor: UnitPoint, at pin: UnitPoint) {
        let resolved = ctx.resolve(Text(str).font(font))
        place(resolved, anchor, at: pin)
    }
       
    func place(_ resolved: GraphicsContext.ResolvedText,
               _ anchor: UnitPoint,
               at pin: UnitPoint
    ) {
        ctx.draw(resolved, at: box.point(at: pin), anchor: anchor)
    }

    @discardableResult
    func line(to e: UnitPoint, width: CGFloat = 2) -> Self {
        let path = Path { p in
            p.move(to: pos)
            p.addLine(to: box[e])
        }
        pos = path.currentPoint ?? box[e]
        ctx.stroke(path, with: foregroundStyle, lineWidth: width)
        return self
    }

    @discardableResult
    func place<S: Shape>(
        _ shape: S,
        anchor: UnitPoint = .center,
        in sz: CGSize,
        at pt: UnitPoint? = nil,
        rotation: Angle = .zero
    ) -> Self {
        let pt = pt ?? upos
        var pbox = CGRect(origin: .zero, size: sz)
        pbox[anchor] = self.box[pt]
        pbox.size = sz

        var xform = CGAffineTransform.identity
        
        if rotation != .zero {
            let apt = pbox[anchor]
            let (x, y) = (apt.x, apt.y)
            xform = CGAffineTransform(translationX: x, y: y)
                .rotated(by: rotation.radians)
                .translatedBy(x: -x, y: -y)
        }
        
        let path = shape.path(in: pbox)
            .applying(xform)
        
        ctx.fill(path, with: fillStyle) // .color(.red.opacity(0.2)))
        return self
    }

    func fill<S: Shape>(_ shape: S, style: any ShapeStyle) {
        let path = shape.path(in: box)
        ctx.fill(path, with: style)
    }

}


/*
 goto: .leading
 face: .east
 line: to: .trailing
 
 line from: .leading, to: .trailing
 place: Circle()
 .scale(0.5(of: height))
 .scale(height * 50%))
    .fill(.red)
   at: (x: .center, y: 25%)

 goto: .leading
 face: .east
 step: (1/4)%
 place: Circle().scale(0.5(of: height)).fill(.red)
 right: 45°
 */

//extension GraphicsContext {
//    func draw(_ s: String, font: Font, at p: CGPoint, anchor ap: UnitPoint) {
//        let resolved = self.resolve(Text(s).font(font))
//        draw(resolved, at: p, anchor: ap)
//    }
//}

extension Pen {
    func line(facing: Angle, length: CGFloat) {
        let p = upos.point(at: facing, length: length)
        line(to: p)
    }
}


struct PenDemo: View {
    var body: some View {
        Canvas { ctx, size in
            let pen = Pen(ctx: ctx, box: size)

            pen
                .move(to: .center)
                .line(to: .trailing)
                .place("Tops", .bottom, at: .center)
                        
            pen.place("Bottom", .center, at: .center - 0.2)
            pen.place(.rect(cornerRadius: 8), anchor: .center, in: 50..50, at: .center, rotation: .degrees(45))
            pen.fillStyle = .red.opacity(0.7)
            pen.place(.circle, in: 20..20, at: .center)
            
            pen.move(to: .center)
            pen.line(facing: .south, length: 0.25)
            pen.line(facing: .west, length: 0.2)
            pen.line(facing: .north, length: 0.2)
        }
        .foregroundStyle(.white)
        .font(.headline)
    }
}

#Preview {
    PenDemo()
        .foregroundStyle(.white)
        .font(.headline)
        .frame(width: 200, height: 200)
}
