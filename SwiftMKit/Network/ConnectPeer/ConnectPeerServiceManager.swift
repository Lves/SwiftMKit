//
//  ConnectPeerServiceManager.swift
//  Merak
//
//  Created by Mao on 7/13/16.
//  Copyright © 2016 jimubox. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import CocoaLumberjack

protocol ConnectPeerServiceManagerDelegate {
    
    func connectedDevicesChanged(manager : ConnectPeerServiceManager, connectedDevices: [MCPeerID])
    func dataReceived(manager : ConnectPeerServiceManager, data: NSData, dataString: String)
    
}
class ConnectPeerServiceManager : NSObject {
    
    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    private let ConnectPeerServiceType = "ConnectPeer"
    private let myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    var delegate : ConnectPeerServiceManagerDelegate?
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: ConnectPeerServiceType)
        
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ConnectPeerServiceType)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        return session
    }()
    
    func sendData(data : String) {
        if let dataString = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            sendData(dataString)
        }
    }
    func sendData(data : NSData) {
        DDLogVerbose("%@", "sendData: \(data)")
        
        if session.connectedPeers.count > 0 {
            let _ = try? self.session.sendData(data, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
        }
    }
    
}


extension ConnectPeerServiceManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        DDLogError("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        DDLogInfo("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
    
}

extension ConnectPeerServiceManager : MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        DDLogError("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DDLogInfo("%@", "foundPeer: \(peerID)")
        DDLogInfo("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DDLogWarn("%@", "lostPeer: \(peerID)")
    }
    
}

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "NotConnected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        }
    }
    
}

extension ConnectPeerServiceManager : MCSessionDelegate {
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        DDLogInfo("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
        self.delegate?.connectedDevicesChanged(self, connectedDevices: session.connectedPeers)
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        DDLogVerbose("%@", "didReceiveData: \(data.length) bytes")
        let str = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        self.delegate?.dataReceived(self, data: data, dataString: str)
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        DDLogVerbose("%@", "didReceiveStream")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        DDLogVerbose("%@", "didFinishReceivingResourceWithName")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        DDLogVerbose("%@", "didStartReceivingResourceWithName")
    }
    
}