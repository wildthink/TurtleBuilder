//
//  Graphics.swift
//  TurtleBuilder
//
//  Created by Jason Jobe on 12/15/24.
//

/*
 https://github.com/EmilioPelaez/CGMath
 https://github.com/mattt/Euler
 */

import SwiftUI
import CoreGraphics

// MARK: CGVector
extension CGVector {
    
}

public struct UnitVector {
    var dx: CGFloat
    var dy: CGFloat
}

// MARK: CGPoint - CGSize Cross reference
extension CGPoint {
    var width: CGFloat  { x }
    var height: CGFloat { y }
}

extension CGSize {
    var x: CGFloat { width }
    var y: CGFloat { height }
}


// MARK: Angle Extensions
public extension Angle {
    static let north: Angle = .degrees(-90)
    static let south: Angle = .degrees(90)
    static let west: Angle  = .degrees(180)
    static let east: Angle  = .degrees(0)
}

// MARK: UnitPoint Extensions
public extension UnitPoint {
    
    static func polar(_ angle: Angle, length: CGFloat) -> UnitPoint {
        UnitPoint(x: cos(angle.radians) * length, y: sin(angle.radians) * length)
    }
    
    func point(at angle: Angle, length: CGFloat) -> UnitPoint {
        UnitPoint(x: self.x + cos(angle.radians) * length, y: self.y + sin(angle.radians) * length)
    }
    
    static func angle(_ angle:Angle) -> UnitPoint {
        UnitPoint(angle)
    }
    
    /// - returns: The point on the perimeter of the unit square that is at angle `angle` relative to the center of the unit square.
    init(_ angle: Angle) {
        // Inspired by https://math.stackexchange.com/a/4041510/399217
        // Also see https://www.desmos.com/calculator/k13553cbgk
        
        let s = sin(angle.radians)
        let c = cos(angle.radians)
        self.init(
            x: (c / s).clamped(to: -1...1) * copysign(1, s) * 0.5 + 0.5,
            y: (s / c).clamped(to: -1...1) * copysign(1, c) * 0.5 + 0.5
        )
    }
}

public extension Comparable {
    /// - returns: The nearest value to `self` that is in `range`.
    func clamped(to range: ClosedRange<Self>) -> Self {
        return max(range.lowerBound, min(self, range.upperBound))
    }
}

infix operator ..
public func ..(wd: CGFloat, ht: CGFloat) -> CGSize {
    CGSize(width: wd, height: ht)
}

public extension CGSize {
    
    func unitPoint(of point: CGPoint) -> UnitPoint {
        let unitX = point.x / width
        let unitY = point.y / height
        
        return UnitPoint(x: unitX, y: unitY)
    }
    
    func point(at unitPoint: UnitPoint) -> CGPoint {
        let x = unitPoint.x * width
        let y = unitPoint.y * height
        
        return CGPoint(x: x, y: y)
    }
    
    subscript(_ p: UnitPoint) -> CGPoint {
        get { point(at: p) }
    }
}

public extension CGRect {

    func unitPoint(of point: CGPoint) -> UnitPoint {
        let unitX = (point.x - origin.x) / width
        let unitY = (point.y - origin.y) / height
        return UnitPoint(x: unitX, y: unitY)
    }
        
    func point(at unitPoint: UnitPoint) -> CGPoint {
        let x = origin.x + unitPoint.x * width
        let y = origin.y + unitPoint.y * height
        
        return CGPoint(x: x, y: y)
    }
    
    subscript(_ p: CGPoint) -> UnitPoint {
        unitPoint(of: p)
    }
    
    subscript(_ p: UnitPoint) -> CGPoint {
        get {
            point(at: p)
        }
        set {
            let newX = origin.x + newValue.x - p.x * width
            let newY = origin.y + newValue.y - p.y * height
            self = CGRect(
                origin: CGPoint(x: newX, y: newY),
                size: size
            )
        }
    }
}
/**
 // Usage without these operators :
 var preferredContentSize = myFlowLayout.itemSize
 preferredContentSize.width *= 1.5
 preferredContentSize.height *= 1.5
 myOtherViewController.preferredContentSize = preferredContentSize
 
 
 // Usage with these operators :
 myOtherViewController.preferredContentSize = myFlowLayout.itemSize * 1.5
 
 Et voilà!
 */


