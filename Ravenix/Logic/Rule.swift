//
//  Rule.swift
//  Ravenix
//
//  Minimal rule protocol placeholder.
//  We'll add real Corvus-style rules here later.
//

import Foundation

/// A symbolic transformation rule.
/// Later we'll implement concrete rules (e.g. ShapeCycleRule, ColorCycleRule)
/// that manipulate a SymbolicGrid.
protocol Rule {
    /// Apply this rule to a base symbolic grid and return a transformed grid.
    func apply(to grid: SymbolicGrid) -> SymbolicGrid
}

/// A no-op rule used as a placeholder so the app compiles.
/// It returns the grid unchanged.
struct IdentityRule: Rule {
    func apply(to grid: SymbolicGrid) -> SymbolicGrid {
        return grid
    }
}
