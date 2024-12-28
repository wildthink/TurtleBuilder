//
//  StripedRectangle.swift
//  TurtleBuilder
//
//  Created by Jason Jobe on 12/26/24.
//

import SwiftUI

struct StripedRectangle: Shape {
    var axis: Axis = .horizontal
    var gap: CGFloat = 8
    
    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        let totalLength: CGFloat
        let step: CGFloat
        let box = Rectangle()
        
        switch axis {
        case .horizontal:
            totalLength = rect.width
            step = gap
            var x: CGFloat = 0
            while x < totalLength {
                let nextX = min(x + step, totalLength)
                path.move(to: CGPoint(x: x, y: rect.midY))
                path.addPath(box.path(in: CGRect(
                    origin: CGPoint(x: nextX, y: rect.midY),
                    size: CGSize(width: step, height: rect.height))
                ))
                x += 2 * step
            }
        case .vertical:
            totalLength = rect.height
            step = gap
            var y: CGFloat = 0
            while y < totalLength {
                let nextY = min(y + step, totalLength)
                path.move(to: CGPoint(x: rect.midX, y: y))
                path.addPath(box.path(in: CGRect(
                    origin: CGPoint(x: rect.midX, y: nextY),
                    size: CGSize(width: rect.width, height: step))
                ))
                y += 2 * step
            }
        }
        return path
    }
}
