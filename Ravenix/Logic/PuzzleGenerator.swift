import SwiftUI

// A single concrete puzzle in "visual world"
struct Puzzle {
    let grid: [[Cell?]]             // 3×3, one nil = missing
    let answerOptions: [VisualObject]
    let correctAnswerIndex: Int
}

struct PuzzleGenerator {

    static func generateDemo() -> Puzzle {

        // We will:
        // - pick a random base shape & color for (0,0)
        // - define 2 rules:
        //     • shape cycles along one axis
        //     • color cycles along (maybe) another axis
        // - apply them to fill a 3×3 symbolic grid
        // - remove the cell at (2, 0)
        // - build structured distractors

        let shapes = ShapeSymbol.allCases
        let colorCycle: [ColorSymbol] = [.red, .blue, .green]  // use 3 for the matrix

        let baseShape = shapes.randomElement()!
        let baseColor = colorCycle.randomElement()!

        let baseObj = SymbolicObject(shape: baseShape,
                                     color: baseColor,
                                     sizeStep: 0)

        // Two rules: one for shape, one for color
        let shapeAxis: Axis = Bool.random() ? .row : .column
        let colorAxis: Axis = Bool.random() ? .row : .column

        let shapeRule = Rule(attribute: .shape,
                             transform: .cycle,
                             axis: shapeAxis)

        let colorRule = Rule(attribute: .color,
                             transform: .cycle,
                             axis: colorAxis)

        // Helper: apply a cycle transform along an axis
        func cycledIndex(base: Int, row: Int, col: Int, axis: Axis, count: Int) -> Int {
            let step = (axis == .row) ? col : row
            return (base + step) % count
        }

        func objectForPosition(row: Int, col: Int) -> SymbolicObject {
            // shape
            let shapeBaseIndex = baseObj.shape.rawValue
            let shapeIndex = cycledIndex(
                base: shapeBaseIndex,
                row: row,
                col: col,
                axis: shapeRule.axis,
                count: shapes.count
            )
            let shape = shapes[shapeIndex]

            // color (use colorCycle indexes)
            let colorBaseIndex = colorCycle.firstIndex(of: baseObj.color) ?? 0
            let colorIndex = cycledIndex(
                base: colorBaseIndex,
                row: row,
                col: col,
                axis: colorRule.axis,
                count: colorCycle.count
            )
            let color = colorCycle[colorIndex]

            return SymbolicObject(shape: shape, color: color, sizeStep: 0)
        }

        // Build 3×3 symbolic grid with a missing cell at (2, 0)
        var gridSymbols: [[SymbolicCell?]] = Array(
            repeating: Array(repeating: nil, count: 3),
            count: 3
        )

        let missingRow = 2
        let missingCol = 0

        for r in 0..<3 {
            for c in 0..<3 {
                if r == missingRow && c == missingCol {
                    gridSymbols[r][c] = nil
                } else {
                    let obj = objectForPosition(row: r, col: c)
                    gridSymbols[r][c] = SymbolicCell(objects: [obj])
                }
            }
        }

        // True answer is what would be at the missing position
        let correctSymbol = objectForPosition(row: missingRow, col: missingCol)

        // --- Distractors: structured near-misses ---

        let allShapes = ShapeSymbol.allCases
        let allColors = ColorSymbol.allCases

        let sIndex = allShapes.firstIndex(of: correctSymbol.shape) ?? 0
        let cIndex = allColors.firstIndex(of: correctSymbol.color) ?? 0

        // 1) breaks shape rule only
        let d1 = SymbolicObject(
            shape: allShapes[(sIndex + 1) % allShapes.count],
            color: correctSymbol.color,
            sizeStep: 0
        )

        // 2) breaks color rule only
        let d2 = SymbolicObject(
            shape: correctSymbol.shape,
            color: allColors[(cIndex + 1) % allColors.count],
            sizeStep: 0
        )

        // 3) breaks both
        let d3 = SymbolicObject(
            shape: allShapes[(sIndex + 2) % allShapes.count],
            color: allColors[(cIndex + 2) % allColors.count],
            sizeStep: 0
        )

        // Shuffle where the correct answer appears
        var symbolicOptions = [correctSymbol, d1, d2, d3].shuffled()
        let correctIndex = symbolicOptions.firstIndex(of: correctSymbol) ?? 0

        // MARK: - Mapping symbolic → visual

        func toVisual(_ sObj: SymbolicObject) -> VisualObject {
            let shapeType: ShapeType
            switch sObj.shape {
            case .circle:   shapeType = .circle
            case .square:   shapeType = .square
            case .triangle: shapeType = .triangle
            }

            let color: Color
            switch sObj.color {
            case .red:    color = .red
            case .blue:   color = .blue
            case .green:  color = .green
            case .purple: color = .purple
            case .orange: color = .orange
            }

            // sizeStep could later map to e.g. 0.8, 1.0, 1.2, etc.
            return VisualObject(shape: shapeType, color: color, size: 1.0)
        }

        func toCell(_ sCell: SymbolicCell) -> Cell {
            let visuals = sCell.objects.map(toVisual)
            return Cell(objects: visuals)
        }

        let visualGrid: [[Cell?]] = gridSymbols.map { row in
            row.map { sCell in
                if let sCell = sCell {
                    return toCell(sCell)
                } else {
                    return nil
                }
            }
        }

        let answerOptions = symbolicOptions.map { toVisual($0) }

        return Puzzle(
            grid: visualGrid,
            answerOptions: answerOptions,
            correctAnswerIndex: correctIndex
        )
    }
}
