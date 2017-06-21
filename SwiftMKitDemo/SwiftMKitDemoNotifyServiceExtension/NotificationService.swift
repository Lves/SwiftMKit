//
//  NotificationService.swift
//  SwiftMKitDemoNotifyServiceExtension
//
//  Created by Mao on 10/11/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UserNotifications
@available(iOS 10.0, *)
class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            
            if let imageURLString = bestAttemptContent.userInfo["image"] as? String,
                let URL = URL(string: imageURLString)
            {
                downloadAndSave(URL) { localURL, error in
                    if let localURL = localURL {
                        do {
                            let attachment = try UNNotificationAttachment(identifier: "image_downloaded", url: localURL, options: nil)
                            bestAttemptContent.attachments = [attachment]
                        } catch {
                            print(error)
                        }
                    }
                    contentHandler(bestAttemptContent)
                }
            } else {
                contentHandler(bestAttemptContent)
            }
            
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    fileprivate func downloadAndSave(_ url: URL, handler: @escaping (_ localURL: URL?, _ error: NSError?) -> Void) {
        let task = URLSession.shared.dataTask(with: url, completionHandler: {
            data, res, err in
            
            var localURL: URL? = nil
            var error: NSError? = err as NSError?
            
            if let data = data {
                let ext = (url.absoluteString as NSString).pathExtension
                let cacheURL = URL(fileURLWithPath: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.absoluteString ?? "")
                let url = cacheURL.appendingPathComponent("cacheImageUrl").appendingPathExtension(ext)
                do {
                    try data.write(to: url, options: .atomic)
                    localURL = url
                } catch let e as NSError {
                    error = e
                }
            }
            
            handler(localURL, error)
        })
        
        task.resume()
    }

}
