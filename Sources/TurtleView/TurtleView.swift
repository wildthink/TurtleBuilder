import SwiftUI
import TurtleBuilder

public struct TurtleView: View {
	var turtle: Turtle

    public var strokeColor: Color = .green
    public var fillColor: Color = .clear

    public var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            
//            strokeColor.setStroke()
            var path = Path()
            for sequence in turtle.lines {
                if sequence.count < 2 {
                    continue
                }
//                path.lineWidth = 3
                path.move(to: transalte(sequence[0], center: center))
                for point in sequence[1...] {
                    path.addLine(to: transalte(point, center: center))
                }
//                let p1 = path.stroke()
                path.closeSubpath()
            }
            context.stroke(path, with: .color(strokeColor), lineWidth: 4)
            context.fill(path, with: .color(fillColor))
        }
    }
    
//    public override func draw(_ rect: CGRect) {
//        super.draw(rect)
//
//
//	}
}


//@TurtleBuilder
//func builder() -> [TurtleCommand] {
let t1 = Turtle {
    penDown()
    loop(20) {
        loop(180) {
            forward(25)
            right(20)
        }
        right(18)
    }
}

let turtle = Turtle {
        penDown()
        loop(9) {
            left(140)
            forward(30)
            left(-100)
            forward(30)
        }
        penUp()
}

#Preview {
//    TurtleView(turtle: t1, strokeColor: .blue, fillColor: .yellow)
//        .border(.red)
//        .frame(width: 300, height: 500)
    TurtleView(turtle: turtle, strokeColor: .blue, fillColor: .yellow)
        .border(.red)
        .frame(width: 300, height: 500)

}
