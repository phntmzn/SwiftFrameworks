import Foundation
import CoreMIDI

/// A singleton class to manage MIDI operations.
public class MIDIManager {
    /// Shared instance of the MIDIManager.
    public static let shared = MIDIManager()
    
    private var midiClient = MIDIClientRef()
    private var inPort = MIDIPortRef()
    
    // Keep a reference for the registered MIDI input handler.
    private var inputHandler: ((MIDIPacketList) -> Void)?
    
    // Private initializer for singleton pattern.
    private init() {}
    
    /// Starts the MIDI client and creates an input port.
    /// - Returns: True if the MIDI client and input port were created successfully.
    @discardableResult
    public func startMIDI() -> Bool {
        var status = MIDIClientCreate("MIDI Client" as CFString, nil, nil, &midiClient)
        guard status == noErr else {
            print("Error creating MIDI client: \(status)")
            return false
        }
        
        status = MIDIInputPortCreate(midiClient, "Input Port" as CFString, midiReadProc, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), &inPort)
        guard status == noErr else {
            print("Error creating MIDI input port: \(status)")
            return false
        }
        
        // Additional code to connect to a MIDI source can be added here.
        return true
    }
    
    /// Stops the MIDI client and disposes of the input port.
    public func stopMIDI() {
        MIDIPortDispose(inPort)
        MIDIClientDispose(midiClient)
    }
    
    /// Sends a MIDI note on message.
    /// - Parameters:
    ///   - note: MIDI note value (0-127).
    ///   - velocity: Velocity value (0-127).
    ///   - channel: MIDI channel (1-16).
    /// - Returns: True if the message was sent successfully.
    public func sendNoteOn(note: UInt8, velocity: UInt8, channel: UInt8) -> Bool {
        // Here you would build a MIDIPacketList and send it using MIDISend.
        // For example, using a virtual MIDI destination or a connected device.
        // This is a placeholder implementation.
        print("Sending Note On: note=\(note), velocity=\(velocity), channel=\(channel)")
        return true
    }
    
    /// Sends a MIDI note off message.
    /// - Parameters:
    ///   - note: MIDI note value (0-127).
    ///   - channel: MIDI channel (1-16).
    /// - Returns: True if the message was sent successfully.
    public func sendNoteOff(note: UInt8, channel: UInt8) -> Bool {
        // Placeholder implementation for sending a MIDI note off message.
        print("Sending Note Off: note=\(note), channel=\(channel)")
        return true
    }
    
    /// Registers a callback to handle incoming MIDI data.
    /// - Parameter handler: A closure that receives a MIDIPacketList.
    public func registerMIDIInputHandler(handler: @escaping (MIDIPacketList) -> Void) {
        inputHandler = handler
    }
    
    /// Handles incoming MIDI packets by invoking the registered handler.
    /// - Parameter packetList: Pointer to a MIDIPacketList.
    fileprivate func handleMIDIInput(packetList: UnsafePointer<MIDIPacketList>) {
        // Call the registered handler with the packet list if available.
        if let handler = inputHandler {
            handler(packetList.pointee)
        } else {
            // Default behavior: print incoming packet data.
            let packets = packetList.pointee
            var packet = packets.packet
            for _ in 0..<packets.numPackets {
                let data = Mirror(reflecting: packet.data).children.prefix(Int(packet.length)).compactMap { $0.value as? UInt8 }
                print("Received MIDI packet: \(data)")
                packet = MIDIPacketNext(&packet).pointee
            }
        }
    }
}

/// MIDI read callback function.
/// This function is called whenever a MIDI packet is received.
private let midiReadProc: MIDIReadProc = { (packetList, refCon, srcConnRefCon) in
    let midiManager = Unmanaged<MIDIManager>.fromOpaque(refCon!).takeUnretainedValue()
    midiManager.handleMIDIInput(packetList: packetList)
}
