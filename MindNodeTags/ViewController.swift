//
//  ViewController.swift
//  document based appliation
//
//  Created by Jonathan on 22/11/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Cocoa
import CoreGraphics
import Sparkle

class tagsClass{
    var list = [Tag]()
    
    var numberOfCheckedTagsBeforeClick = 0
    
    func flatList() -> [Tag] {
        return flattenTagList(list)
    }
    
    func totalTags() -> Int {
        return flatList().count
    }
    
    func filterCheckedOnFlat() -> [Tag] {
        
        flatList().filter {$0.checkedState == .on}
    }
    
}

class ViewController: NSViewController {
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    var tags = tagsClass()
    
    var nsDocumentContent: Document? { return view.window?.windowController?.document as? Document}
    
    var history: History!
    
    var selectedRow = 0
    
    var nsDocumentMainNode: nodeStruct {
        get {return nsDocumentContent!.structOfMindNodeFile.mindMap.mainNodes[0]}
        set {nsDocumentContent!.structOfMindNodeFile.mindMap.mainNodes[0] = newValue}
    }
    
    var nsDocumentMainNodeList: [nodeStruct] {
        get {nsDocumentMainNodeListGet()}
        set {nsDocumentMainNodeListSet(nodeList: newValue)}
    }
    
    func nsDocumentMainNodeListGet() -> [nodeStruct] {
        switch nsDocumentContent!.loadedVersion {
        case .five:
            return nsDocumentContent!.structOfMindNodeFile.mindMap.mainNodes
        case .six:
            return nsDocumentContent!.structOfMindNode6File.canvas.mindMaps.map {$0.mainNode}
        case .none:
            fatalError("nsDocumentMainNodeListGet Switch Error")
        }
    }
    
    func nsDocumentMainNodeListSet(nodeList: [nodeStruct]) {
        switch nsDocumentContent!.loadedVersion {
        case .five:
            nsDocumentContent!.structOfMindNodeFile.mindMap.mainNodes = nodeList
        case .six:
            nsDocumentContent!.structOfMindNode6File.canvas.mindMaps =  nodeList.map {mindMapsStruct(branchType: 0, styleAdjustmentType: 0, mainNode: $0, branchWidthType: 0, layoutStyle: 2)}
        case .none:
            print("nsDocument Set Error")
        }
    }
    
    
    func tagsGet() -> [TagStruct]? {
        switch nsDocumentContent!.loadedVersion {
        case .five:
            return nsDocumentContent!.structOfMindNodeFile?.tags
        case .six:
            return nsDocumentContent!.structOfMindNode6File?.tags
        case .none:
            fatalError("Tag Get Switch Error")
        }
        
    }
    
    func tagsSet(tagList: [TagStruct]) {
        switch nsDocumentContent!.loadedVersion {
        case .five:
            nsDocumentContent!.structOfMindNodeFile.tags = tagList
        case .six:
            nsDocumentContent!.structOfMindNode6File.tags = tagList
        case .none:
            print("Tag set error")
        }
    }
    
    func historyGet() ->  [[nodeStruct]]? {
        switch nsDocumentContent!.loadedVersion {
        case .five:
            return nsDocumentContent!.structOfMindNodeFile.history1?.map {$0.nodeStructVar}
        case .six:
            return nsDocumentContent!.structOfMindNode6File.history1?.map {$0.nodeStructVar}
        case .none:
            fatalError("History get Switch Error")
        }
        
    }
    
    func historySet(history: [[nodeStruct]]) {
        switch nsDocumentContent!.loadedVersion {
        case .five:
            let returnBit = history.map {nodeStructList(nodeStructVar: $0)}
            nsDocumentContent!.structOfMindNodeFile.history1 = returnBit
        case .six:
            nsDocumentContent!.structOfMindNode6File.history1 = history.map {nodeStructList(nodeStructVar: $0)}
        case .none:
            print("History set error")
        }
    }
    
    //    var unfilteredDocument: [nodeStruct]!
    var unfilteredDocumentList: [[nodeStruct]]!
    var documentHistory: [[nodeStruct]]!
    
