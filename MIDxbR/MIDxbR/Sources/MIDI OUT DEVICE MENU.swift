import Cocoa

/// Protocol defining a MIDI output device interface.
protocol MidiOutDevice {
    /// Resets the device.
    func reset()
    /// Closes the device.
    func close()
    /// Opens the device with the specified device ID. Returns true if successful.
    func open(deviceID: Int) -> Bool
    
    /// Returns the number of available MIDI output devices.
    static func getNumOutDevices() -> Int
    /// Returns the name of the device for the given ID, or nil if not available.
    static func getDeviceName(for deviceID: Int) -> String?
    /// The device ID for the MIDI Mapper.
    static var midiMapperID: Int { get }
}

/// A Swift version of a MIDI Out Device Menu using NSMenu.
class MidiOutDeviceMenu {
    /// The submenu that displays available devices.
    var popupMenu: NSMenu
    /// The total number of devices listed.
    var maxDevices: Int = 0
    /// The MIDI Mapper menu item tag, if present.
    var mapperID: Int?
    /// The base menu tag used for device items.
    var idmBase: Int = 0
    /// The currently attached MIDI output device.
    var midiOut: MidiOutDevice?
    
    /// The concrete type conforming to MidiOutDevice used for static calls.
    let deviceType: MidiOutDevice.Type
    
    /// Initializes the device menu.
    ///
    /// - Parameters:
    ///   - menu: The parent menu in which to insert the device submenu.
    ///   - position: The index position in the parent menu.
    ///   - name: The title of the submenu.
    ///   - baseMsg: The base tag value for menu items.
    ///   - deviceType: The concrete type conforming to MidiOutDevice.
    init(menu: NSMenu, position: Int, name: String, baseMsg: Int, deviceType: MidiOutDevice.Type) {
        self.popupMenu = NSMenu(title: name)
        self.idmBase = baseMsg
        self.deviceType = deviceType
        create(menu: menu, position: position, name: name, baseMsg: baseMsg)
    }
    
    /// Creates the device submenu, populating it with available MIDI output devices.
    ///
    /// - Parameters:
    ///   - menu: The parent menu.
    ///   - position: The index at which to insert the submenu.
    ///   - name: The title of the submenu.
    ///   - baseMsg: The base tag for menu items.
    private func create(menu: NSMenu, position: Int, name: String, baseMsg: Int) {
        // Create a menu item that will host the popup submenu.
        let submenuItem = NSMenuItem(title: name, action: nil, keyEquivalent: "")
        submenuItem.submenu = popupMenu
        menu.insertItem(submenuItem, at: position)
        
        // Populate the popup menu with available MIDI output devices.
        maxDevices = deviceType.getNumOutDevices()
        for deviceID in 0..<maxDevices {
            let deviceName = deviceType.getDeviceName(for: deviceID) ?? "Unknown Device"
            let item = NSMenuItem(title: deviceName, action: #selector(selectDeviceAction(_:)), keyEquivalent: "")
            // Set the tag as the base plus the device index.
            item.tag = baseMsg + deviceID
            // Set the target so that the action is called.
            item.target = self
            popupMenu.addItem(item)
        }
        
        // Attempt to add the MIDI Mapper if available.
        if let mapperName = deviceType.getDeviceName(for: deviceType.midiMapperID) {
            let item = NSMenuItem(title: mapperName, action: #selector(selectDeviceAction(_:)), keyEquivalent: "")
            item.tag = baseMsg + maxDevices
            item.target = self
            popupMenu.addItem(item)
            mapperID = item.tag
            maxDevices += 1
        }
    }
    
    /// Called when a menu item is selected.
    @objc private func selectDeviceAction(_ sender: NSMenuItem) {
        _ = selectDevice(id: sender.tag)
    }
    
    /// Selects a MIDI output device based on the provided menu item tag.
    ///
    /// - Parameter id: The menu item tag for the selected device.
    /// - Returns: True if the device was successfully selected and opened.
    func selectDevice(id: Int) -> Bool {
        guard let midiOut = midiOut else { return false }
        // Ensure the id is within the valid range.
        if id < idmBase || id >= idmBase + maxDevices { return false }
        
        // Close any currently open device.
        midiOut.reset()
        midiOut.close()
        
        // Open the device. If the selected id matches the mapper, use the mapper's device ID.
        let isOpen: Bool
        if let mapperID = mapperID, id == mapperID {
            isOpen = midiOut.open(deviceID: deviceType.midiMapperID)
        } else {
            isOpen = midiOut.open(deviceID: id - idmBase)
        }
        
        // Update the state of menu items.
        for item in popupMenu.items {
            item.state = (item.tag == id && isOpen) ? .on : .off
        }
        return isOpen
    }
}
