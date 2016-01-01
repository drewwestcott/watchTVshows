//
//  InterfaceController.swift
//  iTunesTV WatchKit Extension
//
//  Created by Drew Westcott on 31/12/2015.
//  Copyright © 2015 Drew Westcott. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController, NSXMLParserDelegate {
    
    var titles = [String]()
    
    @IBOutlet var tvTable: tvRowController!
    var itemTitle = ""
    var isValidItem = false
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        itemTitle = elementName
        
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        if itemTitle == "entry" {
            isValidItem = true
        }
        
        if itemTitle == "title" && isValidItem == true {
            print(string)
        }
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        let url = NSURL(string: "http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/topTvSeasons/xml")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
            if error == nil {
                var  downloadedContent = NSString(data: data!, encoding: NSUTF8StringEncoding)
                var xmlParser = NSXMLParser()
                
                xmlParser = NSXMLParser(data: data!)
                xmlParser.delegate = self
                xmlParser.parse()
                
//                print(downloadedContent)
                
            } else {
                print(error)
            }
        }
        task.resume()
        
        let json = NSURL(string: "https://itunes.apple.com/search?term=gaga&entity=song")
        
        let jtask = NSURLSession.sharedSession().dataTaskWithURL(json!) { (json, jsonResponse, jsonError) -> Void in
            
            let searchResults : NSDictionary = try! NSJSONSerialization.JSONObjectWithData(json!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            
//            print("********JSON*******\n\(searchResults)")

            let list : NSArray? = searchResults["results"] as? NSArray
            if list != nil {
                for item : AnyObject in list! {
                    if let itemInfo = item as? NSDictionary {
                        if let title = itemInfo["trackCensoredName"] as? NSString {
                            titles.append(title as String)
                            print(title)
                        }
                    }
                }
                
                self.tvTable.setNumberOfRows(self.titles.count, withRowType: "tvRowController")
                for (index, title) in self.titles.enumerate() {
                    let row = self.tvTable.rowControllerAtIndex(index) as! tvRowController
                    row.label.setText(title)
                }
                
            } else {
                print("**No data returned")
            }
        }
        jtask.resume()

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
