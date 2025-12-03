import SwiftUI

enum ShapeType {
    case circle
    case square
    case triangle
}

struct VisualObject {
    var shape: ShapeType
    var color: Color
    var size: Double   // 1.0 = normal size
}
