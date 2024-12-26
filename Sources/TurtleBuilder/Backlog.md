#  Backlog


protocol Turtle {
    var pen: Pen { get set }
    func render(in rect: CGRect)
}

@propertyWrapper
struct Painter: DynamicProperty {
    var wrappedValue: Pen
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
        at pt: UnitPoint,
        rotation: Angle = .zero
    ) {
        pen.place(shape, anchor: anchor, in: sz, at: pt, rotation: rotation)
    }
}

protocol DrawingContext {
    var environment: EnvironmentValues { get }
    func fill(_ path: Path, with style: any ShapeStyle)
    func stroke(_ path: Path, with: any ShapeStyle, lineWidth: CGFloat)
    
    func resolve(_ text: String) -> GraphicsContext.ResolvedText
    func resolve(_ text: Text) -> GraphicsContext.ResolvedText
    func draw(_: GraphicsContext.ResolvedText, at: CGPoint, anchor: UnitPoint)
}


extension GraphicsContext: DrawingContext {
    var font: Font? { nil }
    
    func place(_ s: String, _ anchor: UnitPoint, at pin: CGPoint) {
        let resolved = resolve(Text(s).font(font))
        draw(resolved, at: pin, anchor: anchor)
    }

    func place(_ resolved: GraphicsContext.ResolvedText,
               _ anchor: UnitPoint,
               at pin: CGPoint
    ) {
        draw(resolved, at: pin, anchor: anchor)
    }

    func resolve(_ text: String) -> ResolvedText {
        resolve(Text(text))
    }
    
    func stroke(
        _ path: Path,
        with style: any ShapeStyle,
        lineWidth: CGFloat = 1
    ) {
        self.stroke(
            path,
            with: .style(AnyShapeStyle(style)),
            lineWidth: lineWidth)
    }

    func fill(_ path: Path, with style: any ShapeStyle) {
        self.fill(path, with: .style(AnyShapeStyle(style)))
    }
}
