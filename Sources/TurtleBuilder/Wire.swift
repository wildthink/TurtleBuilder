//
//  Wire.swift
//  TurtleBuilder
//
//  Created by Jason Jobe on 12/26/24.
//
import SwiftUI

struct Line: Shape {
    var head: CGPoint
    var tail: CGPoint

    var animatableData: AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData> {
        get { return AnimatablePair(head.animatableData, tail.animatableData) }
        set {
            head.animatableData = newValue.first
            tail.animatableData = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        return Path { p in
            p.move(to: head)
            p.addLine(to: tail)
        }
    }
}

struct Wire: Shape {
    enum Style { case line, angular, scurve }
    var head: CGPoint? = nil
    var tail: CGPoint? = nil
    //    var arrow: Arrow?
    var style: Style = .angular
    
//    var animatableData: AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData> {
//        get { return AnimatablePair(head.animatableData, tail.animatableData) }
//        set {
//            head.animatableData = newValue.first
//            tail.animatableData = newValue.second
//        }
//    }
    
    func path(in rect: CGRect) -> Path {
        let head: CGPoint = head ?? rect[.bottomLeading]
        let tail: CGPoint = tail ?? rect[.topTrailing]

        return switch style {
            case .line:
                // Straight line
            Path { path in
                path.move(to: head)
                path.addLine(to: tail)
            }
            case .angular:
            Path { path in
                // 2 90° turns
                let midX = (head.x + tail.x) / 2
                path.move(to: head)
                path.addLine(to: CGPoint(x: midX, y: head.y))
                path.addLine(to: CGPoint(x: midX, y: tail.y))
                path.addLine(to: tail)
            }
            
            case .scurve:
            Path { p in
                /*
                 https://groups.google.com/g/jointjs/c/QSXZsAuSwXY?pli=1
                 P1 : source(x,y).
                 P2 : x= (P4.x – P1.x) / 2, y=p1.y
                 P3:  x= (P4.x – P1.x) / 2, y=P4.y
                 P4 : target(x,y)
                 */
                let p1 = rect[.bottomLeading]
                let p4 = rect[.topTrailing]
                let p2 = CGPoint(x: (p4.x - p1.x)/2, y: p1.y)
                let p3 = CGPoint(x: (p4.x - p1.x)/2, y: p4.y)
                p.move(to: p1)
                p.addQuadCurve(to: rect[.center], control: p2)
                p.addQuadCurve(to: p4, control: p3)
            }
        }
    }
}

extension Wire {
    
    init(in up: CGRect, style: Wire.Style) {
       self = Wire(head: up[.bottomLeading], tail: up[.topTrailing], style: style)
    }

    init(down: CGRect, style: Wire.Style) {
       self = Wire(head: down[.topLeading], tail: down[.bottomTrailing], style: style)
    }
    
//    static let up: Wire = Wire()
//    static let down: Wire = Wire(head: .topLeading, tail: .bottomTrailing)
}

public extension Path {
    /*
     https://groups.google.com/g/jointjs/c/QSXZsAuSwXY?pli=1
     P1 : source(x,y).
     P2 : x= (P4.x – P1.x) / 2, y=p1.y
     P3:  x= (P4.x – P1.x) / 2, y=P4.y
     P4 : target(x,y)
     */
    static func scurve(head: CGPoint, tail: CGPoint) -> Path {
        Path { p in
            let midpoint = CGPoint(
                x: (head.x - tail.x)/2,
                y: (head.y - tail.y)/2)
            let p2 = CGPoint(x: (tail.x - head.x)/2, y: head.y)
            let p3 = CGPoint(x: (tail.x - head.x)/2, y: tail.y)
            p.move(to: head)
            p.addQuadCurve(to: midpoint, control: p2)
            p.addQuadCurve(to: tail, control: p3)
        }
    }
}

struct WireView: View {
    let style: Wire.Style = .scurve
    let box = CGRect(origin: .zero, size: CGSize(width: 50, height: 80))
    
    var body: some View {
        HStack {
            Group {
                Wire(style: .line)
                    .stroke()
                Wire(style: .angular)
                    .stroke()
                Wire(down: box, style: .angular)
                    .stroke()
                Wire(style: .scurve)
                    .stroke()
            }
            .foregroundStyle(.blue)
            .frame(width: 50, height: 80)
            .padding(8)
            .border(.green)
        }
        .padding()
        .border(.red)
    }
}

#Preview {
    WireView()
        .frame(width: 300, height: 300)
}

// MARK: PatchBoard

typealias PatchNodeID = Int64

struct Patch: Identifiable {
    var id: Int64  { head }
    let head: PatchNodeID
    let tail: PatchNodeID?
    
    init(id head: PatchNodeID, tail: PatchNodeID? = nil) {
//        self.id = id
        self.head = head
        self.tail = tail
    }
}

struct Connections {
    var frames: [PatchNodeID: Anchor<CGRect>] = [:]
    var connections: [Patch] = []

    mutating func merge(_ other: Connections) {
        frames.merge(other.frames, uniquingKeysWith: { $1 })
        connections.append(contentsOf: other.connections)
    }
}

struct ConnectionsKey: PreferenceKey {
    static let defaultValue = Connections()

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue())
    }
}

//extension View {
//    func patch(id: PatchNodeID, to tail: PatchNodeID? = nil) -> some View {
//        anchorPreference(key: ConnectionsKey.self, value: .bounds, transform: {
//            Connections(frames: [id: $0], connections: previous.map {
//                [Patch(id: id, tail: tail)] } ?? [])
//        })
//    }
//
//    func drawConnections() -> some View {
//        overlayPreferenceValue(ConnectionsKey.self) { connInfo in
//            GeometryReader { proxy in
//                let pairs = connInfo.connections
//                ForEach(pairs, id: \.from) { (item, next) in
//                    if let from = connInfo.frames[item], let to = connInfo.frames[next] {
//                        let fromP = proxy[from][.bottom]
//                        let toP = proxy[to][.top]
//                        let availableHeight = toP.y-fromP.y
//                        DottedLine(availableHeight: availableHeight-4)
//                            .foregroundColor(.primary)
//                            .frame(width: 6, height: availableHeight)
//                            .offset(x: fromP.x - 3, y: fromP.y)
//                    }
//                }
//            }
//        }
//    }
//}
