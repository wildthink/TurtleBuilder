//
//  Pen.swift
//  TurtleBuilder
//
//  Created by Jason Jobe on 12/23/24.
//
import SwiftUI

class Pen {
    var ctx: GraphicsContext
    var foreground: GraphicsContext.Shading
    var font: Font
    var pos: CGPoint
    var box: CGRect
    var size: CGSize { box.size }
    
    init(ctx: GraphicsContext,
         foreground: GraphicsContext.Shading = .foreground,
         font: Font,
         pos: CGPoint = .zero,
         box: CGRect) {
        self.ctx = ctx
        self.foreground = foreground
        self.font = font
        self.pos = pos
        self.box = box
    }
    
    @discardableResult
    func move(to up: UnitPoint) -> Self {
        pos = CGPoint(x: box.width * up.x, y: box.height * up.y)
        return self
    }
    
//    func draw(_ s: String) {
    @discardableResult
    func place(_ s: String, _ anchor: UnitPoint, at up: UnitPoint) -> Self {
        let resolved = ctx.resolve(Text(s).font(font))
        return place(resolved, anchor, at: up)
    }
       
    func place(_ resolved: GraphicsContext.ResolvedText,
               _ anchor: UnitPoint,
               at pt: UnitPoint
    ) -> Self {
        // flips the y-origin for text
//        var pt = up
//        pt.y = -up.y
        ctx.draw(resolved, at: box.point(at: anchor), anchor: pt)
        return self
    }

    @discardableResult
    func line(to e: UnitPoint, width: CGFloat = 2) -> Self {
        let path = Path { p in
            p.move(to: pos)
            p.addLine(to: box[e])
        }
        pos = path.currentPoint ?? box[e]
//            .scale(2)
//        path.move(to: size.point(at: s))
//        path.addLine(to: size.point(at: e))
//        path.stroke(lineWidth: width)
        ctx.stroke(path, with: .color(.blue), lineWidth: width)
        return self
    }

    @discardableResult
    func place<S: Shape>(
        _ shape: S,
        anchor: UnitPoint = .center,
        in sz: CGSize,
        at pt: UnitPoint,
        rotation: Angle = .zero
    ) -> Self {
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
        
        ctx.fill(path, with: .color(.red.opacity(0.2)))
        return self
    }

    @discardableResult
    func fill<S: Shape>(_ shape: S, color: Color) -> Self {
        let path = shape.path(in: box)
        ctx.fill(path, with: .color(color))
        return self
    }

}

extension CGAffineTransform {
    
    init(rotationAngle: CGFloat, anchor: CGPoint) {
        self.init(
            a: cos(rotationAngle),
            b: sin(rotationAngle),
            c: -sin(rotationAngle),
            d: cos(rotationAngle),
            tx: anchor.x - anchor.x * cos(rotationAngle) + anchor.y * sin(rotationAngle),
            ty: anchor.y - anchor.x * sin(rotationAngle) - anchor.y * cos(rotationAngle)
        )
    }

    func rotated(by angle: CGFloat, anchor: CGPoint) -> Self {
        let transform = Self(rotationAngle: angle, anchor: anchor)
        return self.concatenating(transform)
    }

}

//extension CGRect {
//    init(_ size: CGSize) {
//        origin = .zero
//        self.size = size
//    }
//}

//extension Pen {
//    convenience init(ctx: GraphicsContext, font: Font, pos: CGPoint, size: CGSize) {
//        self.init(ctx: ctx, font: , pos: <#T##CGPoint#>, box: <#T##CGRect#>)
//        self.ctx = ctx
//        self.font = font
//        self.pos = pos
//        self.box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//    }
//}

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

extension GraphicsContext {
    func draw(_ s: String, font: Font, at p: CGPoint, anchor ap: UnitPoint) {
        let resolved = self.resolve(Text(s).font(font))
        draw(resolved, at: p, anchor: ap)
    }
}

infix operator ..
func ..(wd: CGFloat, ht: CGFloat) -> CGSize {
    CGSize(width: wd, height: ht)
}

struct PenDemo: View {
    var body: some View {
        Canvas { ctx, size in
            let cframe = CGRect(origin: .zero, size: size)
            let pen = Pen(ctx: ctx, font: .caption, pos: .zero, box: cframe)
            pen.move(to: .center)
            pen.line(to: .trailing)
            pen.place("Hello", .center, at: .bottomLeading)
            pen.place(.rect(cornerRadius: 8), anchor: .center, in: 50..50, at: .center, rotation: .degrees(45))
            pen.place(.circle, in: 20..20, at: .center)
        }
    }
}

#Preview {
    PenDemo()
        .frame(width: 200, height: 200)
}
