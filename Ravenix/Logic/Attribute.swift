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

// MARK: - Symbolic objects & grid

/// One symbolic object in a cell (shape/color/size with orientation and optional layering).
struct SymbolicObject: Equatable {
    var shape: ShapeSymbol
    var color: ColorSymbol
    var sizeStep: SizeStep
    var rotation: Rotation
    var flip: Flip
    /// Layer or ring index for multi-layer icons (nil when unused).
    var ringIndex: Int?
}

/// Backwards-compatible initializer so older code that only
/// passes shape + color still compiles (defaults to medium size).
extension SymbolicObject {
    init(shape: ShapeSymbol, color: ColorSymbol) {
        self.init(shape: shape, color: color, sizeStep: .medium)
    }

    init(
        shape: ShapeSymbol,
        color: ColorSymbol,
        sizeStep: SizeStep,
        rotation: Rotation = .degrees0,
        flip: Flip = .none,
        ringIndex: Int? = nil
    ) {
        self.shape = shape
        self.color = color
        self.sizeStep = sizeStep
        self.rotation = rotation
        self.flip = flip
        self.ringIndex = ringIndex
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
            size: sizeStep.scale,
            rotation: rotation,
            flip: flip,
            ringIndex: ringIndex
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
