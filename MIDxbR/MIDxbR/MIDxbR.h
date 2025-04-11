//
//  MIDxbR.h
//  MIDxbR
//
//  Created by jappleseed on 3/23/25.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

//! Project version number for MIDxbR.
FOUNDATION_EXPORT double MIDxbRVersionNumber;

//! Project version string for MIDxbR.
FOUNDATION_EXPORT const unsigned char MIDxbRVersionString[];

//! Public interface for the MIDxbR framework.
//! This class provides methods to start and stop MIDI processing,
//! send MIDI messages, and register a handler for incoming MIDI data.
@interface MIDxbRManager : NSObject

/// Returns the shared instance of the MIDI manager.
+ (instancetype)sharedManager;

/// Starts the MIDI client and input/output ports.
- (BOOL)startMIDIWithError:(NSError **)error;

/// Stops the MIDI client and releases all ports.
- (void)stopMIDI;

/// Sends a MIDI note on message.
/// @param note The MIDI note (0-127).
/// @param velocity The velocity (0-127).
/// @param channel The MIDI channel (1-16).
- (BOOL)sendNoteOn:(UInt8)note velocity:(UInt8)velocity channel:(UInt8)channel error:(NSError **)error;

/// Sends a MIDI note off message.
/// @param note The MIDI note (0-127).
/// @param channel The MIDI channel (1-16).
- (BOOL)sendNoteOff:(UInt8)note channel:(UInt8)channel error:(NSError **)error;

/// Sends a MIDI control change message.
/// @param controller The controller number (0-127).
/// @param value The controller value (0-127).
/// @param channel The MIDI channel (1-16).
- (BOOL)sendControlChange:(UInt8)controller value:(UInt8)value channel:(UInt8)channel error:(NSError **)error;

/// Sends a MIDI program change message.
/// @param program The program number (0-127).
/// @param channel The MIDI channel (1-16).
- (BOOL)sendProgramChange:(UInt8)program channel:(UInt8)channel error:(NSError **)error;

/// Registers a callback block to handle incoming MIDI messages.
/// @param handler A block that will be invoked with incoming MIDIPacketList data.
- (void)registerMIDIInputHandler:(void (^)(MIDIPacketList *packetList, void *refCon))handler;

@end
