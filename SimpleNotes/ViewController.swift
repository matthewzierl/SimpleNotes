//
//  ViewController.swift
//  SimpleNotes
//
//  Created by Matthew Zierl on 8/14/24.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, ComposeNoteControllerDelegate, UIPopoverPresentationControllerDelegate, NoteOptionsPopoverDelegate {
    
    
    var selectedNotes = [Note]()
    var allNotes = [[Note]]() {
        didSet {
            numNotesLabel.text = "\(allNotes.flatMap{$0}.count) Notes"
        }
    }
    
    let numNotesLabel = UILabel()
    
    var tableView: UITableView!
    var collectionView: UICollectionView!
    var popoverContentController: NoteOptionsPopover!
    
    var isCollectionView = false {
        didSet {
            popoverContentController.isCollectionView = isCollectionView
        }
    }

    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: "allNotes") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                allNotes = try jsonDecoder.decode([[Note]].self, from: savedData)
            } catch {
                print("Failed to load notes")
            }
        }
        
        sortNotes()
        
        setupTableView()
        setupCollectionView()
        setupToolbar()
        setupPopover()
        
        navigationItem.title = "Notes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(presentSortOptions))
        
        navigationController?.navigationBar.alpha = 1
        
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // only want to refresh when needing to present it
        sortNotes()
        
        if isCollectionView {
            collectionView.reloadData()
        } else {
            tableView.reloadData()
        }
    }
    
    func setupTableView() {
        
        
        tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelectionDuringEditing = true // for "select notes"
        
        tableView.register(NoteCell.self, forCellReuseIdentifier: "NoteCell")
        
        tableView.isHidden = isCollectionView
        
        
        view.addSubview(tableView)
        
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 110, height: 100)
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 40)
        layout.sectionInset.left = 10
        layout.sectionInset.right = 10
        layout.sectionInset.top = 5
        layout.sectionInset.bottom = 5
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        collectionView.allowsMultipleSelectionDuringEditing = true
        
        collectionView.register(NoteCollectionViewCell.self, forCellWithReuseIdentifier: "NoteCell")
        
        collectionView.isHidden = !isCollectionView
        
        
        
        view.addSubview(collectionView)
    }
    
    func setupToolbar() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        numNotesLabel.text = "\(allNotes.flatMap{$0}.count) Notes"
        numNotesLabel.textAlignment = .center
        numNotesLabel.frame.size = CGSize(width: 100, height: 30)
        numNotesLabel.font = UIFont.systemFont(ofSize: 14)
        let numNotes = UIBarButtonItem(customView: numNotesLabel)
        let compose = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(composeNote))
        
        toolbarItems = [flexibleSpace, numNotes, flexibleSpace, compose]
        
        navigationController?.toolbar.alpha = 1
        navigationController?.toolbar.isTranslucent = true
        
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    func setupPopover() {
        popoverContentController = NoteOptionsPopover()
        popoverContentController.modalPresentationStyle = .popover
        popoverContentController.delegate = self
    }
    
    @objc func switchViewMode() {
        
        isCollectionView.toggle() // switch when pressed/called
        
        tableView.isHidden = isCollectionView
        collectionView.isHidden = !isCollectionView
        
        if isCollectionView {
            collectionView.reloadData()
        } else {
            tableView.reloadData()
        }
    }
    
    // MARK: tableView Data Source methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return allNotes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNotes[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let note = allNotes[indexPath.section][indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        
        var configuration = cell.defaultContentConfiguration()

        configuration.text = note.title

        
        cell.contentConfiguration = configuration
        
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            let deselectedNote = allNotes[indexPath.section][indexPath.row]
            selectedNotes.removeAll(where: {$0.dateModified == deselectedNote.dateModified})
            return
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            selectedNotes.append(allNotes[indexPath.section][indexPath.row])
            return
        }
        
        let note = allNotes[indexPath.section][indexPath.row]
        
        let newNoteView = ComposeNoteController(note: note, allNotes: allNotes)
        newNoteView.delegate = self
        
        navigationController?.pushViewController(newNoteView, animated: true)
    }
    
    /*
        
     */
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        
        view.backgroundColor = .systemBackground
        
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.frame.width, height: 40))
        label.font = UIFont(name: "Kailasa-Bold", size: 20)
        label.text = allNotes[section][0].key
        
        view.addSubview(label)
        
        return view
    }
    
    // trailing action
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
        // action: action itself you are configuring
        // view: object on which action is being performed. Probably the UITableViewCell
        // completionHandler: the handler that must be called when you are finished, so you can dismiss swipe actions
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completionHandler in
            self?.allNotes[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if (self?.allNotes[indexPath.section].count == 0) {
                self?.allNotes.remove(at: indexPath.section)
                tableView.deleteSections([indexPath.section], with: .fade)
            }
            
            let jsonEncoder = JSONEncoder()
            if let noteData = try? jsonEncoder.encode(self?.allNotes) {
                let defaults = UserDefaults.standard
                defaults.setValue(noteData, forKey: "allNotes")
            } else {
                completionHandler(false)
            }
            completionHandler(true) // signals to system you are finished deleting, dismissing swip actions
        }
        
        let shareAction = UIContextualAction(style: .normal, title: "Share") { [weak self] action, view, completionHandler in
            
            guard let note = self?.allNotes[indexPath.section][indexPath.row] else {
                completionHandler(false)
                return
            }
            let vc = UIActivityViewController(activityItems: [note.body], applicationActivities: nil)
            self?.present(vc, animated: true)
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")
        
        shareAction.backgroundColor = .systemBlue
        shareAction.image = UIImage(systemName: "square.and.arrow.up")
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
        swipeActions.performsFirstActionWithFullSwipe = false
        return swipeActions
        
    }
    
    // MARK: collectionView Data Source methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return allNotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allNotes[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoteCell", for: indexPath) as? NoteCollectionViewCell else { fatalError("Unable to dequeue collecition view cell") }
        
        let note = allNotes[indexPath.section][indexPath.row]
        
        cell.title.text = note.title
        cell.cellNote = note
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.isEditing {
            selectedNotes.append(allNotes[indexPath.section][indexPath.row])
            return
        }
        
        let note = allNotes[indexPath.section][indexPath.row]
        
        let newNoteView = ComposeNoteController(note: note, allNotes: allNotes)
        newNoteView.delegate = self
        
        navigationController?.pushViewController(newNoteView, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView.isEditing {
            print("removing note from selected notes")
            let deselectedNote = allNotes[indexPath.section][indexPath.row]
            selectedNotes.removeAll(where: {$0.dateModified == deselectedNote.dateModified})
            print("selected notes now has \(selectedNotes.count) notes")
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath)
            
            sectionHeader.subviews.forEach { $0.removeFromSuperview() } // remove all other views?
            
            let label = UILabel()
            label.font = UIFont(name: "Kailasa-Bold", size: 20)
            label.text = allNotes[indexPath.section][0].key
            
            label.frame = sectionHeader.frame
            
                        
            sectionHeader.addSubview(label)
            
            return sectionHeader
        } else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        print("in referenceSizeForHeaderInSection")
        return CGSize(width: collectionView.frame.width, height: 40)
    }
    
    
    
    
    func sortNotes() {
        
        var flatArray = allNotes.flatMap { $0 }
        
        flatArray.sort { note1, note2 in
            note1.dateModified > note2.dateModified
        }
        
        var newAllNotes = [[Note]]()
        var currentArray = [Note]()
        
        for note in flatArray {
            
            if let firstNote = currentArray.first {
                if note.key == firstNote.key {
                    currentArray.append(note)
                } else {
                    newAllNotes.append(currentArray)
                    currentArray = [Note]()
                    currentArray.append(note)
                }
            } else {
                currentArray.append(note)
            }
        }
        
        if !currentArray.isEmpty {
            newAllNotes.append(currentArray)
        }
        
        allNotes = newAllNotes
        
    }
    
    
    @objc func presentSortOptions(_ barButton: UIBarButtonItem) {
        
        if let popoverPresentation = popoverContentController.popoverPresentationController {
            popoverPresentation.permittedArrowDirections = .up
            popoverPresentation.sourceItem = barButton
            popoverPresentation.sourceRect = barButton.frame(in: view) ?? CGRect.zero
            popoverPresentation.delegate = self
            present(popoverContentController, animated: true)
        }
        
    }
    
    @objc func endEditing() {
        if isCollectionView {
            collectionView.isEditing = false
            for case let note as NoteCollectionViewCell in collectionView.visibleCells {
                note.isEditMode = false
            }
        } else {
            tableView.setEditing(false, animated: true)
        }
        
        
        // restore toolbar
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        numNotesLabel.text = "\(allNotes.flatMap{$0}.count) Notes"
        numNotesLabel.frame.size = CGSize(width: 100, height: 30)
        numNotesLabel.font = UIFont.systemFont(ofSize: 14)
        let numNotes = UIBarButtonItem(customView: numNotesLabel)
        let compose = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(composeNote))
        
        toolbarItems = [flexibleSpace, numNotes, flexibleSpace, compose]
        
        // clear selection
        selectedNotes.removeAll()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(presentSortOptions))
    }
    
    @objc func composeNote() {
        
        let newNoteView = ComposeNoteController(note: nil, allNotes: allNotes)
        newNoteView.delegate = self
        
        navigationController?.pushViewController(newNoteView, animated: true)
    }
    
    @objc func deleteSelectedNotes() {
        for (sectionIndex, var section) in allNotes.enumerated().reversed() {
            for (index, note) in section.enumerated().reversed() where selectedNotes.contains(where: { $0.dateModified == note.dateModified }) {
                section.remove(at: index)
                allNotes[sectionIndex] = section
                let indexPath = IndexPath(row: index, section: sectionIndex)
                if isCollectionView {
                    collectionView.deleteItems(at: [indexPath])
                } else {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
            
            if section.isEmpty {
                allNotes.remove(at: sectionIndex)
                if isCollectionView {
                    collectionView.deleteSections(IndexSet(integer: sectionIndex))
                } else {
                    tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
                }
            }
        }
        selectedNotes.removeAll()
        saveNotes()
    }
    
    func composeNoteControllerDidLoad(allNotes: [[Note]]) {
        self.allNotes = allNotes
    }
    
    func selectNotes() {
        if isCollectionView {
            collectionView.isEditing = true
            for case let note as NoteCollectionViewCell in collectionView.visibleCells {
                note.isEditMode = true
            }
        } else {
            tableView.setEditing(true, animated: true)
        }
        let deleteAll = UIBarButtonItem(title: "Delete All", style: .plain, target: self, action: #selector(deleteSelectedNotes))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [flexibleSpace, deleteAll]
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(endEditing))
    }
    
    func openRandomNote() {
        let section = allNotes[Int.random(in: 0..<allNotes.count)]
        let note = section[Int.random(in: 0..<section.count)]
        
        let newNoteView = ComposeNoteController(note: note, allNotes: allNotes)
        newNoteView.delegate = self
        
        navigationController?.pushViewController(newNoteView, animated: true)
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {

    }

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
    
    func saveNotes() {
        let jsonEncoder = JSONEncoder()
        
        if let allNotesData = try? jsonEncoder.encode(allNotes) {
            print("saving notes")
            let defaults = UserDefaults.standard
            defaults.setValue(allNotesData, forKey: "allNotes")
        } else {
            print("Failed to save allNotes")
        }
    }


}

