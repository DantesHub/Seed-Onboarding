//
//  ContentBlockerRequestHandler.swift
//  AdultContentBlocker
//
//  Created by Gursewak Singh on 26/09/24.
//

import MobileCoreServices
import UIKit

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {
    func beginRequest(with context: NSExtensionContext) {
        let attachment = NSItemProvider(contentsOf: Bundle.main.url(forResource: "blockerList", withExtension: "json"))!

        let item = NSExtensionItem()
        item.attachments = [attachment]

        context.completeRequest(returningItems: [item], completionHandler: nil)
    }
}
