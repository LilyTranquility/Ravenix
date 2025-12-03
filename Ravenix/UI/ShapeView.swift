import SwiftUI

struct ShapeView: View {
    let obj: VisualObject

    var body: some View {
        let baseSize: CGFloat = 26

        Group {
            switch obj.shape {
            case .circle:
                Circle()
            case .square:
                Rectangle()
            case .triangle:
                Triangle()
            }
        }
        .foregroundStyle(obj.color)
        .frame(width: baseSize, height: baseSize)
    }
}

/// Simple triangle shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}
