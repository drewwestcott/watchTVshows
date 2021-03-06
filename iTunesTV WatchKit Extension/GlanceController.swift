//
//  GlanceController.swift
//  iTunesTV WatchKit Extension
//
//  Created by Drew Westcott on 31/12/2015.
//  Copyright © 2015 Drew Westcott. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {

    @IBOutlet var glanceTitle: WKInterfaceLabel!
    @IBOutlet var glanceText: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        glanceTitle.setText("New Show")
        glanceTitle.setTextColor(UIColor.greenColor())
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
