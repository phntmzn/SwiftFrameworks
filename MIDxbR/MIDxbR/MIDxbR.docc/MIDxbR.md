# MIDxbR Framework

## Overview

MIDxbR is a powerful framework designed for MIDI event synchronization and production system management. It provides high-resolution timing, seamless integration with MIDI devices, and a robust architecture for real-time MIDI event processing.

## Features

- **High-resolution Timing:** Achieve accurate MIDI event scheduling with resolutions up to 960 ticks per beat.
- **MIDI Synchronization:** Support for both internal and external MIDI clock synchronization.
- **Real-time Processing:** Efficient handling of MIDI events with minimal latency.
- **Modular Design:** Easily extend and integrate with other MIDI components.

## Installation

To integrate MIDxbR into your project, follow these steps:

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/yourusername/MIDxbR.git
   ```

2. **Add to Your Xcode Project:**
   - Drag and drop the MIDxbR framework into your project.
   - Ensure it is added to your target's build phases.

3. **Import the Framework:**
   ```swift
   import MIDxbR
   ```

## Usage

### Setting Up the Production System

The production system initializes the MIDI manager and processes incoming MIDI events. For example:

```swift
// Start the production system
ProductionSystem.shared.start()

// Later, stop the production system
ProductionSystem.shared.stop()
```

### MIDI Synchronization

MIDxbR includes a robust MIDI synchronization module. Use the `MidiSync` class to manage synchronization:

```swift
// Create a MidiSync instance with internal sync mode
let midiSync = MidiSync(hWnd: self, mode: .internalSync, timerPeriod: 0.01)
midiSync.start()

// Handle an incoming MIDI clock event
midiSync.midiClockEvent()
```

## API Documentation

### Production System

- `start()`: Starts the production system and registers MIDI input handlers.
- `stop()`: Stops the production system and releases resources.

### MidiSync

- `start()`: Begins the synchronization process using a timer.
- `stop()`: Stops the synchronization process.
- `pause(resetOutputs:)`: Pauses sync and optionally resets MIDI outputs.
- `restart()`: Resumes sync from the current tick position.
- `setTempo(_:)`: Sets the current tempo (in microseconds per beat).
- `setResolution(_:)`: Configures the resolution (ticks per beat).
- `getPosition(unit:)`: Retrieves the current sync position in milliseconds or ticks.

## Contributing

Contributions are welcome! Please submit pull requests or file issues on GitHub.

## License

This project is licensed under the [MIT License](LICENSE).
