import SwiftUI

struct MatrixView: View {
    let grid: [[Cell?]]   // 3×3 with one missing cell

    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { col in
                        ZStack {
                            Rectangle()
                                .stroke(.gray, lineWidth: 2)
                                .aspectRatio(1, contentMode: .fit)

                            if let cell = grid[row][col] {
                                ForEach(0..<cell.objects.count, id: \.self) { index in
                                    ShapeView(obj: cell.objects[index])
                                }
                            } else {
                                Color.clear
                            }
                        }
                    }
                }
            }
        }
    }
}
