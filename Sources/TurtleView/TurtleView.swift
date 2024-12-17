import SwiftUI
import TurtleBuilder

public struct TurtleView: View {
    @State var percentage: CGFloat = 1.0
    
	var turtle: Turtle

    public var strokeColor: Color = .green
    public var fillColor: Color = .clear

    public var body: some View {
        VStack {
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
                    //                path.move(to: sequence[0])
                    for point in sequence[1...] {
                        //                    path.addLine(to: point)
                        path.addLine(to: transalte(point, center: center))
                    }
                    //                let p1 = path.stroke()
                }
                if turtle.lines[0][0] == turtle.lines.last?[0] {
                    path.closeSubpath()
                    print(turtle.lines[0][0], turtle.lines.last![0])
                }
                path = path.trimmedPath(from: 0, to: percentage)
                context.stroke(path, with: .color(strokeColor), lineWidth: 4)
                context.fill(path, with: .color(fillColor))
            }
            Slider(value: $percentage)
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

    turtle
        .stroke(.green)
        .fill(.orange)
        .border(.red)
        .frame(width: 50, height: 50)
}

#Preview {
    AnimatePath(turtle: Rectangle())
        .frame(width: 300, height: 500)
}

struct AnimatePath: View {
    var turtle: any Shape
    
    @State private var percentage: CGFloat = .zero
    @State private var flag = false
    @State var size: CGSize = .zero
    
    var body: some View {
        ZStack(alignment: .center) {
            let path = turtle.path(in: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
            Color.clear
            path
                .stroke(.green)
                .fill(.orange)
                .border(.red)
                .frame(width: 50, height: 50)
//                .frame(width: size.width, height: size.height)
            mark(path: path)
        }
        .onGeometryChange(for: CGSize.self, of: \.size) {
            size = $0
            print("size", size)
        }
    }
    
    func mark(path: Path, sz: CGFloat = 10) -> some View {
        Image(systemName: "circle")
            .resizable()
            .foregroundColor(Color.red)
            .frame(width: sz*2, height: sz*2)
//            .offset(x: -sz, y: -sz)
            .modifier(FollowEffect(pct: self.flag ? 1 : 0, path: path, rotate: false))
            .onAppear {
                withAnimation(Animation.linear(duration: 20.0).repeatForever(autoreverses: false)) {
                    self.flag.toggle()
                }
            }
    }
    
    var _body: some View {

         ZStack {
             GeometryReader {
                 let path = turtle.path(in: $0.frame(in: .global))
                 
                 path
                     .trim(from: 0, to: percentage) // << breaks path by parts, animatable
                     .stroke(Color.black, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                 
                 Image(systemName: "airplane")
                     .resizable()
                     .foregroundColor(Color.red)
                     .frame(width: 50, height: 50).offset(x: -25, y: -25)
                     .modifier(FollowEffect(pct: self.flag ? 1 : 0, path: path, rotate: true))
                     .onAppear {
                         withAnimation(Animation.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                             self.flag.toggle()
                         }
                     }
             }
            .animation(.easeOut(duration: 2.0), value: percentage) // << animate
            .onAppear {
                self.percentage = 1.0 // << activates animation for 0 to the end
            }

        }
    }
}
