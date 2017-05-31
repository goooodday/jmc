//
//  AdvancedFilterViewController.swift
//  minimalTunes
//
//  Created by John Moody on 12/2/16.
//  Copyright © 2016 John Moody. All rights reserved.
//

import Cocoa

class AdvancedFilterViewController: NSViewController {
    
    @IBOutlet weak var predicateEditor: NSPredicateEditor!
    
    @IBOutlet weak var limitCheck: NSButton!
    @IBOutlet weak var createSmartPlaylistButton: NSButton!
    @IBOutlet weak var playlistLengthDeterminantSelector: NSPopUpButton!
    @IBOutlet weak var itemLimitField: NSTextField!
    @IBOutlet weak var playlistSelectionCriteriaSelector: NSPopUpButton!
    
    var mainWindowController: MainWindowController?
    
    @IBAction func lengthDeterminantChanged(_ sender: AnyObject) {
        
    }

    @IBAction func orderingCriterionChanged(_ sender: AnyObject) {
        
    }
    
    func initializePredicateEditor() {
        if predicateEditor.predicate == nil {
            predicateEditor.addRow(nil)
        }
    }
    
    @IBAction func createSmartPlaylistButtonPressed(_ sender: AnyObject) {
        let newSmartCriteria = NSEntityDescription.insertNewObject(forEntityName: "SmartCriteria", into: managedContext) as! SmartCriteria
        if limitCheck.state == NSOnState {
            newSmartCriteria.fetch_limit = itemLimitField.integerValue as NSNumber?
            newSmartCriteria.fetch_limit_type = playlistLengthDeterminantSelector.titleOfSelectedItem
            newSmartCriteria.ordering_criterion = playlistSelectionCriteriaSelector.titleOfSelectedItem
        } else {
            newSmartCriteria.fetch_limit = nil
            newSmartCriteria.fetch_limit_type = nil
            newSmartCriteria.ordering_criterion = nil
        }
        newSmartCriteria.predicate = predicateEditor.predicate
        mainWindowController?.createPlaylistFromSmartCriteria(newSmartCriteria)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if mainWindowController?.currentTableViewController?.playlist != nil {
            createSmartPlaylistButton.isEnabled = false
        }
        // Do view setup here.
    }
    
}
