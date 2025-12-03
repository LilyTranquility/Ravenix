import SwiftUI

struct ContentView: View {

    // Generate one demo puzzle from the logic layer
    private let puzzle = PuzzleGenerator.generateDemo()

    @State private var selectedIndex: Int? = nil
    @State private var feedback: String? = nil

    var body: some View {
        VStack(spacing: 24) {
            // Title
            Text("Ravenix")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Demo 3×3 Matrix")
                .font(.headline)
                .foregroundColor(.secondary)

            // Matrix from generated puzzle
            MatrixView(grid: puzzle.grid)
                .padding(.horizontal)

            // Prompt
            Text("Which piece completes the pattern?")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // 4 answer options from generated puzzle
            HStack(spacing: 16) {
                ForEach(0..<puzzle.answerOptions.count, id: \.self) { index in
                    let choice = puzzle.answerOptions[index]

                    Button {
                        selectedIndex = index
                        if index == puzzle.correctAnswerIndex {
                            feedback = "Correct!"
                        } else {
                            feedback = "Try again"
                        }
                    } label: {
                        ZStack {
                            // background square
                            Rectangle()
                                .stroke(
                                    index == selectedIndex
                                    ? Color.blue
                                    : Color.gray,
                                    lineWidth: index == selectedIndex ? 3 : 2
                                )
                                .frame(width: 70, height: 70)

                            // candidate piece
                            ShapeView(obj: choice)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            // Feedback text
            if let feedback = feedback {
                Text(feedback)
                    .font(.headline)
                    .foregroundColor(
                        selectedIndex == puzzle.correctAnswerIndex ? .green : .red
                    )
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
