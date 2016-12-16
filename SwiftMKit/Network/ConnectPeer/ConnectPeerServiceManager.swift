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
    
    func connectedDeviceChanged(_ manager : ConnectPeerServiceManager, connectedDevices: [MCPeerID], changedDevice: MCPeerID, changedState: MCSessionState)
    func dataReceived(_ manager : ConnectPeerServiceManager, fromDevice: MCPeerID, data: Data, dataString: String)
    
}
class ConnectPeerServiceManager : NSObject {
    
    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    fileprivate let ConnectPeerServiceType = "ConnectPeer"
    fileprivate let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    fileprivate let serviceAdvertiser : MCNearbyServiceAdvertiser
    fileprivate let serviceBrowser : MCNearbyServiceBrowser
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
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.required)
        session.delegate = self
        return session
    }()
    
    func sendDataString(_ data : String) {
        if let dataString = data.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            sendData(dataString)
        }
    }
    func sendData(_ data : Data) {
        DDLogVerbose("[ConnectPeerServiceManager] SendData: \(data)")
        
        if session.connectedPeers.count > 0 {
            let _ = try? self.session.send(data, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
        }
    }
    
}


extension ConnectPeerServiceManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        DDLogError("[ConnectPeerServiceManager] DidNotStartAdvertisingPeer: \(error)")
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DDLogInfo("[ConnectPeerServiceManager] DidReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
    
}

extension ConnectPeerServiceManager : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        DDLogError("[ConnectPeerServiceManager] DidNotStartBrowsingForPeers: \(error)")
    }
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DDLogInfo("[ConnectPeerServiceManager] FoundPeer: \(peerID)")
        DDLogInfo("[ConnectPeerServiceManager] InvitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DDLogWarn("[ConnectPeerServiceManager] LostPeer: \(peerID)")
    }
    
}

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .notConnected: return "NotConnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        }
    }
    
}

extension ConnectPeerServiceManager : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DDLogInfo("[ConnectPeerServiceManager] Peer \(peerID) didChangeState: \(state.stringValue())")
        self.delegate?.connectedDeviceChanged(self, connectedDevices: session.connectedPeers, changedDevice: peerID, changedState: state)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DDLogVerbose("[ConnectPeerServiceManager] DidReceiveData: \(data.length) bytes")
        let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
        self.delegate?.dataReceived(self, fromDevice: peerID, data: data, dataString: str)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        DDLogVerbose("[ConnectPeerServiceManager] DidReceiveStream")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        DDLogVerbose("[ConnectPeerServiceManager] DidFinishReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        DDLogVerbose("[ConnectPeerServiceManager] DidStartReceivingResourceWithName")
    }
    
}
