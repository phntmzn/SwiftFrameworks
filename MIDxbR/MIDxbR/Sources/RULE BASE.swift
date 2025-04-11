//
//  Rule_Base.swift
//  MIDxbR
//
//  Created by jappleseed on 3/23/25.
//

import Foundation

/// A rule base for music theory that analyzes MIDI note data to determine chord and scale names.
public class MusicTheoryRuleBase {
    
    /// Shared instance for singleton usage.
    public static let shared = MusicTheoryRuleBase()
    
    /// Private initializer to enforce singleton usage.
    private init() {}
    
    /// Attempts to identify a chord based on an array of MIDI note values.
    /// - Parameter midiNotes: An array of UInt8 representing MIDI note numbers.
    /// - Returns: A string describing the detected chord or an "Unknown chord" message.
    public func chordName(for midiNotes: [UInt8]) -> String {
        guard midiNotes.count >= 3 else {
            return "Not enough notes to form a chord."
        }
        
        // Convert MIDI note values to pitch classes (0-11) and sort them.
        let notes = midiNotes.map { Int($0) % 12 }.sorted()
        
        // Try each note as a potential root.
        for root in notes {
            let intervals = notes.map { ($0 - root + 12) % 12 }
            // Check for a major triad (root, major third, perfect fifth).
            if intervals.contains(4) && intervals.contains(7) {
                return "\(noteName(for: root)) Major"
            }
            // Check for a minor triad (root, minor third, perfect fifth).
            else if intervals.contains(3) && intervals.contains(7) {
                return "\(noteName(for: root)) Minor"
            }
        }
        
        return "Unknown chord"
    }
    
    /// Attempts to identify a scale based on an array of MIDI note values.
    /// This simple example only checks for a major scale pattern: 2, 2, 1, 2, 2, 2, 1.
    /// - Parameter midiNotes: An array of UInt8 representing MIDI note numbers.
    /// - Returns: A string describing the detected scale or an "Unknown scale" message.
    public func scaleName(for midiNotes: [UInt8]) -> String {
        guard midiNotes.count >= 7 else {
            return "Not enough notes to form a scale."
        }
        
        // Convert to pitch classes (0-11) and sort them.
        let notes = midiNotes.map { Int($0) % 12 }.sorted()
        
        // Calculate intervals between consecutive notes.
        var intervals: [Int] = []
        for i in 0..<notes.count - 1 {
            intervals.append((notes[i+1] - notes[i] + 12) % 12)
        }
        // Add wrap-around interval from the last note back to the first note plus 12.
        intervals.append((12 - notes.last! + notes.first!) % 12)
        
        // The major scale pattern: whole, whole, half, whole, whole, whole, half (2,2,1,2,2,2,1).
        let majorPattern = [2, 2, 1, 2, 2, 2, 1]
        if intervals == majorPattern {
            return "\(noteName(for: notes.first!)) Major Scale"
        }
        
        return "Unknown scale"
    }
    
    /// Returns the note name for a given pitch class (0-11).
    /// - Parameter pitchClass: An integer representing the pitch class.
    /// - Returns: A string with the note name.
    private func noteName(for pitchClass: Int) -> String {
        let noteNames = ["C", "C♯/D♭", "D", "D♯/E♭", "E", "F", "F♯/G♭", "G", "G♯/A♭", "A", "A♯/B♭", "B"]
        return noteNames[pitchClass % 12]
    }
}
