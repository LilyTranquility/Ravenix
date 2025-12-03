import SwiftUI

/// Concrete shapes that the UI can draw.
enum ShapeType: CaseIterable {
    case circle
    case square
    case triangle
}

/// Rotation in 90° increments.
enum Rotation: Int, CaseIterable {
    case degrees0 = 0
    case degrees90 = 90
    case degrees180 = 180
    case degrees270 = 270
}

/// Optional flips that can be applied to a shape.
enum Flip: CaseIterable {
    case none
    case horizontal
    case vertical
}

/// One visual object that can live inside a cell, including orientation and optional layering.
struct VisualObject: Identifiable, Equatable {
    let id = UUID()
    var shape: ShapeType
    var color: Color
    var size: Double
    var rotation: Rotation
    var flip: Flip
    /// Layer or ring index for multi-layer icons (nil when unused).
    var ringIndex: Int?
}

/// A single grid cell (may hold 0 or more visual objects).
struct Cell: Identifiable, Equatable {
    let id = UUID()
    var objects: [VisualObject]

    static func empty() -> Cell {
        Cell(objects: [])
    }
}
