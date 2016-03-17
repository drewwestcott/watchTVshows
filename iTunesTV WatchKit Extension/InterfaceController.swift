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
    var descriptions = [String]()
    
    @IBOutlet var tvTable: WKInterfaceTable!
    var itemTitle = ""
    var isValidItem = false
    @IBOutlet var updatingButton: WKInterfaceButton!
    var currentParsedElement = ""
    var entryTitle = ""
    var entryDescription = ""
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        itemTitle = elementName
        if isValidItem {
            switch elementName {
            case "title":
                entryTitle = String()
                currentParsedElement = "title"
            case "itunes:summary":
                entryDescription = String()
                currentParsedElement = "itunes:summary"
            default: break
            }
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        if itemTitle == "entry" {
            isValidItem = true
        }
        //print("ItemTitle:\(itemTitle): String:\(string):")
        switch currentParsedElement {
        case "title":
            entryTitle = entryTitle + string
        case "itunes:summary":
            entryDescription = entryDescription + string
        default: break
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            if isValidItem {
                switch elementName {
                    case "title":
                        currentParsedElement = ""
                        titles.append(entryTitle)
                    case "itunes:summary":
                        currentParsedElement = ""
                        descriptions.append(entryDescription)
                    default:
                    break
                    }
                }
                if elementName == "title" {
                    isValidItem = false
                }
            }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        //load from defaults and display last results.
        var titles = loadShowsFromDefaults()
        print("loaded:\(titles.count)\n")
        if titles.count > 0 {
            updateShowsTable(titles)
        }
        
        let url = NSURL(string: "http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/topTvSeasons/xml")
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
   
            if error == nil {
                var downloadedContent = NSString(data: data!, encoding: NSUTF8StringEncoding)
                var xmlParser = NSXMLParser()
                //print(downloadedContent)
                xmlParser = NSXMLParser(data: data!)
                xmlParser.delegate = self
                xmlParser.parse()
                
                print(self.titles.count)
                self.updatingButton.setHidden(true)
                self.updatingButton.setTitle("\(self.titles.count) shows")
                self.tvTable.setNumberOfRows(self.titles.count, withRowType: "tvRow")
   //             self.tvTable.setNumberOfRows(self.titles.count, withRowType: "tvRowController")
                for (index, title) in self.titles.enumerate() {
                   let row = self.tvTable.rowControllerAtIndex(index) as! tvRowController
                    print("table:\(title)")
                   row.showName.setText(title)
                }
                print("Still have access: \(self.titles[0])")
                self.saveToUserDefaults()
            } else {
                print(error)
            }
        })
    
        task.resume()
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }


    func testForAlpha(phrase : String) -> Int {
        let letters = NSCharacterSet.letterCharacterSet()
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        
        var letterCount = 0
        var digitCount = 0
        
        for uni in phrase.unicodeScalars {
            if letters.longCharacterIsMember(uni.value) {
                letterCount++
            } else if digits.longCharacterIsMember(uni.value) {
                digitCount++
            }
        }
        return(letterCount)
    }

    override func handleActionWithIdentifier(identifier: String?, forRemoteNotification remoteNotification: [NSObject : AnyObject]) {
        if identifier == "look" {
            updatingButton.setTitle("Looking")
        }
        if identifier == "later" {
            updatingButton.setTitle("Later")
        }
    }
    
    func updateShowsTable(shows: NSArray) {
        tvTable.setNumberOfRows(shows.count, withRowType: "tvRow")
        for (index, title) in shows.enumerate() {
            let row = tvTable.rowControllerAtIndex(index) as! tvRowController
            print("table:\(title)")
            row.showName.setText(title as? String)
        }

    }
    func saveToUserDefaults() {
        
        defaults.setObject(titles.count, forKey: "numberOfShows")
        defaults.setObject(titles, forKey: "showTitles")
    
        defaults.synchronize()
    }
    
    func loadShowsFromDefaults() -> NSArray {
        
        if let savedShows = defaults.arrayForKey("showTitles") {
            return savedShows
        } else {
            let savedShows = ["loading..."]
            return savedShows
        }
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        
            print(descriptions[rowIndex])
        return false
    }
    
}
