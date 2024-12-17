import Foundation

//#if os(macOS)
//import AppKit
//
//public typealias PlatformView = NSView
//public typealias PlatformColor = NSColor
//public typealias PlatformPath = NSBezierPath
//#endif
//
//#if os(iOS)
//import UIKit
//
//public typealias PlatformView = UIView
//public typealias PlatformColor = UIColor
//public typealias PlatformPath = UIBezierPath
//#endif

func transalte(_ position: CGPoint, center: CGPoint) -> CGPoint {
	let x = center.x + CGFloat(position.x)
	let y = center.y + (CGFloat(position.y) * -1)
	let point = CGPoint(x: x, y: y)
	return point
}
