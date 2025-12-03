import SwiftUI

struct ContentView: View {

    // Demo 3×3 grid with one missing cell (bottom-left)
    private let demoGrid: [[Cell?]] = [
        [
            Cell(objects: [VisualObject(shape: .circle,   color: .red,    size: 1.0)]),
            Cell(objects: [VisualObject(shape: .square,   color: .blue,   size: 1.0)]),
            Cell(objects: [VisualObject(shape: .triangle, color: .green,  size: 1.0)])
        ],
        [
            Cell(objects: [VisualObject(shape: .triangle, color: .blue,   size: 1.0)]),
            Cell(objects: [VisualObject(shape: .circle,   color: .green,  size: 1.0)]),
            Cell(objects: [VisualObject(shape: .square,   color: .red,    size: 1.0)])
        ],
        [
            nil,
            Cell(objects: [VisualObject(shape: .square,   color: .purple, size: 1.0)]),
            Cell(objects: [VisualObject(shape: .circle,   color: .orange, size: 1.0)])
        ]
    ]

    var body: some View {
        VStack(spacing: 24) {
            Text("Ravenix")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Demo 3×3 Matrix")
                .font(.headline)
                .foregroundColor(.secondary)

            MatrixView(grid: demoGrid)
                .padding()

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
