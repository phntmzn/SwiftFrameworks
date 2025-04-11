//
//  STEP EDIT.swift
//  MIDxbR
//
//  Created by jappleseed on 3/24/25.
//

import Foundation

/// A struct representing a single MIDI step.
struct MidiStep {
    /// The timestamp for when the step begins (in seconds relative to the sequence start).
    var timeStamp: TimeInterval
    /// The MIDI note value (0-127).
    var note: UInt8
    /// The velocity of the note (0-127).
    var velocity: UInt8
    /// The duration of the step (in seconds).
    var duration: TimeInterval
}

/// A class representing a MIDI Step Editor that allows for creating and editing step sequences.
class MidiStepEditor {
    /// An array of MIDI steps representing the current sequence.
    private(set) var steps: [MidiStep] = []
    
    /// Adds a new MIDI step to the sequence.
    /// - Parameters:
    ///   - timeStamp: The start time of the step.
    ///   - note: The MIDI note number.
    ///   - velocity: The velocity (volume) of the note.
    ///   - duration: The duration of the step.
    func addStep(timeStamp: TimeInterval, note: UInt8, velocity: UInt8, duration: TimeInterval) {
        let step = MidiStep(timeStamp: timeStamp, note: note, velocity: velocity, duration: duration)
        steps.append(step)
    }
    
    /// Removes a step at the given index.
    /// - Parameter index: The index of the step to remove.
    func removeStep(at index: Int) {
        guard index >= 0 && index < steps.count else { return }
        steps.remove(at: index)
    }
    
    /// Updates an existing step at the given index.
    /// - Parameters:
    ///   - index: The index of the step to update.
    ///   - newStep: The new step data to replace the old one.
    func updateStep(at index: Int, with newStep: MidiStep) {
        guard index >= 0 && index < steps.count else { return }
        steps[index] = newStep
    }
    
    /// Returns the steps sorted by their timestamp.
    func sortedSteps() -> [MidiStep] {
        return steps.sorted { $0.timeStamp < $1.timeStamp }
    }
    
    /// Prints the current step sequence to the console.
    func printSequence() {
        print("MIDI Step Sequence:")
        for (index, step) in sortedSteps().enumerated() {
            print("\(index + 1): Time: \(step.timeStamp), Note: \(step.note), Velocity: \(step.velocity), Duration: \(step.duration)")
        }
    }
    
    /// Stub function to simulate playing the step sequence.
    /// In a full implementation, this would send MIDI events to your MIDI output device.
    func playSequence() {
        print("Playing MIDI Step Sequence...")
        for step in sortedSteps() {
            print("Playing note \(step.note) at time \(step.timeStamp) with velocity \(step.velocity) for \(step.duration) seconds.")
            // Here, integrate with your custom MIDI framework to actually play the note.
        }
    }
}

/// Example usage function for MidiStepEditor.
/// Call this function from an appropriate entry point (for example, in a view controller's viewDidLoad() or main.swift)
func runMidiStepEditorExample() {
    let stepEditor = MidiStepEditor()
    stepEditor.addStep(timeStamp: 0.0, note: 60, velocity: 100, duration: 0.5) // Middle C
    stepEditor.addStep(timeStamp: 0.5, note: 62, velocity: 100, duration: 0.5) // D
    stepEditor.addStep(timeStamp: 1.0, note: 64, velocity: 100, duration: 0.5) // E
    stepEditor.printSequence()
    stepEditor.playSequence()
}

// The following line is removed from the top-level to avoid the "Expressions are not allowed at the top level" error.
// Instead, call runMidiStepEditorExample() from an appropriate place in your app.
// runMidiStepEditorExample()
