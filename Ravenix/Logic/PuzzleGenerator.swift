import Foundation

// One full Ravenix puzzle: grid + answer options.
enum TransformPattern {
    case none
    case rotateAcrossRow
    case rotateAcrossColumn
    case flipAcrossRow
}

struct Puzzle {
    /// 3×3 grid with one nil hole.
    let grid: [[Cell?]]

    /// Four answer options (visual objects).
    let options: [VisualObject]

    /// Index in `options` that is the correct answer.
    let correctIndex: Int

    /// Row / column of the missing cell in the 3×3 grid.
    let holeRow: Int
    let holeCol: Int
}

struct PuzzleGenerator {

    // Public entry point – uses SystemRandomNumberGenerator by default.
    static func generate(difficulty: Difficulty, transformPattern: TransformPattern = .none) -> Puzzle {
        var rng = SystemRandomNumberGenerator()
        return generate(difficulty: difficulty, transformPattern: transformPattern, rng: &rng)
    }

    // Core generator with injectable RNG (handy for tests later).
    static func generate<R: RandomNumberGenerator>(
        difficulty: Difficulty,
        transformPattern: TransformPattern = .none,
        rng: inout R
    ) -> Puzzle {

        // 1. Build a symbolic base grid.
        var symbolicGrid: SymbolicGrid = Array(
            repeating: Array(repeating: nil, count: 3),
            count: 3
        )

        // Randomize which shapes / colors we use, but keep the pattern structured.
        let shapeCycle = ShapeSymbol.allCases.shuffled(using: &rng)
        // e.g. row 0 = colorCycle[0], row 1 = colorCycle[1], etc.
        let colorCycle = ColorSymbol.allCases.shuffled(using: &rng)

        // Very explicit size progression: small → medium → large
        let sizeCycle: [SizeStep] = [.small, .medium, .large]

        for row in 0..<3 {
            for col in 0..<3 {
                // Column controls shape (so columns look consistent)
                let shape = shapeCycle[col % shapeCycle.count]
                // Row controls color (so rows look consistent)
                let color = colorCycle[row % colorCycle.count]
                // Diagonal-ish size pattern
                let size  = sizeCycle[(row + col) % sizeCycle.count]

                var obj = SymbolicObject(shape: shape,
                                         color: color,
                                         sizeStep: size)
                obj = applyTransformPattern(obj,
                                            row: row,
                                            col: col,
                                            pattern: transformPattern)
                symbolicGrid[row][col] = SymbolicCell(objects: [obj])
            }
        }

        // 2. Choose a hole position based on difficulty.
        let holeRow: Int
        let holeCol: Int

        switch difficulty {
        case .easy:
            // Make it a bottom-row corner for now (nice and obvious).
            holeRow = 2
            holeCol = 0

        case .medium:
            // Random edge (not a corner).
            let edges = [(0,1), (1,0), (1,2), (2,1)]
            let choice = edges.randomElement(using: &rng)!
            holeRow = choice.0
            holeCol = choice.1

        case .hard, .expert:
            // Random corner.
            let corners = [(0,0), (0,2), (2,0), (2,2)]
            let choice = corners.randomElement(using: &rng)!
            holeRow = choice.0
            holeCol = choice.1
        }

        guard let missingCell = symbolicGrid[holeRow][holeCol] else {
            fatalError("Missing cell should not be nil before removal")
        }

        // Actually punch the hole.
        symbolicGrid[holeRow][holeCol] = nil

        // 3. Convert symbolic grid → visual grid.
        let visualGrid = symbolicGrid.toCellGrid()

        // 4. Correct visual object is the one inside the missing cell.
        guard let correctSymbolic = missingCell.objects.first else {
            fatalError("Missing cell should contain at least one object")
        }
        let correctVisual = correctSymbolic.toVisual()

        // 5. Build answer options: 1 correct + 3 distractors.
        var options: [VisualObject] = [correctVisual]

        while options.count < 4 {
            var alt = correctSymbolic

            if Bool.random(using: &rng) {
                // Change shape (keep color).
                var newShape = alt.shape
                while newShape == alt.shape {
                    newShape = ShapeSymbol.allCases.randomElement(using: &rng)!
                }
                alt.shape = newShape
            } else {
                // Change color (keep shape).
                var newColor = alt.color
                while newColor == alt.color {
                    newColor = ColorSymbol.allCases.randomElement(using: &rng)!
                }
                alt.color = newColor
            }

            let altVisual = alt.toVisual()
            if !options.contains(altVisual) {
                options.append(altVisual)
            }
        }

        // 6. Shuffle options and record where the correct one ended up.
        options.shuffle(using: &rng)
        let correctIndex = options.firstIndex(of: correctVisual) ?? 0

        return Puzzle(
            grid: visualGrid,
            options: options,
            correctIndex: correctIndex,
            holeRow: holeRow,
            holeCol: holeCol
        )
    }

    private static func applyTransformPattern(
        _ obj: SymbolicObject,
        row: Int,
        col: Int,
        pattern: TransformPattern
    ) -> SymbolicObject {
        switch pattern {
        case .none:
            return obj
        case .rotateAcrossRow:
            return obj.applyingRepeated(.rotate90, count: col)
        case .rotateAcrossColumn:
            return obj.applyingRepeated(.rotate90, count: row)
        case .flipAcrossRow:
            switch col {
            case 1:
                return obj.applying(.flipHorizontal)
            case 2:
                return obj.applying(.flipVertical)
            default:
                return obj
            }
        }
    }
}
