import Foundation

// Symbolic enums for the "logic layer" (not UI)
enum ShapeSymbol: Int, CaseIterable {
    case circle = 0
    case square
    case triangle
}

enum ColorSymbol: Int, CaseIterable {
    case red = 0
    case blue
    case green
    case purple
    case orange
}

// One symbolic object in a cell
struct SymbolicObject: Equatable {
    var shape: ShapeSymbol
    var color: ColorSymbol
    var sizeStep: Int   // 0 = normal size for now
}

// A cell can hold multiple objects, kept symbolic
struct SymbolicCell {
    var objects: [SymbolicObject]
}
