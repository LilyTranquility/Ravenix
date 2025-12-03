import Foundation

enum AttributeType {
    case shape
    case color
    case size
}

enum TransformType {
    case constant      // stays the same
    case cycle         // cycles through values (mod N)
    case progression   // increases/decreases in a step
    case alternate     // ABAB...
    // You can add more later (XOR, union, etc.)
}

enum Axis {
    case row
    case column
}

struct Rule {
    let attribute: AttributeType
    let transform: TransformType
    let axis: Axis
}
