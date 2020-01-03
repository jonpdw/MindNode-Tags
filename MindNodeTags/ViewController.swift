//
//  ViewController.swift
//  document based appliation
//
//  Created by Jonathan on 22/11/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Cocoa
//import CoreGraphics
import Sparkle
  


class ViewController: NSViewController{
    
    
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    // MARK: -
    
    var nsDocumentContent: Document? { return view.window?.windowController?.document as? Document}
    
    var nsDocumentMainNodeList: [nodeStruct] {
        get {nsDocumentNodeListGet()}
        set {nsDocumentNodeListSet(nodeList: newValue)}
    }
    
    var tagsInStruct: [TagStruct]? {
        get {tagsGet()}
        set {tagsSet(tagList: newValue!)}
    }
    
    
    var unfilteredDocumentList: [[nodeStruct]]!
    
    var unfilteredDocumentListToFindTagsIn: [nodeStruct]!

    var tags = tagsClass()
    var backupClass = BackupNodeList()
    var saveImagesClass = SaveImages()
    var hasAppBeenLaunched = false
    let itemPasteboardTypeForMyTagCells = NSPasteboard.PasteboardType(rawValue: "jonathan.outlineItem")
    var selectedRow = 0
    var lastCellSelected: TagCellView?
    var uiIsEnabled = true
    var mindmapsForStruct6: Set<mindMapsStruct6>?
    var allowAlertForNoOpenDoc = true
    let mNoDocumentAlert = noDocumentAlert()
    var delayBetweenClicks = 1.5
    
    // MARK: -
    
    
    func changeUIto(newState: Bool) {
        let toolbarItems = view.window?.toolbar?.items ?? []
        
//        view.window?.toolbar!.validateVisibleItems()
        uiIsEnabled = newState
        switch newState {
        case true:
            outlineView.isEnabled = true
//            view.window?.makeFirstResponder(outlineView)
            changeTagsCheckbox(to: true)
            
            for item in toolbarItems {
                item.isEnabled = true
            }
            
        case false:
            outlineView.deselectAll(nil)
            outlineView.isEnabled = false
            changeTagsCheckbox(to: false)
//            view.window?.makeFirstResponder(view.window)
            for item in toolbarItems {
                item.isEnabled = false
            }
        }
    }
    
    func getMindMaps() -> Set<mindMapsStruct6>?{
        // return set
        // make sure the thing is accessing this
        let array =  self.nsDocumentContent!.structOfMindNode6File.canvas.mindMaps.map { (input) -> mindMapsStruct6 in
            var temp = input
            temp.mainNode.subnodes = []
            return temp
        }
        return Set(array)
    }
    
    func tagsGet() -> [TagStruct]? {
        switch nsDocumentContent!.loadedVersion {
        case .two:
            return nsDocumentContent!.structOfMindNode2File?.tags
        case .six:
            return nsDocumentContent!.structOfMindNode6File?.tags
        case .none:
            fatalError("Tag Get Switch Error")
        }
    }
    
    
    func tagsSet(tagList: [TagStruct]) {
        switch nsDocumentContent?.loadedVersion {
        case .two:
            nsDocumentContent!.structOfMindNode2File.tags = tagList
        case .six:
            nsDocumentContent!.structOfMindNode6File.tags = tagList
        case .none:
            print("Tag set error")
        }
    }
    
    func nsDocumentNodeListGet() -> [nodeStruct] {
        switch nsDocumentContent?.loadedVersion {
        case .two:
            return nsDocumentContent!.structOfMindNode2File.mindMap.mainNodes
        case .six:
            return nsDocumentContent!.structOfMindNode6File.canvas.mindMaps.map {$0.mainNode}
        case .none:
            print("nsDocumentMainNodeListGet Switch None.")
            return [blankNodeStruct]
            //            fatalError("nsDocumentMainNodeListGet Switch Error")
        }
    }
    
    func nsDocumentNodeListSet(nodeList: [nodeStruct]) {
        switch nsDocumentContent!.loadedVersion {
        case .two:
            nsDocumentContent!.structOfMindNode2File.mindMap.mainNodes = nodeList
        case .six:
            nsDocumentContent!.structOfMindNode6File.canvas.mindMaps =  nodeList.map {
                let currentNode = $0
                var mindMapsStructTemp = self.mindmapsForStruct6!.first {$0.mainNode.nodeID == currentNode.nodeID}!
                mindMapsStructTemp.mainNode = currentNode
                return mindMapsStructTemp
            }
        case .none:
            print("nsDocument Set Error")
        }
    }
    
//    let delegate = NSApplication.shared.delegate as! AppDelegate
    
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outlineView.delegate = self
        outlineView.dataSource = self
        
        
        // make the entire background layer white. I can't see how to do this on the storyboard
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.white.cgColor;
        
