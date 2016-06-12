//
//  MenuController.swift
//  ipcountry
//
//  Created by Oleg Medvedev on 2016-06-11.
//  Copyright © 2016 Oleg Medvedev. All rights reserved.
//

import Cocoa
import FlagKit

class StatusMenuController: NSObject {
    
    @IBOutlet weak var statusMenu: NSMenu!
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    @IBOutlet weak var localIPItem: NSMenuItem!
    @IBOutlet weak var countryItem: NSMenuItem!
    @IBOutlet weak var publicIPItem: NSMenuItem!
    
    var myIPAddrs = stIPAddrs()
    var localIPAddrsItems = [NSMenuItem]()
    var publicIPAddrsItem = NSMenuItem()
    var iconToggle = true
    let startIndex = 4
    var myCountryCode = String()
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    
    //Toggle Icon clicked
    @IBAction func toggleClicked(sender: NSMenuItem) {
        toggleIcon()
    }
    
    //Refresh clicked
    @IBAction func refreshClicked(sender: NSMenuItem) {
        updateMenuUI()
    }
    
    //Quit clicked
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    override func awakeFromNib() {
        
        //Initial Update
        statusItem.menu = statusMenu
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.myIPAddrs = parseIPAddrs()
            dispatch_async(dispatch_get_main_queue()) {
                self.updateMenuUI()
            }
        }
        
        //set up timer
        let timeInc = 5.0
        _ = NSTimer.scheduledTimerWithTimeInterval(timeInc, target: self,
                        selector: #selector(StatusMenuController.backgroundGetIPChanges), userInfo: nil, repeats: true)
        
        //background version
        _ = NSTimer(timeInterval: timeInc, target: self, selector: #selector(StatusMenuController.backgroundGetIPChanges), userInfo: nil, repeats: true)
    }
    
    //Check if IP addresses changed and if so - update
    func backgroundGetIPChanges() {
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            let newIPAddrs = parseIPAddrs()
            dispatch_async(dispatch_get_main_queue()) {
                if newIPAddrs.IP != self.myIPAddrs.IP {
                    self.myIPAddrs = newIPAddrs
                    self.updateMenuUI()
                }
            }
        }
    }
    
    //Update Menu
    func updateMenuUI() {
        
        //Update local IP addresses
        //First delete all items if exist
        if !localIPAddrsItems.isEmpty {
            for AddrsItem in localIPAddrsItems {
                statusItem.menu!.removeItem(AddrsItem)
            }
        }

        
        //Now add new ones
        localIPAddrsItems = []
        for ik in Array(startIndex...myIPAddrs.localIP.count+startIndex-1) {
            let newItem : NSMenuItem = NSMenuItem()
            statusItem.menu!.insertItem(newItem, atIndex: ik)
            newItem.title = myIPAddrs.localIP[ik-startIndex]
            localIPAddrsItems.append(newItem)
        }
        
        //Update Country
        getCountryCode() {
            countryCode, publicIP, country in
            self.myCountryCode = countryCode
            
            if self.iconToggle {
                self.statusItem.image = NSImage(flagImageWithCountryCode: self.myCountryCode)
                self.statusItem.title = nil
                
            }
            else {
                self.statusItem.image = nil
                self.statusItem.title = self.myCountryCode
            }
            
            self.countryItem.title = "Country: "+country
            self.publicIPItem.title = "Public IP: "+publicIP
        }
    }
    
    //Update icon
    func toggleIcon() {
        iconToggle = !iconToggle
        if self.iconToggle {
            self.statusItem.image = NSImage(flagImageWithCountryCode: self.myCountryCode)
            self.statusItem.title = nil
            
        }
        else {
            self.statusItem.image = nil
            self.statusItem.title = self.myCountryCode
        }
    }
}