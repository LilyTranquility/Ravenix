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
    var rotation: Rotation = .deg0
    var flip: FlipState = .none
    var layerIndex: Int? = nil
}

extension VisualObject {
    static func == (lhs: VisualObject, rhs: VisualObject) -> Bool {
        lhs.shape == rhs.shape &&
        lhs.color == rhs.color &&
        lhs.rotation == rhs.rotation &&
        lhs.flip == rhs.flip &&
        lhs.layerIndex == rhs.layerIndex
    }
}

extension Rotation {
    var angle: Angle {
        Angle(degrees: Double(rawValue))
    }
}

/// A single grid cell (may hold 0 or more visual objects).
struct Cell: Identifiable, Equatable {
    let id = UUID()
    var objects: [VisualObject]

    static func empty() -> Cell {
        Cell(objects: [])
    }
}
