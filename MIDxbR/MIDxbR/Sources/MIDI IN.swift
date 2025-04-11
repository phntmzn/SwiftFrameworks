//
//  MIDI IN.swift
//  MIDxbR
//
//  Created by jappleseed on 3/23/25.
//

import Foundation
import CoreMIDI

/// A singleton class to manage MIDI input.
public class MIDIInManager {
    public static let shared = MIDIInManager()
    
    private var midiClient = MIDIClientRef()
    private var inputPort = MIDIPortRef()
    private var source: MIDIEndpointRef = 0
    
    /// Private initializer for singleton usage.
    private init() {
        setupMIDIClient()
    }
    
    /// Sets up the MIDI client, input port, and connects to the first available MIDI source.
    private func setupMIDIClient() {
        var status = MIDIClientCreate("MIDI In Client" as CFString, nil, nil, &midiClient)
        guard status == noErr else {
            print("Error creating MIDI client: \(status)")
            return
        }
        
        status = MIDIInputPortCreate(midiClient, "Input Port" as CFString, midiReadProc, nil, &inputPort)
        guard status == noErr else {
            print("Error creating MIDI input port: \(status)")
            return
        }
        
        let sourceCount = MIDIGetNumberOfSources()
        if sourceCount > 0 {
            source = MIDIGetSource(0)
            status = MIDIPortConnectSource(inputPort, source, nil)
            if status != noErr {
                print("Error connecting to MIDI source: \(status)")
            } else {
                print("Connected to MIDI source at index 0.")
            }
        } else {
            print("No MIDI sources found.")
        }
    }
    
    /// Stops the MIDI input by disconnecting the source and disposing of the client.
    public func stop() {
        MIDIPortDisconnectSource(inputPort, source)
        MIDIClientDispose(midiClient)
        print("MIDI In stopped.")
    }
}

/// MIDI read callback function.
/// This function is called whenever MIDI data is received.
private let midiReadProc: MIDIReadProc = { (packetList, refCon, srcConnRefCon) in
    let packets = packetList.pointee
    var packet = packets.packet
    for _ in 0..<packets.numPackets {
        // Extract the MIDI data from the packet using Mirror for reflection.
        let data = Mirror(reflecting: packet.data)
            .children
            .prefix(Int(packet.length))
            .compactMap { $0.value as? UInt8 }
        print("Received MIDI message: \(data)")
        
        // Move to the next packet.
        packet = MIDIPacketNext(&packet).pointee
    }
}
