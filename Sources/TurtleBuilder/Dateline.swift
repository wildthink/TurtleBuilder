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
//    @State var config: DatelineConfiguration = .monthly
    var timeframe: TimeFrame = .this(.year)
    @State var center: Date

    var columnWidth: CGFloat = 24
    @State var currentOffset: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    
    // Factor to reduce the sensitivity of the scrolling
    private let scrollSensitivityFactor: CGFloat = 0.5
    
    init(timeframe: TimeFrame = .this(.year), columnWidth: CGFloat) {
        self.timeframe = timeframe
        self.center = timeframe.lerp(progress: 0.5)
        self.columnWidth = columnWidth
    }
    
    var body: some View {
        ScrollView {
            HStack(spacing: 0) {
                ForEach(timeframe.dates(by: .month), id: \.self) {
                    cell(for: $0)
                        .frame(width: columnWidth)
                        .background {
                            Color.blue
                        }
                        .foregroundStyle(.white)
                }
            }
        }
        .padding()
        .border(.purple)
    }
    
    func cell(for date: Date) -> some View {
        Text(date, format: .dateTime.month().day())
    }
    
    var _body: some View {
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
            
            for (ndx, day) in timeframe.dates(by: .month).enumerated() {
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
//    static func year(_ year: Int) -> DateInterval {
//        let calendar = Calendar.current
//        let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
//        let end = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1))!
//        return DateInterval(start: start, end: end)
//    }

    func this(_ cc: Calendar.Component) -> DateInterval {
        Calendar.current.dateInterval(of: cc, for: .now)!
    }
    
    static var thisYear: DateInterval {
        Calendar.current.dateInterval(of: .year, for: .now)!
//        year(Calendar.current.component(.year, from: Date()))
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
    @State var width: CGFloat = 48
    
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
        .frame(width: 400, height: 240)
}

// MARK: Timeframe
struct TimeFrame {
    let dateInterval: DateInterval
    
    init(_ dateInterval: DateInterval) {
        self.dateInterval = dateInterval
    }
    
    subscript<Value>(dynamicMember keypath: KeyPath<DateInterval,Value>) -> Value {
        dateInterval[keyPath: keypath]
    }
    
    /// Returns the TimeInterval between the start and "to" dates.
    func duration(to date: Date) -> TimeInterval {
        assert(date >= dateInterval.start && date <= dateInterval.end)
        return dateInterval.start.timeIntervalSince(date)
    }
    
    /// Returns the ratio [0, 1] of the TimeInterval between the start and "to" dates
    /// over the TimeInterval of entire TimeFrame.
    func progress(to date: Date) -> Double {
        assert(date >= dateInterval.start && date <= dateInterval.end)
        let dt = duration(to: date)
        return dt / dateInterval.duration
    }

    /// Interprets percentage progress [0, 1] between start and end Dates
    /// I negative progress value indicates an amount "before the end" instead
    /// of "from the start",
    func lerp(progress: Double) -> Date {
        assert(progress >= -1.0 && progress <= 1.0)
        let step = dateInterval.duration * progress
        return (step < 0 ? dateInterval.end : dateInterval.start) + step
    }
}

extension TimeFrame {
    
    static func this(_ cc: Calendar.Component) -> TimeFrame {
        TimeFrame(Calendar.current.dateInterval(of: cc, for: .now)!)
    }

    func dates(by cc: Calendar.Component) -> [Date] {
        dateInterval.dates(by: cc)
    }
}
