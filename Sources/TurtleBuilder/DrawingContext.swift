//
//  DrawingContext.swift
//  TurtleBuilder
//
//  Created by Jason Jobe on 12/24/24.
//
import SwiftUI

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