public func += ( rect: inout CGRect, size: CGSize) {
    rect.size += size
}
public func -= (rect: inout CGRect, size: CGSize) {
    rect.size -= size
}
public func *= (rect: inout CGRect, size: CGSize) {
    rect.size *= size
}
public func /= (rect: inout CGRect, size: CGSize) {
    rect.size /= size
}
public func += (rect: inout CGRect, origin: CGPoint) {
    rect.origin += origin
}
public func -= (rect: inout CGRect, origin: CGPoint) {
    rect.origin -= origin
}
public func *= (rect: inout CGRect, origin: CGPoint) {
    rect.origin *= origin
}
public func /= (rect: inout CGRect, origin: CGPoint) {
    rect.origin /= origin
}


/** CGSize+OperatorsAdditions */
public func += (size: inout CGSize, right: CGFloat) {
    size.width += right
    size.height += right
}
public func -= (size: inout CGSize, right: CGFloat) {
    size.width -= right
    size.height -= right
}
public func *= (size: inout CGSize, right: CGFloat) {
    size.width *= right
    size.height *= right
}
public func /= (size: inout CGSize, right: CGFloat) {
    size.width /= right
    size.height /= right
}

public func += (left: inout CGSize, right: CGSize) {
    left.width += right.width
    left.height += right.height
}
public func -= (left: inout CGSize, right: CGSize) {
    left.width -= right.width
    left.height -= right.height
}
public func *= (left: inout CGSize, right: CGSize) {
    left.width *= right.width
    left.height *= right.height
}
public func /= (left: inout CGSize, right: CGSize) {
    left.width /= right.width
    left.height /= right.height
}

public func + (size: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: size.width + right, height: size.height + right)
}
public func - (size: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: size.width - right, height: size.height - right)
}
public func * (size: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: size.width * right, height: size.height * right)
}
public func / (size: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: size.width / right, height: size.height / right)
}

public func + (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width + right.width, height: left.height + right.height)
}
public func - (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width - right.width, height: left.height - right.height)
}
public func * (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width * right.width, height: left.height * right.height)
}
public func / (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width / right.width, height: left.height / right.height)
}


/**
    UnitPoint Convenience Operators
 */
public extension UnitPoint {
    static func += ( point: inout Self, right: CGFloat) {
        point.x += right
        point.y += right
    }
    static func -= ( point: inout Self, right: CGFloat) {
        point.x -= right
        point.y -= right
    }
    static func *= ( point: inout Self, right: CGFloat) {
        point.x *= right
        point.y *= right
    }
    static func /= ( point: inout Self, right: CGFloat) {
        point.x /= right
        point.y /= right
    }
    
    static func + (point: Self, right: CGFloat) -> Self {
        .init(x: point.x + right, y: point.y + right)
    }
    static func - (point: Self, right: CGFloat) -> Self {
        .init(x: point.x - right, y: point.y - right)
    }
    static func * (point: Self, right: CGFloat) -> Self {
        .init(x: point.x * right, y: point.y * right)
    }
    static func / (point: Self, right: CGFloat) -> Self {
        .init(x: point.x / right, y: point.y / right)
    }
}

/** CGPoint+OperatorsAdditions */
public extension CGPoint {
    static func += ( point: inout Self, right: CGFloat) {
        point.x += right
        point.y += right
    }
    static func -= ( point: inout Self, right: CGFloat) {
        point.x -= right
        point.y -= right
    }
    static func *= ( point: inout Self, right: CGFloat) {
        point.x *= right
        point.y *= right
    }
    static func /= ( point: inout Self, right: CGFloat) {
        point.x /= right
        point.y /= right
    }
    
    static func + (point: Self, right: CGFloat) -> Self {
        .init(x: point.x + right, y: point.y + right)
    }
    static func - (point: Self, right: CGFloat) -> Self {
        .init(x: point.x - right, y: point.y - right)
    }
    static func * (point: Self, right: CGFloat) -> Self {
        .init(x: point.x * right, y: point.y * right)
    }
    static func / (point: Self, right: CGFloat) -> Self {
        .init(x: point.x / right, y: point.y / right)
    }

}

public func += (left: inout CGPoint, right: CGPoint) {
    left.x += right.x
    left.y += right.y
}
public func -= (left: inout CGPoint, right: CGPoint) {
    left.x -= right.x
    left.y -= right.y
}
public func *= (left: inout CGPoint, right: CGPoint) {
    left.x *= right.x
    left.y *= right.y
}
public func /= (left: inout CGPoint, right: CGPoint) {
    left.x /= right.x
    left.y /= right.y
}

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}
public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}
public func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}
public func / (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

