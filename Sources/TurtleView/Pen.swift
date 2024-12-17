//
//  Pen.swift
//  TurtleBuilder
//
//  Created by Jason Jobe on 12/15/24.
//

import SwiftUI

enum PenOp {
    //    case pen(Color?)
    case pen_up, pen_down
    case closeSubpath
    case move(to: UnitPoint)
    // move(to: UnitPoint, clip: Shape) - stops at intersection of shape
    case face(Angle)
    case turn(Angle)
    case forward(CGFloat)
    case dot(CGFloat)
    case left(face: Angle, step: CGFloat)
    case right(face: Angle, step: CGFloat)
    case loop(Int, [PenOp])
    /*
     // Anchor is the alignment point of the shape/string
     case place(AnyShape, anchor: )
     case print(String, anchor: )
     */
}

//struct _Pen: Shape {
//    var start: CGPoint = .zero
//    var ops: [PenOp]
//    
//    func path(in rect: CGRect) -> Path {
//        var pos: CGPoint = rect.size.point(at: .center)
//        print("center", UnitPoint.center)
//        print(pos, "in", rect)
////        var draw = false
////        var dir: Angle = .degrees(0)
//        return Path { p in
//            p.move(to: rect.midpoint)
//            var f = rect
//            let r = 50.0
//            f.origin.x = pos.x - 25
////            f.midpoint = pos
//            f.size.width = r
////            f.size.height = r
//            p.addPath(Circle().path(in: f))
//        }
//    }
//}

extension CGRect {
    var midpoint: CGPoint {
        get { CGPoint(x: midX, y: minY) }
        set {
                origin = CGPoint(
                    x: newValue.x - width / 2,
                    y: newValue.y - height / 2)
        }
    }
}

struct Nib {
    var pos: CGPoint
    var draw = false
    var dir: Angle = .degrees(0)
}

struct Pen: Shape {
    var start: CGPoint = .zero
    var ops: [PenOp]
    
    func path(in rect: CGRect) -> Path {
        var nib = Nib(pos: start)
        return _path(nib: &nib, in: rect)
    }
    
    func _path(nib: inout Nib, in rect: CGRect) -> Path {
//        var nib.pos: CGPoint = start // rect[start]
//        var nib.draw = false
//        var nib.dir: Angle = .degrees(0)
        var p = Path()
        
        p.move(to: nib.pos)
        
        for op in ops {
            switch op {
            case .pen_up: nib.draw = false
            case .pen_down: nib.draw = true
            case .closeSubpath:
                p.closeSubpath()
                
            case .move(to: let pt):
//                dir = aim(at: pt)
                nib.pos = goto(rect[pt])
                
            case .dot(let r):
                var f = rect
//                f.origin.x = pos.x - r/2
//                f.origin.y = pos.y - r/2
                f.size.width = r
                f.size.height = r
                f.midpoint = nib.pos
                p.addPath(Circle().path(in: f))
                p.move(to: nib.pos)
                
            case .face(let a):
                nib.dir = a
                
            case .forward(let length):
                var x = cos(nib.dir.radians)
                var y = sin(nib.dir.radians)
                if abs(x) == 1.0 {
                    y = 0
                } else if abs(y) == 1.0 {
                    x = 0
                }
                x = x * length
                y = y * length
                let newPoint = CGPoint(x: nib.pos.x + x, y: nib.pos.y +  y)
                nib.pos = goto(newPoint)
//                if isPenDown {
//                    if var lastSequence = lines.last {
//                        lastSequence.append(newPoint)
//                        lines[lines.count - 1] = lastSequence
//                    }
//                }
//                lastPoint = newPoint
            case .turn(let degree):
//                let rad = Turtle.deg2rad(Double(degree))
                nib.dir += degree
                
            case .left(face: let face, step: let step):
                nib.dir = -face
                let pt = point(angle: nib.dir.radians, distance: step)
                nib.pos = goto(pt)

            case .right(face: let face, step: let step):
                nib.dir += face
                var x = cos(nib.dir.radians)
                var y = sin(nib.dir.radians)
                if abs(x) == 1.0 {
                    y = 0
                } else if abs(y) == 1.0 {
                    x = 0
                }
                x = x * step
                y = y * step
                let pt = CGPoint(x: nib.pos.x + x, y: nib.pos.y + y)
//                print("right", draw, pt)
//                let pt = point(angle: dir.radians, distance: step)
                nib.pos = goto(pt)
   
            case .loop(let count, let ops):
                var pt = nib.pos
                for _ in 0..<count {
                    let pen = Pen(ops: ops)
                    p.addPath(pen._path(nib: &nib, in: rect))
                }
            }
//            case .loop(let count, var innerPen):
//                innerPen.start = rect.unitPoint(of: pos)
//                var box = rect
//                for _ in 0..<count {
//                    box.midpoint = pos
//                    let innerPath = innerPen.path(in: box)
//                    p.addPath(innerPath)
//                    pos = innerPath.currentPoint ?? pos
//                }
//            }
        }
        return p
        
        func goto(_ dest: CGPoint) -> CGPoint {
            if nib.draw {
                p.addLine(to: dest)
            } else {
                p.move(to: dest)
            }
            return dest
        }
        
        func point(angle: CGFloat, distance: CGFloat) -> CGPoint {
            let point = nib.pos
            let x = point.x + distance * cos(angle)
            let y = point.y + distance * sin(angle)
//            print(x, y)
            return CGPoint(x: x, y: y)
        }
        
        func aim(at p: UnitPoint) -> Angle {
            let dp = rect[p]
            let dx = nib.pos.x - dp.x
            let dy = nib.pos.y - dp.y
            let ang = atan2(dy, dx)
            return Angle(radians: ang)
        }
    }
}

let innerPen = Pen(ops: [
//    .move(to: .center),
    .pen_down,
    .forward(20),
    .turn(.degrees(120)),
    .forward(20),
//    .move(to: .topTrailing),
//    .move(to: .bottom),
    .closeSubpath,
    .pen_up,
    .turn(.degrees(90)),
    .forward(20)
//    .right(face: .degrees(90), step: 50),
//    .left(face: .degrees(90), step: 50)
])

let star = Pen(ops: [
    .move(to: .trailing),
    .dot(10),
    .pen_down,
    .loop(9, [
        .turn(.degrees(140)),
        .forward(30),
        .turn(.degrees(-100)),
        .forward(30),
    ]),
//    }
        .pen_up,
])

let mainPen = Pen(ops: [
    .move(to: .center),
    .pen_down,
    .dot(10),
    .forward(40),
    .turn(.degrees(45)),
    .forward(40),
    .turn(.degrees(-90)),
    .forward(40),
    .pen_up,
//    .move(to: .center),
//    .loop(8, innerPen),
//    .face(.degrees(0)),
//    loop(9) {
//    .forward(20),
//    .turn(.degrees(90)),
//    .forward(30),
//    .turn(.degrees(-100)),
//    .forward(30),
//    }
        .pen_up,
])

#Preview {
    ZStack {
        star
            .stroke(.green)
            .border(.red)
            .frame(width: 100, height: 100)
    }
    .frame(width: 300, height: 500)
}
