//
//  AlbumFileLocationViewController.swift
//  jmc
//
//  Created by John Moody on 9/7/17.
//  Copyright © 2017 John Moody. All rights reserved.
//

import Cocoa

class AlbumFilePathNode: NSObject {
    
    var pathComponent: String
    var children = [AlbumFilePathNode]()
    var parent: AlbumFilePathNode?
    var totalFiles = Set<AnyHashable>()
    
    
    init(pathComponent: String, parent: AlbumFilePathNode? = nil) {
        self.pathComponent = pathComponent
        self.parent = parent
        super.init()
        if parent != nil {
            parent?.children.append(self)
        }
    }
    
    func numberBeneath() -> Int {
        var sum = 0
        for child in self.children {
            sum += child.numberBeneath()
            if child.children.count == 0 {
                sum += 1
            }
        }
        return sum
    }
    
    func completePathRepresentation() -> String {
        var pathComponents = [self.pathComponent]
        var node = self
        while node.parent != nil {
            node = node.parent!
            pathComponents.append(node.pathComponent)
        }
        pathComponents.reverse()
        let path = "/" + pathComponents.filter({$0 != "" && $0 != "/"}).joined(separator: "/")
        return path
    }
    
    func removeFileRecursive(_ file: AnyHashable) {
        if let file = self.totalFiles.remove(file) {
            for child in self.children {
                child.removeFileRecursive(file)
            }
        }
    }
    
    func getEmptyNodesBeneath() -> [AlbumFilePathNode] {
        var nodes = [AlbumFilePathNode]()
        for child in self.children {
            nodes.append(contentsOf: child.getEmptyNodesBeneath())
        }
        if self.totalFiles.count < 1 {
            nodes.append(self)
        }
        return nodes
    }
    
    func purge() {
        for child in self.children {
            child.purge()
        }
        if self.totalFiles.count < 1 {
            self.parent!.children.remove(at: self.parent!.children.index(of: self)!)
        }
    }
    
}

class AlbumFilePathTree: NSObject {
    
    var rootNode: AlbumFilePathNode
    
    func createNode(with pathComponents: inout [String], under parentOrRoot: AlbumFilePathNode? = nil, with file: AnyHashable) {
        guard pathComponents.count > 0 else { return }
        
        let currentNode = parentOrRoot ?? rootNode
        currentNode.totalFiles.insert(file)
        
        let nextPathComponent = pathComponents.removeFirst()
        
        if let nextNode = currentNode.children.first(where: {$0.pathComponent == nextPathComponent}) {
            createNode(with: &pathComponents, under: nextNode, with: file)
        } else {
            let newNode = AlbumFilePathNode(pathComponent: nextPathComponent, parent: currentNode)
            let nextURLString = URL(fileURLWithPath: newNode.completePathRepresentation()).absoluteString
            let setUnderNextNode = Set(currentNode.totalFiles.filter {(($0 as AnyObject).value(forKey: "location") as? String)?.hasPrefix(nextURLString) ?? false})
            newNode.totalFiles = setUnderNextNode
            if pathComponents.count > 0 {
                createNode(with: &pathComponents, under: newNode, with: file)
            } else {
                newNode.totalFiles.insert(file)
                return
            }
        }
    }
    
    init(files: inout [AnyHashable]) {
        self.rootNode = AlbumFilePathNode(pathComponent: "/")
        self.rootNode.totalFiles = Set(files)
        super.init()
        var indexes = [Int]()
        for (index, file) in files.enumerated() {
            if let location = (file as AnyObject).value(forKey: "location") as? String, let url = URL(string: location) {
                var path = url.path.components(separatedBy: "/").filter({$0 != ""})
                createNode(with: &path, with: file)
            } else {
                indexes.append(index)
            }
        }
        for index in indexes.sorted().reversed() {
            files.remove(at: index)
        }
    }
}

class AlbumFileLocationViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let node = item as? AlbumFilePathNode else { return nil }
        let view = outlineView.make(withIdentifier: "pathnode", owner: node) as! NSTableCellView
        let url = URL(fileURLWithPath: node.completePathRepresentation())
        let keys = [URLResourceKey.effectiveIconKey, URLResourceKey.customIconKey]
        if let values = try? url.resourceValues(forKeys: Set(keys)) {
            view.imageView?.image = values.customIcon ?? values.effectiveIcon as? NSImage
        } else {
            if node.children.count > 0 {
                view.imageView?.image = NSImage(named: NSImageNameFolder)
            }
        }
        return view
    }
    
    
    
}