        outlineView.selectionHighlightStyle = .none
        
        // make outline view able to accept drag drop of this made up type
        outlineView.registerForDraggedTypes([itemPasteboardTypeForMyTagCells])
        
        NotificationCenter.default.addObserver(self, selector: #selector(addNewTagstoTagList), name: NSNotification.Name(rawValue: "addNewTagstoTagList"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkBoxClicked), name: NSNotification.Name(rawValue: "checkBoxClicked"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(noMindNodeDoc), name: NSNotification.Name(rawValue: "No MindNode Doc"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(highlightOnSelect), name: NSOutlineView.selectionDidChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesChanged), name: UserDefaults.didChangeNotification, object: nil)
        
        
//        NotificationCenter.default.addObserver(self, selector: #selector(mykeyUp(_:)), name: NSNotification.Name(rawValue: "keyEvent"), object: nil)
    }
    
    @objc func preferencesChanged() {
        let showButtonsBool = UserDefaults.standard.bool(forKey: "showButtons")
        closeHideFullScreenButtons(hide: showButtonsBool)
        
        delayBetweenClicks = UserDefaults.standard.double(forKey: "delayBetweenClicks")
    }
    
    func closeHideFullScreenButtons(hide bool: Bool) {
        view.window?.standardWindowButton(.closeButton)?.isHidden = bool
        view.window?.standardWindowButton(.miniaturizeButton)?.isHidden = bool
        view.window?.standardWindowButton(.zoomButton)?.isHidden = bool
    }
    
    override func viewWillAppear() {
        // when the app is hidden then unhidden it also calls this function. But I don't want it to be run again
        if hasAppBeenLaunched == false {
            if nsDocumentContent!.loadedVersion == .six {
                mindmapsForStruct6 = getMindMaps()
            }
            
            // get preferences values
            let defaults = ["showButtons": NSNumber(value: false), "delayBetweenClicks": NSNumber(value: 1.5)]
            UserDefaults.standard.register(defaults: defaults)
            
            
//            if outlineView.acceptsFirstResponder {
//                self.view.window?.makeFirstResponder(outlineView)
//            }
//            
//            outlineView.nextKeyView = outlineView
            
            unfilteredDocumentList = [markWillShowInFilterList(nodeList:  nsDocumentMainNodeList, taglist: [], markAllChildren: true)]
            
            tags.list = convertTagStructListToTagList(tagStructList: tagsInStruct ?? [])
            addNewTagstoTagList()
            
            saveImagesClass.getImagesFromBackup()
            
            hasAppBeenLaunched = true

            // sometimes a small delay is needed so the function can find the window
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                moveAppNextToOpenMindNodeDocument()
            })
        
