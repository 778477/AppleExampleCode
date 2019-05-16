/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A view controller for testing SimplePing on iOS.
 */

import UIKit

class MainViewController: UITableViewController {

    let hostName = "www.apple.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.hostName
    }

    var pinger: SimplePing?
    var sendTimer: Timer?
    
    /// Called by the table view selection delegate callback to start the ping.
    
    func start(_ ipv4 : Bool ,_ ipv6 : Bool){
        self.pingerWillStart()

        NSLog("start")

        let pinger = SimplePing(hostName: self.hostName)
        self.pinger = pinger

        // By default we use the first IP address we get back from host resolution (.Any) 
        // but these flags let the user override that.
            
        if (ipv4 && !ipv6) {
            pinger.addressStyle = SimplePingAddressStyle.icmPv4
        } else if (ipv6 && !ipv4) {
            pinger.addressStyle = SimplePingAddressStyle.icmPv6
        }

        pinger.delegate = self
        pinger.start()
    }

    /// Called by the table view selection delegate callback to stop the ping.
    
    func stop() {
        NSLog("stop")
        self.pinger?.stop()
        self.pinger = nil

        self.sendTimer?.invalidate()
        self.sendTimer = nil
        
        self.pingerDidStop()
    }

    /// Sends a ping.
    ///
    /// Called to send a ping, both directly (as soon as the SimplePing object starts up) and 
    /// via a timer (to continue sending pings periodically).
    @objc func sendPing() {
        self.pinger!.send(with: nil)
    }

    static func shortErrorFromError(error: Error) -> String {
        return error.localizedDescription
    }
    
    // MARK: table view delegate callback
    
    @IBOutlet var forceIPv4Cell: UITableViewCell!
    @IBOutlet var forceIPv6Cell: UITableViewCell!
    @IBOutlet var startStopCell: UITableViewCell!
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = tableView.cellForRow(at: indexPath)!
        switch cell {
        case forceIPv4Cell, forceIPv6Cell:
            cell.accessoryType = cell.accessoryType == .none ? .checkmark : .none
        case startStopCell:
            if self.pinger == nil {
                let forceIPv4 = self.forceIPv4Cell.accessoryType != .none
                let forceIPv6 = self.forceIPv6Cell.accessoryType != .none

                self.start(forceIPv4,forceIPv6)
            } else {
                self.stop()
            }
        default:
            fatalError()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }


    func pingerWillStart() {
        self.startStopCell.textLabel!.text = "Stop…"
    }
    
    func pingerDidStop() {
        self.startStopCell.textLabel!.text = "Start…"
    }
}


extension MainViewController : SimplePingDelegate {
    func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        NSLog("ping %@", HostResloveHelper.displayIPAddress(bySockAdr: address))
        self.sendPing()
        
        self.sendTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.sendPing), userInfo: nil, repeats: true)
    }
    
    func simplePing(_ pinger: SimplePing, didFailWithError error: Error) {
        NSLog("failed: %@", MainViewController.shortErrorFromError(error: error))
    }
    
    func simplePing(_ pinger: SimplePing, didSendPacket packet: Data, sequenceNumber: UInt16) {
        NSLog("#%u sent", sequenceNumber)
    }

    func simplePing(_ pinger: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: Error) {
        NSLog("#%u send failed: %@", sequenceNumber, MainViewController.shortErrorFromError(error: error))
    }
    
    
    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        NSLog("#%u received, size=%zu", sequenceNumber, packet.count)
    }

    func simplePing(_ pinger: SimplePing, didReceiveUnexpectedPacket packet: Data) {
        NSLog("unexpected packet, size=%zu", packet.count)
    }
}
