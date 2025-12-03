import SwiftUI

/// Concrete shapes that the UI can draw.
enum ShapeType: CaseIterable {
    case circle
    case square
    case triangle
}

/// One visual object that can live inside a cell.
/// (No size for now – we keep all shapes the same size on screen.)
struct VisualObject: Identifiable, Equatable {
    let id = UUID()
    var shape: ShapeType
    var color: Color
}

/// A single grid cell (may hold 0 or more visual objects).
struct Cell: Identifiable, Equatable {
    let id = UUID()
    var objects: [VisualObject]

    static func empty() -> Cell {
        Cell(objects: [])
    }
}
