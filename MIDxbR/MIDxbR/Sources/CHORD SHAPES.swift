//
//  ChordShapes.swift
//  MIDxbR
//
//  Created by jappleseed on 3/23/25.
//

import Foundation

/// Represents a chord shape with a name and a set of intervals (in semitones) from the root.
public struct ChordShape {
    public let name: String
    /// The intervals from the root note, with the root defined as 0.
    public let intervals: [Int]
    
    public init(name: String, intervals: [Int]) {
        self.name = name
        self.intervals = intervals
    }
}

/// A repository of common chord shapes in music theory.
public struct ChordShapeRepository {
    
    /// An array containing many common chord shapes.
    public static let allChordShapes: [ChordShape] = [
        // Triads
        ChordShape(name: "Major Triad", intervals: [0, 4, 7]),
        ChordShape(name: "Minor Triad", intervals: [0, 3, 7]),
        ChordShape(name: "Diminished Triad", intervals: [0, 3, 6]),
        ChordShape(name: "Augmented Triad", intervals: [0, 4, 8]),
        
        // Seventh Chords
        ChordShape(name: "Major Seventh", intervals: [0, 4, 7, 11]),
        ChordShape(name: "Dominant Seventh", intervals: [0, 4, 7, 10]),
        ChordShape(name: "Minor Seventh", intervals: [0, 3, 7, 10]),
        ChordShape(name: "Half-Diminished Seventh", intervals: [0, 3, 6, 10]),
        ChordShape(name: "Diminished Seventh", intervals: [0, 3, 6, 9]),
        ChordShape(name: "Minor Major Seventh", intervals: [0, 3, 7, 11]),
        
        // Suspended Chords
        ChordShape(name: "Suspended 2", intervals: [0, 2, 7]),
        ChordShape(name: "Suspended 4", intervals: [0, 5, 7]),
        
        // Sixth Chords
        ChordShape(name: "Sixth Chord", intervals: [0, 4, 7, 9]),
        ChordShape(name: "Minor Sixth", intervals: [0, 3, 7, 9]),
        
        // Extended Chords
        ChordShape(name: "Dominant Ninth", intervals: [0, 4, 7, 10, 14]),
        ChordShape(name: "Major Ninth", intervals: [0, 4, 7, 11, 14]),
        ChordShape(name: "Minor Ninth", intervals: [0, 3, 7, 10, 14]),
        ChordShape(name: "Dominant Eleventh", intervals: [0, 4, 7, 10, 14, 17]),
        ChordShape(name: "Major Eleventh", intervals: [0, 4, 7, 11, 14, 17]),
        ChordShape(name: "Minor Eleventh", intervals: [0, 3, 7, 10, 14, 17]),
        ChordShape(name: "Dominant Thirteenth", intervals: [0, 4, 7, 10, 14, 17, 21]),
        ChordShape(name: "Major Thirteenth", intervals: [0, 4, 7, 11, 14, 17, 21]),
        ChordShape(name: "Minor Thirteenth", intervals: [0, 3, 7, 10, 14, 17, 21])
    ]
    
    /// Returns a formatted string representation for all chord shapes.
    public static func allChordShapesDescription() -> String {
        return allChordShapes.map { "\($0.name): \($0.intervals)" }.joined(separator: "\n")
    }
}

// Removed top-level expression to avoid "expressions are not allowed at the top level" error.
// If you need to test, consider calling this from a unit test or another executable context.
// print(ChordShapeRepository.allChordShapesDescription())
