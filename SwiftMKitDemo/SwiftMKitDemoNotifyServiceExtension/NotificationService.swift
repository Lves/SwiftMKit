//
//  NotificationService.swift
//  SwiftMKitDemoNotifyServiceExtension
//
//  Created by Mao on 10/11/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceiveNotificationRequest(request: UNNotificationRequest, withContentHandler contentHandler: (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            
            if let imageURLString = bestAttemptContent.userInfo["image"] as? String,
                let URL = NSURL(string: imageURLString)
            {
                downloadAndSave(URL) { localURL, error in
                    if let localURL = localURL {
                        do {
                            let attachment = try UNNotificationAttachment(identifier: "image_downloaded", URL: localURL, options: nil)
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
    
    private func downloadAndSave(url: NSURL, handler: (localURL: NSURL?, error: NSError?) -> Void) {
        let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: {
            data, res, err in
            
            var localURL: NSURL? = nil
            var error: NSError? = err
            
            if let data = data {
                let ext = (url.absoluteString! as NSString).pathExtension
                let cacheURL = NSURL(fileURLWithPath: NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first?.absoluteString ?? "")
                let url = cacheURL.URLByAppendingPathComponent("cacheImageUrl")?.URLByAppendingPathExtension(ext)
                do {
                    try data.writeToURL(url!, options: .DataWritingAtomic)
                    localURL = url
                } catch let e as NSError {
                    error = e
                }
            }
            
            handler(localURL: localURL, error: error)
        })
        
        task.resume()
    }

}
