//
//  ArtistViewTrackListViewController.swift
//  jmc
//
//  Created by John Moody on 5/22/17.
//  Copyright © 2017 John Moody. All rights reserved.
//

import Cocoa

class ArtistViewTrackListViewController: NSViewController {
    
    var album: Album
    var trackArray = [Track]()
    
    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, album: Album) {
        self.album = album
        self.trackArray = self.album.tracks!.allObjects as! [Track]
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