            //  Code to run load table every 3 seconds. I don't use this becuase when my app is not in focus it will no update the screen
            //        DispatchQueue.main.async {
            //            self.document!.addWindowController(MyWindowController(window: self.view.window!))
            //            let date = Date().addingTimeInterval(1)
            //            let timer = Timer(fireAt: date, interval: 3, target: self, selector: #selector(loadTableFromAppDelegate), userInfo: nil, repeats: true)
            //            RunLoop.main.add(timer, forMode: .common)
            //        }
            
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
                if self.myKeyDown(with: $0) {
                    return nil
                } else {
                    return $0
                }
            }
            
        }
        
    }

    // MARK: - Filter Unfilter

    @objc func checkBoxClicked() {
        
        if self.view.window == nil {
        // window can become nill after having two documents open and then closing one. I don't know why the window becomes nill and why adding a check only here seems to stop crashes.
            return
        }
        if nsDocumentContent == nil {
            // this was nill in some rare situations
            print("nsDocument nil")
            return
        }
        self.view.window!.makeKey()
        
        saveImagesClass.loadAndSaveEverything()
        
        if nsDocumentContent!.loadedVersion == .six {
            mindmapsForStruct6 = getMindMaps()!.union(mindmapsForStruct6!)
        }
        
        
        // update model with checkbox changes
        for indexOfTag in 0..<tags.totalTags() {
            if let tagCellView = outlineView.view(atColumn: 0, row: indexOfTag, makeIfNecessary: false) as? TagCellView {
                tags.replaceTagInTagList(replaceUUID: tagCellView.uuid, newCheckboxState: tagCellView.checkbox.state)
            } else {
                print("problem updating model with checkbox changes")
            }
            
        }
        
        let areNoTagsSelected = tags.filterCheckedOnFlat().count == 0
        if areNoTagsSelected {
            unfilterCurrentDocument("")
        } else {
            filterCurrentDocumentWithSelectedTags("")
        }
        
        tags.numberOfCheckedTagsBeforeClick = tags.filterCheckedOnFlat().count
        
        addDocumentToBackup()
        
        changeTagsCheckbox(to: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delayBetweenClicks, execute: {
            self.changeTagsCheckbox(to: true)
        })
    }
    
    func saveDocumentAndCheckSaveWorked(docToSave: [nodeStruct]) {
        var counter = 0
        repeat {
            counter += 1
            nsDocumentMainNodeList = docToSave
            
            sendActionSaveNSDocument()
            if counter == 10 {
                print("Broke out of unfilter save check after 10 attemps")
                break
            }
            if (nsDocumentMainNodeList == docToSave) {
                break
            }
        }
            while nsDocumentMainNodeList != docToSave
    }
    
    func getUnfilteredDocument() -> [nodeStruct] {
        if tags.numberOfCheckedTagsBeforeClick == 0 {
            return nsDocumentMainNodeList
        } else {
            return mergeUnfilteredWithFiltered(unfiltered: unfilteredDocumentList[0], filtered: nsDocumentMainNodeList)
        }
    }
    
    @IBAction func unfilterCurrentDocument(_ sender: Any) {
        
        let newNodeList = mergeUnfilteredWithFiltered(unfiltered: unfilteredDocumentList[0], filtered: nsDocumentMainNodeList)
    
        saveDocumentAndCheckSaveWorked(docToSave: newNodeList)
    }
    
    @IBAction func filterCurrentDocumentWithSelectedTags(_ sender: Any) {
        let checkedTags = tags.filterCheckedOnFlat()
        let checkedTagsStringForm = checkedTags.map {$0.tagName}
        
        // Update Unfiltered Document
        let newUnfilteredDocumentList: [nodeStruct] = getUnfilteredDocument()
        
        unfilteredDocumentList.insert(markWillShowInFilterList(nodeList: newUnfilteredDocumentList, taglist: checkedTagsStringForm, markAllChildren: false), at: 0)
        
        // Filter The document
        let newFilteredDocumentList = filterNodeListByTag(subnodeList: newUnfilteredDocumentList, tagsToFilterBy: checkedTagsStringForm)
        
        saveDocumentAndCheckSaveWorked(docToSave: newFilteredDocumentList)
        
    }
    

    // MARK: -
    
    @objc func noMindNodeDoc() {
        if getMindNodeOpenFileUrlMaster() == nil {
            changeUIto(newState: false)
            mNoDocumentAlert.run()
            
        } else {
            changeUIto(newState: true)
        }
    }
    @objc func addNewTagstoTagList() {
        
        //This happens when I close with command w
        if nsDocumentContent == nil {return}
        
        
        #warning("This function can be removed if I find a solution to the nsDocumentMainNodeListSet for MindNode6 not working when I select a blank tag ")
//        changeTagsCheckbox(to: false)
        
        unfilteredDocumentListToFindTagsIn = getUnfilteredDocument()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            
            // Add new tags from document to my list of tags
            let allTagsInCurrentDoc = getListOfTagsFromListOfNodes(nodeList: self.nsDocumentMainNodeList)
            for tag in allTagsInCurrentDoc {
                if self.tags.flatList().filter({$0.tagName == tag.tagName}).count == 0 {
                    self.tags.list.append(tag)
                }
            }
            
            // Save my new tags to XML
            self.tagsInStruct = convertTagsToSavableForm(tagList: self.tags.list)
            
            let selectedIndexes = self.outlineView.selectedRow
            // outlineView gets its tags from tags.list. Trigger refresh after we just added new tags to it
            self.outlineView.reloadData()
            
//            self.outlineView.expandItem(nil, expandChildren: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                // Re-highlight selected row
                self.outlineView.selectRowIndexes(IndexSet(arrayLiteral: selectedIndexes), byExtendingSelection: false)
                
//                self.changeTagsCheckbox(to: true)
                moveAppNextToOpenMindNodeDocument()
            })
            
        })
    }
        
    
    // MARK: -
    @objc func highlightOnSelect(_ sender: NSNotification) {
        lastCellSelected?.highlightBox.isHidden = true
        
        let selectedRow = (sender.object! as! NSOutlineView).selectedRow
        
        // Make sure nothing invalid is selected
        // the selectedRow is -1 if there is no row selected
        if selectedRow == -1 { return }
        
        let totalTagsIndex = tags.totalTags()-1
        if selectedRow > totalTagsIndex || selectedRow < 0 {
            print("highlightOnSelect: Row out of range")
            return
        }
        // Select Row
        let tagCellView = outlineView.view(atColumn: 0, row: selectedRow, makeIfNecessary: false) as? TagCellView
        tagCellView?.highlightBox.isHidden = false
        
        lastCellSelected = tagCellView
    }
    
    
    
    func changeTagsCheckbox(to newState: Bool) {
            for row in 0..<tags.flatList().count {
                if outlineView.item(atRow: row) != nil {
                    let tagCellView = outlineView.view(atColumn: 0, row: row, makeIfNecessary: false) as? TagCellView
                    tagCellView?.checkbox.isEnabled = newState
                }
            }
    }
    
    // MARK: - Backup
    
    @objc func addDocumentToBackup() {
        
        let unfilteredDocument = getUnfilteredDocument()
        
        let currentDocMatchesLastSave = unfilteredDocument == backupClass.get(index: 0)?.nodeStruct
        if currentDocMatchesLastSave {return}
        
        backupClass.add(content: unfilteredDocument, mindmapsForStruct61: mindmapsForStruct6)
        
    }
    
    @IBAction func changeCurrentDocumentToHistory(_ sender: NSSegmentedControl) {
        
        switch sender.selectedSegment {
        case 0: // back
            let numFilesIndexForm = backupClass.numberFiles-1
            if backupClass.indexOfCurrentBackup < numFilesIndexForm {
                print("Went Back")
                backupClass.indexOfCurrentBackup += 1
                (mindmapsForStruct6, nsDocumentMainNodeList) = backupClass.get(index: backupClass.indexOfCurrentBackup)!
                sendActionSaveNSDocument()
            }
        case 1: // forward
            if backupClass.indexOfCurrentBackup > 0 {
                print("Went Forward")
                backupClass.indexOfCurrentBackup -= 1
                (mindmapsForStruct6, nsDocumentMainNodeList) = backupClass.get(index: backupClass.indexOfCurrentBackup)!
                sendActionSaveNSDocument()
            }
        default:
            fatalError("Switch case should not exist")
        }
        print("Current Pointer = \(backupClass.indexOfCurrentBackup+1)/\(backupClass.numberFiles)")
        addNewTagstoTagList()
        
    }
    
    // MARK: -
    func isNoRowSelected() -> Bool {
        selectedRow = outlineView.selectedRow
        let rowIndicatingNoSelection = -1
        if selectedRow == rowIndicatingNoSelection {
            return true
        }
        return false
    }
    
    func myKeyDown(with event: NSEvent) -> Bool {
        
        // handle keyDown only if current window has focus, i.e. is keyWindow
        guard let locWindow = self.view.window,
            NSApplication.shared.keyWindow === locWindow else { return false }
        
        switch Int(event.keyCode) {
        case 49: // space
            if isNoRowSelected() {return true}
            let selectedView = outlineView.view(atColumn: 0, row: outlineView.selectedRow, makeIfNecessary: false) as! TagCellView
            selectedView.checkbox.setNextState()
            // handle check box clicks like mouse checkbox clicks
            selectedView.checkboxClicked("keyUp")
            return true
            
        case 51: // delete
            // delete selected row
            if isNoRowSelected() {return true}
            selectedRow = outlineView.selectedRow
            let selectedView = outlineView.view(atColumn: 0, row: selectedRow, makeIfNecessary: false) as! TagCellView
            
            outlineView.beginUpdates()
            let (_, parent, index) = tags.findTagAlongWithParentAndIndex(itemsUUIDToFind: selectedView.uuid, currentItem: nil)!
            tags.list = removeItemList(removeIndex: index, parentOfItemToRemove: parent, inputItems: tags.list)
            outlineView.removeItems(at: IndexSet(arrayLiteral: index), inParent: parent, withAnimation: .effectFade)
            outlineView.reloadItem(nil, reloadChildren: true)
            
            // Re select row after outline reload
            DispatchQueue.main.async {
                // We just deleted a row. There are now one less rows. if the selected row was the last one then we can't select the last row anymore. It must be the last -1
                if self.tags.flatList().count == self.selectedRow {
                    self.selectedRow -= 1
                }
                self.outlineView.selectRowIndexes(IndexSet(arrayLiteral: self.selectedRow), byExtendingSelection: false)
            }
            outlineView.endUpdates()
            return true
        default:
            return false
        }
    }
    

    func sendActionSaveNSDocument() {
        //    DispatchQueue.main.asyncAfter(deadline: .now(), execute: thingToDo)
        // tried calling from inside an asyncAfter and calling: nsDocumentContent!.save("viewcontroller save action")
        // both froze on me. it seemed like the nsDocument one froze more often
        NSApp.sendAction(#selector(NSDocument.save(_:)), to: nil, from: self)
        
    }
    
    @IBAction func checkForUpdates(_ sender: Any) {
        let updater = SUUpdater.shared()
        //        updater?.feedURL = URL(string: "some mystery location")
        updater?.checkForUpdates(self)
    }
    

}