    var indexInDocumentHistory = 0
    var hasAppBeenLaunched = false
    let itemPasteboardType = NSPasteboard.PasteboardType(rawValue: "jonathan.outlineItem")
    
    let delegate = NSApplication.shared.delegate as! AppDelegate
    
    @IBAction func checkForUpdates(_ sender: Any) {
        let updater = SUUpdater.shared()
        updater?.feedURL = URL(string: "some mystery location")
        updater?.checkForUpdates(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outlineView.delegate = self
        outlineView.dataSource = self
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.white.cgColor;
        outlineView.selectionHighlightStyle = .none
        // make outline view able to accept drag drop of this made up type
        outlineView.registerForDraggedTypes([itemPasteboardType])
        
        NotificationCenter.default.addObserver(self, selector: #selector(addNewTagstoTagList), name: NSNotification.Name(rawValue: "refeshTagsList"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkBoxClicked), name: NSNotification.Name(rawValue: "checkBoxClicked"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(boldOnSelected), name: NSOutlineView.selectionDidChangeNotification, object: nil)
        
        
        
        
    }
    
    
    
    var lastCellSelected: TagCellView?
    
    @objc func boldOnSelected(_ sender: NSNotification) {
        lastCellSelected?.box.isHidden = true
        let row = (sender.object! as! NSOutlineView).selectedRow
        if row == -1 {
            // the selectedRow is -1 if there is no row selected
            return
        }
        let tagCellView = outlineView.view(atColumn: 0, row: row, makeIfNecessary: false) as! TagCellView
        //        tagCellView.wantsLayer = true
        //        tagCellView.layer?.masksToBounds = false
        
        tagCellView.box.isHidden = false
        
        lastCellSelected = tagCellView
        //        guard let sender1 = sender.object as? TagCellView else {return}
        //        sender1.tagName.textColor = .systemRed
        //        NSLog("Selection Changed")
    }
    
    override func viewWillAppear() {
        // when the app is hidden then unhidden it also calls this function. But I don't want it to be run again
        if hasAppBeenLaunched == false {
            let markedCurrDoc = markWillShowInFilterList(nodeList:  nsDocumentMainNodeList, taglist: [], markAllChildren: true)
            unfilteredDocumentList = [markedCurrDoc]
            documentHistory = [markedCurrDoc]
            //            unfilteredDocumentList = [[]]
            
            if historyGet() == nil {
                print("View will appear set history")
                historySet(history: [markedCurrDoc])
            }
            
            history = History()
            //            sendActionSaveNSDocument()
            
            tags.list = convertTagStructListToTagList(tagStructList: tagsGet() ?? [])
            addNewTagstoTagList()
            DispatchQueue.main.async {
                // I don't know why but if I don't do this the code doesn't seem to be called properly
                moveAppNextToOpenMindNodeDocument()
            }
            //            Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(saveCurrentDocToHistory), userInfo: nil, repeats: true)
            hasAppBeenLaunched = true
            
            
        }
        
    }
    
    
    
    
    
    //  Code to run load table every 3 seconds. I don't use this becuase when my app is not in focus it will no update the screen
    //        DispatchQueue.main.async {
    //            self.document!.addWindowController(MyWindowController(window: self.view.window!))
    //            let date = Date().addingTimeInterval(1)
    //            let timer = Timer(fireAt: date, interval: 3, target: self, selector: #selector(loadTableFromAppDelegate), userInfo: nil, repeats: true)
    //            RunLoop.main.add(timer, forMode: .common)
    //        }
    
    
    
    @IBAction func unfilterCurrentDocument(_ sender: Any) {
        
        
        let newUnfilteredDocumentList = mergeUnfilteredWithFiltered(unfiltered: unfilteredDocumentList[0], filtered: nsDocumentMainNodeList)
        
        // this fixes a problem where I unfilter but for some reason it doesn't work. I don't know why but trying it a few times seems to fix it
        
        // I could have added new items while the document was
        var counter = 0
        repeat {
            counter += 1
            nsDocumentMainNodeList = newUnfilteredDocumentList
            sendActionSaveNSDocument()
            if counter == 10 {
                print("Broke out of unfilter save check after 10 attemps")
                break
            }
            if (nsDocumentMainNodeList == newUnfilteredDocumentList) {
                break
            }
        }
            while nsDocumentMainNodeList != newUnfilteredDocumentList
    }
    
    @IBAction func filterCurrentDocumentWithSelectedTags(_ sender: Any) {
        // get list of tags
        let filterdTags = tags.filterCheckedOnFlat()
        let filteredTagsString = filterdTags.map {$0.tagName}
        
        let newUnfilteredDocumentList: [nodeStruct]
        if tags.numberOfCheckedTagsBeforeClick == 0 { // i.e I am going from 0 boxes checked to 1
            // if this is the first tag we are filtering by anything on the screen couldn have changed. In particular I could have deleted a node. By marknig the unfilteredDocumentList[0] and all its children as 'in the filtered list' it means that the version of this that is saved to unfilteredDocumentList includes things like deleted nodes.
            let unfiltered1 = markWillShowInFilterList(nodeList: unfilteredDocumentList[0], taglist: [], markAllChildren: true)
            newUnfilteredDocumentList = mergeUnfilteredWithFiltered(unfiltered: unfiltered1, filtered: nsDocumentMainNodeList)
        } else {
            newUnfilteredDocumentList = mergeUnfilteredWithFiltered(unfiltered: unfilteredDocumentList[0], filtered: nsDocumentMainNodeList)
        }
        
        unfilteredDocumentList.insert(markWillShowInFilterList(nodeList: newUnfilteredDocumentList, taglist: filteredTagsString, markAllChildren: false), at: 0)
        
        //        unfilteredDocumentList.insert(newUnfilteredDocumentList, at: 0)
        
        
        let newFilteredDocumentList = filterNodeListByTag(subnodeList: newUnfilteredDocumentList, tagsToFilterBy: filteredTagsString)
        
        var counter = 0
        repeat {
            counter += 1
            nsDocumentMainNodeList = newFilteredDocumentList
            sendActionSaveNSDocument()
            if counter == 10 {
                print("filter: stoped after 10 save attemps")
                break
            }
            if nsDocumentMainNodeList == newFilteredDocumentList {
                break
            }
        }
            while nsDocumentMainNodeList != newFilteredDocumentList
        
    }
    
    @objc func checkBoxClicked() {
        // update model with checkbox changes
        view.window?.level = .floating
        for indexOfTag in 0..<tags.totalTags() {
            let tagCellView = outlineView.view(atColumn: 0, row: indexOfTag, makeIfNecessary: false) as! TagCellView
            tags.list = replaceTagInTagList(tagList: tags.list, replaceUUID: tagCellView.uuid, replaceCheckbox: tagCellView.checkbox.state)
        }
        
        
        // unfilter if there are no checkboxes checked. This is here
        let areNoTagsSelected = tags.filterCheckedOnFlat().count == 0
        if areNoTagsSelected {
            unfilterCurrentDocument("checkBoxClicked")
        } else {
            filterCurrentDocumentWithSelectedTags("checkBoxClicked")
        }
        
        tags.numberOfCheckedTagsBeforeClick = tags.filterCheckedOnFlat().count
        
        saveCurrentDocToHistory()
        
    }
    
    @objc func addNewTagstoTagList() {
        
        if nsDocumentContent == nil {
            print("This happens when I close with command w")
            return
        }
        
        for row in 0..<tags.flatList().count {
            if outlineView.item(atRow: row) != nil {
                let tagCellView = outlineView.view(atColumn: 0, row: row, makeIfNecessary: false) as? TagCellView
                tagCellView?.checkbox.isEnabled = false
            }
        }
        
        
        
        DispatchQueue.global().async(qos: .userInteractive) {
            // This adds a delay to the process as otherwise when users click and unclick the checkbox very fast it caused problems. I tested a bunch of times and 0.7 seconds was the stable minimum
            let seconds: Double = 0.7
            let dispatchTime: DispatchTime = DispatchTime.now() + seconds
            DispatchQueue.global().asyncAfter(deadline: dispatchTime) {
                DispatchQueue.main.async {
                    let allTagsInCurrentDoc = getListOfTagsFromListOfNodes(nodeList: self.nsDocumentMainNodeList)
                    for tag in allTagsInCurrentDoc {
                        if self.tags.flatList().filter({$0.tagName == tag.tagName}).count == 0 {
                            self.tags.list.append(tag)
                        }
                    }
                    
                    //                    writeTags(to: URL(string: "file:///Users/jonathan/Desktop/tags.xml")!, tagList: self.tags.list)
                    self.tagsSet(tagList: convertTagListToTagStructList(tagList: self.tags.list))
                    
                    self.sendActionSaveNSDocument()
                    let selectedIndexes = self.outlineView.selectedRow
                    self.outlineView.reloadData()
                    self.outlineView.expandItem(nil, expandChildren: true)
                    
                    DispatchQueue.global().async(qos: .userInteractive) {
                        let seconds: Double = 0.05
                        
                        let dispatchTime: DispatchTime = DispatchTime.now() + seconds
                        DispatchQueue.global().asyncAfter(deadline: dispatchTime) {
                            DispatchQueue.main.async {
                                self.outlineView.selectRowIndexes(IndexSet(arrayLiteral: selectedIndexes), byExtendingSelection: false)
                                
                                for row in 0..<self.tags.flatList().count {
                                    if self.outlineView.item(atRow: row) != nil {
                                        let tagCellView = self.outlineView.view(atColumn: 0, row: row, makeIfNecessary: false) as? TagCellView
                                        tagCellView?.checkbox.isEnabled = true
                                    }
                                    
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        
        
        
        moveAppNextToOpenMindNodeDocument()
    }
    
    
    @objc func saveCurrentDocToHistory() {
        
        let newUnfilteredDocumentList: [nodeStruct]
        if tags.numberOfCheckedTagsBeforeClick == 0 {
            let unfiltered1 = markWillShowInFilterList(nodeList: unfilteredDocumentList[0], taglist: [], markAllChildren: true)
            newUnfilteredDocumentList = mergeUnfilteredWithFiltered(unfiltered: unfiltered1, filtered: nsDocumentMainNodeList)
        } else {
            newUnfilteredDocumentList = mergeUnfilteredWithFiltered(unfiltered: unfilteredDocumentList[0], filtered: nsDocumentMainNodeList)
        }
        print("Saving with \(newUnfilteredDocumentList[0].subnodes.count) nodes")
        if history.numberFiles != 0 && newUnfilteredDocumentList == history.get(index: 0) {
            print("Identical no need to make a backup")
            return
        }
        history.add(content: newUnfilteredDocumentList)
        
    }
    
    @IBAction func changeCurrentDocumentToHistory(_ sender: NSSegmentedControl) {
        
        switch sender.selectedSegment {
        case 0: // back
            if indexInDocumentHistory < (history.numberFiles-1) {
                print("Went Back")
                indexInDocumentHistory += 1
                nsDocumentMainNodeList = history.get(index: indexInDocumentHistory)
                sendActionSaveNSDocument()
            }
        case 1: // forward
            if indexInDocumentHistory > 0 {
                print("Went Forward")
                indexInDocumentHistory -= 1
                nsDocumentMainNodeList = history.get(index: indexInDocumentHistory)
                sendActionSaveNSDocument()
            }
        default:
            fatalError("Switch case should not exist")
        }
        print("Current Pointer = \(indexInDocumentHistory+1)/\(history.numberFiles)")
        
    }
    
    
    
    
    override func keyUp(with event: NSEvent) {
        
        if (event.keyCode == 49) {
            //            // make a space update the checkbox
            //            let selectedView = outlineView.view(atColumn: 0, row: outlineView.selectedRow, makeIfNecessary: false) as! TagCellView
            //            selectedView.checkbox.setNextState()
            //            // handle check box clicks like mouse checkbox clicks
            //            selectedView.checkboxClicked("keyUp")
            
        } else if (event.keyCode == 51){
            // delete remove selected row
            let rowIndicatingNoSelection = -1
            selectedRow = outlineView.selectedRow
            if selectedRow == rowIndicatingNoSelection {
                return
            }
            let selectedView = outlineView.view(atColumn: 0, row: outlineView.selectedRow, makeIfNecessary: false) as! TagCellView
            
            outlineView.beginUpdates()
            let output = getIndexParentChild(itemToFind: selectedView.uuid, children: tags.list, currentItem: nil)
            tags.list = removeItemList(removeIndex: output!.Index, parentOfItemToRemove: output?.Parent, inputItems: tags.list)
            outlineView.removeItems(at: IndexSet(arrayLiteral: output!.Index), inParent: output?.Parent, withAnimation: .effectFade)
            outlineView.reloadItem(nil, reloadChildren: true)
            
            
            DispatchQueue.main.async {
                if self.tags.flatList().count == self.selectedRow {
                    self.selectedRow -= 1
                }
                self.outlineView.selectRowIndexes(IndexSet(arrayLiteral: self.selectedRow), byExtendingSelection: false)
            }
            outlineView.endUpdates()
            
        }
    }
    

func sendActionSaveNSDocument() {
    NSApp.sendAction(#selector(NSDocument.save(_:)), to: nil, from: self)
}

}

extension ViewController: NSOutlineViewDelegate {
    
    // Make the view that is used in the outline
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let item = item as! Tag
        let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: self)
            as! TagCellView
        cell.textField?.stringValue = "\(item.tagName)   (\(occurancesOfTag(tagInQuestion: item, tagList: getListOfTagsFromListOfNodes(nodeList: nsDocumentMainNodeList))))"
        cell.checkbox?.state = item.checkedState
        cell.uuid = item.uuid
        cell.box.isHidden = true
        return cell
    }
}

extension ViewController: NSOutlineViewDataSource {
    
    
    // number of children
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return tags.list.count
        }
        let item = item as! Tag
        return item.children.count
    }
    // child of item
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return tags.list[index]
        }
        let item = item as! Tag
        return item.children[index]
    }
    // is item expandable
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return true
    }
    
    // should show triangle thing
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        let item = item as! Tag
        if item.children.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    //
    // drag and drop
    //
    
    // returns the bit that is stored in the pasteboard. We store a unique string made but UUID
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        let pp = NSPasteboardItem()
        let item = item as! Tag
        pp.setString(item.uuid, forType: itemPasteboardType)
        return pp
    }
    
    // if a proposed drop location should be accepted
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        let pasteboardItem = info.draggingPasteboard.pasteboardItems?.first
        let theString = pasteboardItem!.string(forType: itemPasteboardType)!
        let draggedItem = getIndexParentChild(itemToFind: theString, children: tags.list, currentItem: nil)
        
        if draggedItem?.Item.uuid == (item as? Tag)?.uuid {
            return []
        }
        
        let currentRow = outlineView.row(forItem: item)
        let canDrag = index >= 0
        let onCurrentRow = currentRow == index
        if !canDrag {
            return []
        } else {
            return .move
        }
        
        //        return canDrag ? .move : []
        
    }
    
    // Handle user dropping item
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        guard
            let pasteboardItem = info.draggingPasteboard.pasteboardItems?.first,
            let theString = pasteboardItem.string(forType: itemPasteboardType),
            let draggedItem = getIndexParentChild(itemToFind: theString, children: tags.list, currentItem: nil)
            else {return false}
        var newIndex = index
        
        let item = (item as? Tag ?? nil)
        if (draggedItem.Parent == item) && draggedItem.Index < index {
            newIndex = index - 1
        }
        outlineView.beginUpdates()
        outlineView.moveItem(at: draggedItem.1, inParent: draggedItem.0, to: newIndex, inParent: item)
        tags.list = removeItemList(removeIndex: draggedItem.Index, parentOfItemToRemove: draggedItem.Parent, inputItems: tags.list)
        tags.list = insertItemList(insertIndex: newIndex, parentOfItemToRemove: item, inputItems: tags.list, insertItem: draggedItem.Item)
        outlineView.reloadItem(nil, reloadChildren: true)
        outlineView.expandItem(item)
        outlineView.endUpdates()
        
        tagsSet(tagList: convertTagListToTagStructList(tagList: self.tags.list))
        sendActionSaveNSDocument()
        
        return true
    }
    
}
