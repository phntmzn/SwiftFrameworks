//
//  SCALES.swift
//  MIDxbR
//
//  Created by jappleseed on 3/23/25.
//

import Foundation

/// Enum representing every possible scale degree with common alterations.
enum ScaleDegree: String, CaseIterable {
    case root = "1"
    case flat2 = "♭2"
    case natural2 = "2"
    case flat3 = "♭3"
    case natural3 = "3"
    case perfect4 = "4"
    case sharp4 = "♯4"
    case perfect5 = "5"
    case flat6 = "♭6"
    case natural6 = "6"
    case flat7 = "♭7"
    case natural7 = "7"
}

/// Extension providing the semitone offset for each scale degree relative to the root.
extension ScaleDegree {
    var semitoneOffset: Int {
        switch self {
        case .root:
            return 0
        case .flat2:
            return 1
        case .natural2:
            return 2
        case .flat3:
            return 3
        case .natural3:
            return 4
        case .perfect4:
            return 5
        case .sharp4:
            return 6
        case .perfect5:
            return 7
        case .flat6:
            return 8
        case .natural6:
            return 9
        case .flat7:
            return 10
        case .natural7:
            return 11
        }
    }
}

/// An array containing every possible scale degree.
let allScaleDegrees: [ScaleDegree] = ScaleDegree.allCases

// MARK: - Scale Arrays

/// The diatonic (major) scale: 1, 2, 3, 4, 5, 6, 7
let diatonicScale: [ScaleDegree] = [.root, .natural2, .natural3, .perfect4, .perfect5, .natural6, .natural7]

/// The pentatonic (major pentatonic) scale: 1, 3, 4, 5, 7
let pentatonicScale: [ScaleDegree] = [.root, .natural3, .perfect4, .perfect5, .natural7]

/// The chromatic scale: all available scale degrees.
let chromaticScale: [ScaleDegree] = allScaleDegrees

/// Example usage: Print each scale degree with its semitone offset.
func printScaleDegrees() {
    print("Diatonic Scale:")
    for degree in diatonicScale {
        print("\(degree.rawValue) (\(degree.semitoneOffset) semitones)")
    }
    
    print("\nPentatonic Scale:")
    for degree in pentatonicScale {
        print("\(degree.rawValue) (\(degree.semitoneOffset) semitones)")
    }
    
    print("\nChromatic Scale:")
    for degree in chromaticScale {
        print("\(degree.rawValue) (\(degree.semitoneOffset) semitones)")
    }
}

// To run the example, call printScaleDegrees() from an appropriate entry point, such as in a view controller's viewDidLoad().
