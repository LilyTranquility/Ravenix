// ContentView.swift
// Ravenix

import SwiftUI

struct ContentView: View {

    // MARK: - Session state

    @State private var puzzles: [Puzzle] = []
    @State private var currentIndex: Int = 0
    @State private var selectedIndex: Int? = nil
    @State private var feedback: String? = nil
    @State private var score: Int = 0

    private let totalQuestions = 12

    // MARK: - Body

    var body: some View {
        VStack(spacing: 24) {
            // Title
            VStack(spacing: 4) {
                Text("Ravenix")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Adaptive Matrix Reasoning")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Question \(currentIndex + 1) of \(totalQuestions)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            Spacer(minLength: 8)

            if let puzzle = currentPuzzle {
                // Matrix
                MatrixView(grid: puzzle.grid)
                    .padding(.horizontal)

                // Prompt
                Text("Which piece completes the pattern?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)

                // Answer options
                HStack(spacing: 16) {
                    ForEach(0..<puzzle.options.count, id: \.self) { idx in
                        answerButton(for: idx, in: puzzle)
                    }
                }
                .padding(.horizontal)

                // Feedback
                if let feedback = feedback {
                    Text(feedback)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(feedback == "Correct!" ? .green : .red)
                        .padding(.top, 8)
                }

                // Next / Restart button
                Button(action: advanceOrRestart) {
                    Text(buttonTitle)
                        .font(.subheadline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
                .padding(.top, 8)
                .disabled(selectedIndex == nil && !isFinished)

                // Score
                Text("Score: \(score) / \(totalQuestions)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)

            } else {
                // Loading / empty state
                Text("Generating puzzles…")
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            if puzzles.isEmpty {
                generatePuzzleSequence()
            }
        }
    }

    // MARK: - Computed helpers

    private var currentPuzzle: Puzzle? {
        guard currentIndex < puzzles.count else { return nil }
        return puzzles[currentIndex]
    }

    private var isFinished: Bool {
        currentIndex >= totalQuestions
    }

    private var buttonTitle: String {
        if isFinished {
            return "Restart"
        } else if selectedIndex == nil {
            return "Skip"
        } else {
            return currentIndex + 1 >= totalQuestions ? "Finish" : "Next"
        }
    }

    // MARK: - UI pieces

    private func answerButton(for index: Int, in puzzle: Puzzle) -> some View {
        let isSelected = (index == selectedIndex)
        let isCorrect = (index == puzzle.correctIndex)
        let showReveal = isFinished || selectedIndex != nil

        return Button {
            handleAnswerTap(index: index, puzzle: puzzle)
        } label: {
            ZStack {
                // Base square
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor(for: isSelected,
                                        isCorrect: isCorrect,
                                        reveal: showReveal),
                            lineWidth: isSelected ? 3 : 1)
                    .frame(width: 64, height: 64)

                // Shape inside
                ShapeView(obj: puzzle.options[index])
                    .frame(width: 40, height: 40)
            }
        }
        .buttonStyle(.plain)
    }

    private func borderColor(for isSelected: Bool,
                             isCorrect: Bool,
                             reveal: Bool) -> Color {
        if reveal && isCorrect { return .green }
        if isSelected { return .blue }
        return .gray.opacity(0.6)
    }

    // MARK: - Actions

    private func handleAnswerTap(index: Int, puzzle: Puzzle) {
        guard !isFinished else { return }

        selectedIndex = index

        if index == puzzle.correctIndex {
            feedback = "Correct!"
            if currentIndex < totalQuestions {
                score += 1
            }
        } else {
            feedback = "Try again."
        }
    }

    private func advanceOrRestart() {
        if isFinished {
            currentIndex = 0
            score = 0
            selectedIndex = nil
            feedback = nil
            generatePuzzleSequence()
        } else {
            currentIndex += 1
            selectedIndex = nil
            feedback = nil

            if currentIndex >= totalQuestions {
                currentIndex = totalQuestions
            }
        }
    }

    // MARK: - Difficulty ladder & generation

    private func difficultyForQuestion(_ i: Int) -> Difficulty {
        let fraction = Double(i) / Double(max(totalQuestions - 1, 1))

        switch fraction {
        case ..<0.33: return .easy
        case ..<0.66: return .medium
        case ..<0.9:  return .hard
        default:      return .expert
        }
    }

    private func generatePuzzleSequence() {
        var generated: [Puzzle] = []
        generated.reserveCapacity(totalQuestions)

        for i in 0..<totalQuestions {
            let diff = difficultyForQuestion(i)
            let puzzle = PuzzleGenerator.generate(difficulty: diff)
            generated.append(puzzle)
        }

        self.puzzles = generated
    }
}
