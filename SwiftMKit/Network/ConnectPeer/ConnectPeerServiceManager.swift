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
    
    func connectedDeviceChanged(manager : ConnectPeerServiceManager, connectedDevices: [MCPeerID], changedDevice: MCPeerID, changedState: MCSessionState)
    func dataReceived(manager : ConnectPeerServiceManager, fromDevice: MCPeerID, data: NSData, dataString: String)
    
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
    
    func sendDataString(data : String) {
        if let dataString = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            sendData(dataString)
        }
    }
    func sendData(data : NSData) {
        DDLogVerbose("[ConnectPeerServiceManager] SendData: \(data)")
        
        if session.connectedPeers.count > 0 {
            let _ = try? self.session.sendData(data, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
        }
    }
    
}


extension ConnectPeerServiceManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        DDLogError("[ConnectPeerServiceManager] DidNotStartAdvertisingPeer: \(error)")
    }
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession?) -> Void) {
        DDLogInfo("[ConnectPeerServiceManager] DidReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
    
}

extension ConnectPeerServiceManager : MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        DDLogError("[ConnectPeerServiceManager] DidNotStartBrowsingForPeers: \(error)")
    }
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DDLogInfo("[ConnectPeerServiceManager] FoundPeer: \(peerID)")
        DDLogInfo("[ConnectPeerServiceManager] InvitePeer: \(peerID)")
        browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DDLogWarn("[ConnectPeerServiceManager] LostPeer: \(peerID)")
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
        DDLogInfo("[ConnectPeerServiceManager] Peer \(peerID) didChangeState: \(state.stringValue())")
        self.delegate?.connectedDeviceChanged(self, connectedDevices: session.connectedPeers, changedDevice: peerID, changedState: state)
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        DDLogVerbose("[ConnectPeerServiceManager] DidReceiveData: \(data.length) bytes")
        let str = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        self.delegate?.dataReceived(self, fromDevice: peerID, data: data, dataString: str)
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        DDLogVerbose("[ConnectPeerServiceManager] DidReceiveStream")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        DDLogVerbose("[ConnectPeerServiceManager] DidFinishReceivingResourceWithName")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        DDLogVerbose("[ConnectPeerServiceManager] DidStartReceivingResourceWithName")
    }
    
}
