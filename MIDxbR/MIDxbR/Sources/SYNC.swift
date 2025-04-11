//
//  SYNC.swift
//  MIDxbR
//
//  Created by jappleseed on 3/23/25.
//

import Foundation

// MARK: - MIDI Sync Mode
enum SyncMode {
    case internalSync  // Internal timer based sync
    case midiSync      // Sync using incoming MIDI clock events
}

// MARK: - Protocol for MIDI Output Device
protocol MidiOutput {
    func sendShortMessage(_ message: UInt32)
    func reset()
}

// MARK: - MIDI Sync Class
class MidiSync {
    
    // MARK: Properties
    
    /// The window or object that will receive sync-related notifications (e.g. MIDI beat)
    var hWnd: Any?
    
    /// Current sync mode
    var syncMode: SyncMode = .internalSync
    
    /// Timer period in seconds (for internal sync)
    var timerPeriod: TimeInterval = 0.01
    
    /// Resolution: ticks per beat (e.g. 480)
    var resolution: UInt16 = 480
    
    /// Tempo in microseconds per beat (default 500,000 µs = 120 bpm)
    var tempo: UInt32 = 500000
    
    /// A scaling factor (used for tempo adjustments; set to 1 for simplicity)
    let scale: UInt32 = 1
    
    /// List of attached MIDI output devices
    var midiOutputs: [MidiOutput] = []
    
    // Timer and tick tracking
    private var timer: DispatchSourceTimer?
    var ticks: UInt32 = 0
    var fractionalTicks: UInt32 = 0
    var ticksSinceClock: UInt16 = 0
    var ticksSinceBeat: UInt16 = 0
    var tempoTicks: UInt16 = 0
    var lastTicks: UInt32 = 0
    var msPosition: UInt32 = 0
    
    // State flags
    var isRunning: Bool = false
    var sentSyncDone: Bool = false
    var holdClock: Bool = false
    var resyncNeeded: Bool = false
    
    // Computed properties
    var nTicksPerClock: UInt16 { resolution / 24 }
    /// trTime is a pre-calculated factor representing (resolution * timerPeriod in ms * 256)
    var trTime: UInt32 { UInt32(resolution) * UInt32(timerPeriod * 1000) * 256 }
    
    // MARK: - Initialization
    init(hWnd: Any?, mode: SyncMode = .internalSync, timerPeriod: TimeInterval = 0.01) {
        self.hWnd = hWnd
        self.syncMode = mode
        self.timerPeriod = timerPeriod
    }
    
    // MARK: - Sync Control Methods
    
    /// Opens and starts the sync process.
    func start() {
        // Reset counters
        ticks = 0
        fractionalTicks = 0
        ticksSinceClock = 0
        ticksSinceBeat = 0
        tempoTicks = 0
        lastTicks = 0
        msPosition = 0
        sentSyncDone = false
        isRunning = true
        
        // Start the periodic timer for sync events.
        startTimer()
    }
    
    /// Stops the sync process and resets MIDI outputs.
    func stop() {
        isRunning = false
        stopTimer()
        
        // Send MIDI STOP message to all attached outputs and reset them.
        for output in midiOutputs {
            output.sendShortMessage(0xFC) // MIDI STOP message (0xFC)
            output.reset()
        }
    }
    
    /// Pauses the sync process. Optionally resets MIDI outputs.
    func pause(resetOutputs: Bool = false) {
        isRunning = false
        stopTimer()
        
        if resetOutputs {
            for output in midiOutputs {
                output.sendShortMessage(0xFC)
                output.reset()
            }
        }
    }
    
    /// Restarts the sync process from the current tick position.
    func restart() {
        isRunning = true
        startTimer()
    }
    
    // MARK: - Timer Management
    
    private func startTimer() {
        let queue = DispatchQueue(label: "MidiSyncTimerQueue")
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now(), repeating: timerPeriod)
        timer?.setEventHandler { [weak self] in
            self?.sync()
        }
        timer?.resume()
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    // MARK: - Sync Processing
    
