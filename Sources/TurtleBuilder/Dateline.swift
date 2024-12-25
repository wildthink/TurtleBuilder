//
//  Dateline.swift
//  ShowcasePackage
//
//  Created by Jason Jobe on 12/1/24.
//

import SwiftUI
//import Carbon14

// AKA Storyline
struct Dateline: View {
    @State var config: DatelineConfiguration = .monthly
    @State var center: Date = .now

    var columnWidth: CGFloat = 12
    @State var currentOffset: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    
    // Factor to reduce the sensitivity of the scrolling
    private let scrollSensitivityFactor: CGFloat = 0.5
    
    var body: some View {
        Canvas { ctx, size in
            let pen = Pen(ctx: ctx, box: size)

            pen
                .move(to: .leading)
                .line(to: .trailing)
            
//                .place(symbol: "arrowtriangle.down", .bottomLeading, at: .leading)
//                .place(symbol: "arrowtriangle.down", .topTrailing, at: .trailing)

            
            pen.font = .body
                pen.move(to: .center)
                    .place("event", .bottom)
            
            for (ndx, day) in config.markDates().enumerated() {
//            for day in 1..<10 {
                let ndx = CGFloat(ndx)
                pen.move_to(x: ndx * columnWidth)
                    .place(symbol: "arrowtriangle.down", .bottomLeading)
//                    .place(symbol: "circle", .center)
                
                let resolved = ctx.resolve("ok", font: .body)
                ctx.draw(resolved, at: pen.pos, anchor: .topLeading)
//                    .place(day.formatted(date: .abbreviated, time: .omitted), .bottom, at: .bottom)
            }
                        
        }
        .foregroundStyle(.blue)
        .font(.headline)
    }
    
    private func drawLabel(context: inout GraphicsContext, text: String, at point: CGPoint, size: CGSize) {
        let text = Text(text)
            .font(.system(size: 10))
            .foregroundColor(.orange)
        
        context.draw(text, at: point)
    }
    
}

extension Pen {
    @discardableResult
    func place(_ str: String, _ anchor: UnitPoint) -> Self {
        let resolved = ctx.resolve(str, font: font)
        ctx.draw(resolved, at: pos, anchor: anchor)
        return self
    }

    @discardableResult
    func move_to(x: CGFloat? = nil, y: CGFloat? = nil) -> Self {
        pos = CGPoint(x: x ?? pos.x, y: y ?? pos.y)
        return self
    }
}

extension DatelineConfiguration {
    static let daily: Self = Self(.day, pointSize: 8, format: .dateTime.weekday(.abbreviated))
    static let monthly: Self = Self(.month, pointSize: 8, format: .dateTime.month(.abbreviated))
}

struct DatelineConfiguration {
    var dateRange: DateInterval
    var calendarUnit: Calendar.Component
    var pointSize: CGFloat = 16
    var dateFormatStyle: Date.FormatStyle
//    var dateFormat: String = "EEE"
//    var dateFormatter: DateFormatter
    
    init(
        range: DateInterval = .thisYear,
        _ calendarUnit: Calendar.Component,
        pointSize: CGFloat,
        format: Date.FormatStyle
    ) {
        self.dateRange = range
        self.calendarUnit = calendarUnit
        self.pointSize = pointSize
        self.dateFormatStyle = format
    }
    
    func markDates() -> [Date] {
        dateRange.dates(by: calendarUnit)
    }
}

extension DateInterval {
    static func year(_ year: Int) -> DateInterval {
        let calendar = Calendar.current
        let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let end = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1))!
        return DateInterval(start: start, end: end)
    }

    static var thisYear: DateInterval {
        year(Calendar.current.component(.year, from: Date()))
    }
}

extension DateInterval {
    /// Returns an array of Dates, each Date being the starting Date of the specified Component,
    /// within the DataInterval
    func dates(by unit: Calendar.Component = .month) -> [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        var current = start
        while current < end {
            dates.append(current)
            guard let next = calendar.date(byAdding: unit, value: 1, to: current) else { break }
            current = next
        }
        return dates
    }
}

struct DatelineDemo: View {
    @State var origin: Date = .now
    @State var width: CGFloat = 30
    
    var body: some View {
        VStack {
            Text(origin, format: .dateTime.month(.abbreviated).day())
            Dateline(columnWidth: width)
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .padding(.bottom)
            Divider()
            Slider(value: $width, in: 12...80)
        }
    }
}

#Preview {
    DatelineDemo()
        .padding()
        .border(.red)
        .frame(width: 400, height: 128)
}
