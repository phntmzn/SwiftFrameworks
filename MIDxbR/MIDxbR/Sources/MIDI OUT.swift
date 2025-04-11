import Foundation
import CoreMIDI

/// A singleton class to manage MIDI output.
public class MIDIOutManager {
    public static let shared = MIDIOutManager()
    
    private var midiClient = MIDIClientRef()
    private var outPort = MIDIPortRef()
    private var destination: MIDIEndpointRef = 0
    
    /// Private initializer to enforce singleton usage.
    private init() {
        // Create the MIDI client.
        var status = MIDIClientCreate("MIDI Out Client" as CFString, nil, nil, &midiClient)
        guard status == noErr else {
            print("Error creating MIDI client: \(status)")
            return
        }
        
        // Create the output port.
        status = MIDIOutputPortCreate(midiClient, "Output Port" as CFString, &outPort)
        guard status == noErr else {
            print("Error creating MIDI output port: \(status)")
            return
        }
        
        // Choose the MIDI destination at port 4, if available.
        let destinationCount = MIDIGetNumberOfDestinations()
        if destinationCount > 4 {
            destination = MIDIGetDestination(4)
            print("Using MIDI destination at index 4.")
        } else {
            print("Not enough MIDI destinations available. Found \(destinationCount) destination(s).")
        }
    }
    
    /// Sends a MIDI message.
    ///
    /// - Parameter message: An array of UInt8 representing the MIDI message.
    /// - Returns: A Boolean value indicating whether the message was sent successfully.
    public func sendMIDIMessage(message: [UInt8]) -> Bool {
        // Ensure that there's a valid destination.
        guard destination != 0 else {
            print("No valid MIDI destination available.")
            return false
        }
        
        // Allocate a buffer for the MIDIPacketList.
        let bufferSize = 1024
        let packetListPointer = UnsafeMutablePointer<MIDIPacketList>.allocate(capacity: 1)
        defer { packetListPointer.deallocate() }
        
        // Initialize the packet list and add the MIDI message.
        var packet = MIDIPacketListInit(packetListPointer)
        packet = MIDIPacketListAdd(packetListPointer, bufferSize, packet, 0, message.count, message)
        
        // Send the MIDI packet list to the destination.
        let result = MIDISend(outPort, destination, packetListPointer)
        if result != noErr {
            print("Error sending MIDI message: \(result)")
            return false
        }
        
        print("MIDI message sent: \(message)")
        return true
    }
}