    /// Main sync method. This method calculates elapsed ticks, updates position,
    /// sends MIDI clock messages, and posts beat notifications.
    func sync() {
        guard isRunning else { return }
        
        // Update millisecond position
        msPosition += UInt32(timerPeriod * 1000)
        
        // Calculate new ticks (a simplified tick interpolation algorithm)
        let tickIncrement = (fractionalTicks + trTime) / tempo
        fractionalTicks = (fractionalTicks + trTime) % tempo
        
        // Handle MIDI clock sync adjustments if in midiSync mode
        if syncMode == .midiSync {
            if holdClock {
                tempoTicks += UInt16(tickIncrement)
                return
            }
            if resyncNeeded {
                fractionalTicks = 0
                let extraTicks = nTicksPerClock - UInt16(ticks - lastTicks)
                lastTicks = ticks + UInt32(extraTicks)
                resyncNeeded = false
            } else {
                tempoTicks += UInt16(tickIncrement)
            }
        } else {
            ticksSinceClock += UInt16(tickIncrement)
        }
        
        ticks += UInt32(tickIncrement)
        ticksSinceBeat += UInt16(tickIncrement)
        
        // Post beat notification if a full beat has elapsed
        if ticksSinceBeat >= resolution {
            NotificationCenter.default.post(name: Notification.Name("MIDI_BEAT"), object: self)
            ticksSinceBeat -= resolution
        }
        
        // For internal sync mode, calculate and send MIDI clock messages if needed
        var numClocks: UInt16 = 0
        if syncMode != .midiSync {
            while ticksSinceClock >= nTicksPerClock {
                numClocks += 1
                ticksSinceClock -= nTicksPerClock
            }
        }
        
        // Send clock messages to attached MIDI outputs
        for output in midiOutputs {
            if syncMode != .midiSync && numClocks > 0 {
                for _ in 0..<numClocks {
                    output.sendShortMessage(0xF8) // MIDI Clock message (0xF8)
                }
            }
            // In a full implementation, scheduled MIDI events would be checked here
            // and dispatched when their scheduled tick times are reached.
        }
        
        // If no events are pending, post a "sync done" notification once.
        if !sentSyncDone {
            NotificationCenter.default.post(name: Notification.Name("SYNC_DONE"), object: self)
            sentSyncDone = true
        }
    }
    
    // MARK: - Tempo and Resolution
    
    /// Sets the tempo (in microseconds per beat). Returns false if the tempo is zero.
    func setTempo(_ uSPerBeat: UInt32) -> Bool {
        guard uSPerBeat > 0 else { return false }
        tempo = uSPerBeat * scale
        return true
    }
    
    /// Sets the resolution (ticks per beat).
    func setResolution(_ resolution: UInt16) {
        // For example, ensure the resolution does not exceed a maximum value.
        guard resolution <= 960 else { return }
        self.resolution = resolution
    }
    
    /// Returns the current tempo in microseconds per beat.
    func getTempo() -> UInt32 {
        return tempo / scale
    }
    
    /// Returns the current resolution (ticks per beat).
    func getResolution() -> UInt16 {
        return resolution
    }
    
    /// Position units for retrieving the sync position.
    enum PositionUnit {
        case milliseconds
        case ticks
    }
    
    /// Returns the current sync position in either milliseconds or ticks.
    func getPosition(unit: PositionUnit) -> UInt32 {
        switch unit {
        case .milliseconds:
            return msPosition
        case .ticks:
            return ticks
        }
    }
    
    // MARK: - MIDI Clock Handler
    
    /// Simulate receiving a MIDI clock event. In a real implementation this would be
    /// triggered by an incoming MIDI clock message.
    func midiClockEvent() {
        // Indicate that a resync is required.
        resyncNeeded = true
        holdClock = false
        
        // Process sync immediately
        sync()
        
        // Adjust tempo based on the ticks received (simplified calculation)
        let delta = Int(nTicksPerClock) - Int(tempoTicks)
        if tempo > 0 {
            tempo = tempo - UInt32(delta) * (tempo / UInt32(resolution))
        }
        tempoTicks = 0
    }
}
