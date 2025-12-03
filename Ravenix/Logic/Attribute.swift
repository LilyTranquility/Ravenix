// Attribute.swift
// Ravenix logic layer: symbolic attributes used for rule generation.

import Foundation
import SwiftUI   // Needed so we can map to Color & VisualObject

// MARK: - Symbolic enums

enum ShapeSymbol: Int, CaseIterable {
    case circle = 0
    case square = 1
    case triangle = 2
}

enum ColorSymbol: Int, CaseIterable {
    case red = 0
    case blue
    case green
    case purple
    case orange
}

// Discrete size steps used in patterns (small → medium → large).
enum SizeStep: Int, CaseIterable {
    case small = 0
    case medium
    case large
}

/// Discrete 90-degree rotation states for symbolic and visual objects.
enum Rotation: Int, CaseIterable {
    case deg0 = 0
    case deg90 = 90
    case deg180 = 180
    case deg270 = 270

    /// Combine two rotations, wrapping around 360°.
    func rotated(by other: Rotation) -> Rotation {
        let total = (self.rawValue + other.rawValue) % 360
        return Rotation(rawValue: total) ?? .deg0
    }
}

/// Supported flip states.
enum FlipState: CaseIterable {
    case none
    case horizontal
    case vertical

    /// Apply a new flip transformation on top of the current state.
    func applying(_ newFlip: FlipState) -> FlipState {
        switch (self, newFlip) {
        case (_, .none):
            return self
        case (.none, _):
            return newFlip
        case let (current, incoming) where current == incoming:
            // Double-flip cancels out.
            return .none
        default:
            // Mixing horizontal + vertical behaves like toggling to the incoming one.
            return newFlip
        }
    }
}

/// Basic transformation operations that can be applied to symbolic objects.
enum Transformation: CaseIterable {
    case rotate90
    case rotate180
    case rotate270
    case flipHorizontal
    case flipVertical
}

// MARK: - Symbolic objects & grid

/// One symbolic object in a cell.
struct SymbolicObject: Equatable {
    var shape: ShapeSymbol
    var color: ColorSymbol
    var sizeStep: SizeStep
    var rotation: Rotation = .deg0
    var flip: FlipState = .none
    var layerIndex: Int? = nil
}

/// Backwards-compatible initializer so older code that only
/// passes shape + color still compiles (defaults to medium size).
extension SymbolicObject {
    init(shape: ShapeSymbol, color: ColorSymbol) {
        self.shape = shape
        self.color = color
        self.sizeStep = .medium
        self.rotation = .deg0
        self.flip = .none
        self.layerIndex = nil
    }

    /// Return a copy of the object after applying the provided transformation.
    func applying(_ t: Transformation) -> SymbolicObject {
        var copy = self

        switch t {
        case .rotate90:
            copy.rotation = copy.rotation.rotated(by: .deg90)
        case .rotate180:
            copy.rotation = copy.rotation.rotated(by: .deg180)
        case .rotate270:
            copy.rotation = copy.rotation.rotated(by: .deg270)
        case .flipHorizontal:
            copy.flip = copy.flip.applying(.horizontal)
        case .flipVertical:
            copy.flip = copy.flip.applying(.vertical)
        }

        return copy
    }

    /// Apply the same transformation repeatedly.
    func applyingRepeated(_ t: Transformation, count: Int) -> SymbolicObject {
        guard count > 0 else { return self }

        return (0..<count).reduce(self) { current, _ in
            current.applying(t)
        }
    }
}

/// A cell can hold multiple symbolic objects (we only use 1 for now).
struct SymbolicCell: Equatable {
    var objects: [SymbolicObject]
}

/// 3×3 symbolic grid. `nil` means an empty/missing cell.
typealias SymbolicGrid = [[SymbolicCell?]]


// MARK: - Mapping to visual layer (VisualObject / Cell)

/// These extensions bridge the symbolic model (ShapeSymbol / ColorSymbol / SizeStep)
/// to your visual model (ShapeType / Color / size Double / Cell).

extension SizeStep {
    var scale: Double {
        switch self {
        case .small:  return 0.7   // tweak these if you like
        case .medium: return 1.0
        case .large:  return 1.3
        }
    }
}

extension ShapeSymbol {
    var visualShape: ShapeType {
        switch self {
        case .circle:   return .circle
        case .square:   return .square
        case .triangle: return .triangle
        }
    }
}

extension ColorSymbol {
    var visualColor: Color {
        switch self {
        case .red:    return .red
        case .blue:   return .blue
        case .green:  return .green
        case .purple: return .purple
        case .orange: return .orange
        }
    }
}

extension SymbolicObject {
    /// Convert one symbolic object into a VisualObject for rendering.
    func toVisual() -> VisualObject {
        VisualObject(
            shape: shape.visualShape,
            color: color.visualColor,
            rotation: rotation,
            flip: flip,
            layerIndex: layerIndex
        )
    }
}

extension SymbolicGrid {
    /// Convert the 3×3 symbolic grid into a 3×3 visual grid (Cell?).
    /// `nil` stays nil (the missing piece).
    func toCellGrid() -> [[Cell?]] {
        map { row in
            row.map { maybeSymbolicCell in
                guard let sCell = maybeSymbolicCell else {
                    return nil
                }
                let visuals = sCell.objects.map { $0.toVisual() }
                return Cell(objects: visuals)
            }
        }
    }
}
