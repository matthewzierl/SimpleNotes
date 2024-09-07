//
//  ComposeNoteController.swift
//  SimpleNotes
//
//  Created by Matthew Zierl on 8/15/24.
//

import Foundation
import UIKit
import LocalAuthentication

class ComposeNoteController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var textView: UITextView!
    
    var note: Note?
    
    var allNotes: [[Note]]
    
    var delegate: ComposeNoteControllerDelegate?
    
    init(note: Note? = nil, allNotes: [[Note]]) {
        self.note = note
        self.allNotes = allNotes
        super.init(nibName: nil, bundle: nil) // have no clue what this does
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView = UITextView()
        view.backgroundColor = .systemBackground
        
        if note == nil { // if note doesn't exist yet, need to create empty one
            print("Note was nil, creating a new one")
            note = Note()
            note!.dateModified = note!.dateModified
            let arr = [note!]
            allNotes.append(arr) // new note must be added, will sort later
        }
        
        
        if note!.isLocked { // prompt for biometric login
            getAuthentication()
        } else {
            setupComposeNote()
        }
        
        
    }
    
    func getAuthentication() {
        print("Note was locked... prompting...")
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify Yourself"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.setupComposeNote()
                    } else {
                        // error
                        let ac = UIAlertController(title: "Authentication Failed", message: "You could not be verified. Please try again.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "Okay", style: .default))
                        self?.present(ac, animated: true)
                    }
                }
            }
        } else {
            // no biometry
            let ac = UIAlertController(title: "Biometry Unavailable", message: "Your device is not configured for biometrix authentication", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac, animated: true)
        }
    }
    
    func setupComposeNote() {
        
        print("setting up note")
        
        
        let noteOptions = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(presentNoteOptions))
        let shareNote = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareNote))
        let lockImage = note!.isLocked ? "lock" : "lock.open"
        let lockNote = UIBarButtonItem(image: UIImage(systemName: lockImage), style: .plain, target: self, action: #selector(lockNote))
        
        navigationItem.rightBarButtonItems = [noteOptions, shareNote, lockNote]
        
        textView.text = note!.body
        textView.delegate = self
        view = textView
        
        delegate?.composeNoteControllerDidLoad(allNotes: allNotes)
        
        let camera = UIBarButtonItem(image: UIImage(systemName: "camera"), style: .plain, target: self, action: #selector(presentImageOptions))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let compose = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(composeNote))
        
        toolbarItems = [camera, flexibleSpace, compose]
        navigationController?.setToolbarHidden(false, animated: true)
        
        let notificationCenter = NotificationCenter.default
        
        
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(showEditingOptions), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(showOptions), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        saveNote()
    }
    
    @objc func presentNoteOptions(_ barButton: UIBarButtonItem) {
        
    }
    
    @objc func shareNote(_ barButton: UIBarButtonItem) {
        let ac = UIActivityViewController(activityItems: [note!.body], applicationActivities: [])
        present(ac, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        // resize the image
        let targetWidth: CGFloat = textView.frame.size.width - 150 // Adjust as needed for padding
        let scaleFactor = targetWidth / image.size.width
        let targetHeight = image.size.height * scaleFactor

        let resizedImage = UIGraphicsImageRenderer(size: CGSize(width: targetWidth, height: targetHeight)).image { _ in
            image.draw(in: CGRect(origin: .zero, size: CGSize(width: targetWidth, height: targetHeight)))
        }
        
        let attachment = NSTextAttachment()
        attachment.image = resizedImage
        let imageString = NSAttributedString(attachment: attachment)
        textView.textStorage.insert(imageString, at: textView.selectedRange.location)
    }
    
    @objc func presentImageOptions(_ barButton: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func composeNote(_ barButton: UIBarButtonItem) {
        
        
        let newNoteView = ComposeNoteController(note: nil, allNotes: allNotes)
        
        newNoteView.delegate = delegate
        
        
        navigationController?.pushViewController(newNoteView, animated: true)
    }
    
    // a Notification contains name of notification and dictionary
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        textView.verticalScrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        
        textView.scrollRangeToVisible(selectedRange)
        
    }
    
    @objc func showOptions() {
        if (navigationItem.rightBarButtonItems?.count != 3) {
            navigationItem.rightBarButtonItems?.remove(at: 0)
        }
    }
    
    @objc func showEditingOptions() {
        
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(finishEditing))
        if navigationItem.rightBarButtonItems?.count == 3 {
            navigationItem.rightBarButtonItems?.insert(done, at: 0)
        }
    }
    
    @objc func finishEditing(_ button: UIBarButtonItem) {
        // dismiss keyboard
        textView.resignFirstResponder() // resign object that is currently receiving user input
    }
    
    func unlockNote() {
        
    }
    
    @objc func lockNote(_ btn: UIBarButtonItem) {
        guard let note = note else { return }
        
        if note.isLocked {
            btn.image = UIImage(systemName: "lock.open")
        } else {
            btn.image = UIImage(systemName: "lock")
        }
        
        note.isLocked.toggle()
        saveNote()
        
    }
    
    func saveNote() {
//        if var allNotes = allNotes {
//            let defaults = UserDefaults.standard
//            note.title = getTitle()
//            note.body = textView.text
//            allNotes[note!.index] = note!
//            defaults.setValue(allNotes, forKey: "allNotes")
//        }
        guard let note = note else { return }
        
        note.title = getTitle()
        note.body = textView.text
        note.dateModified = Date.now
        
        let jsonEncoder = JSONEncoder()
        if let noteData = try? jsonEncoder.encode(allNotes) {
            let defaults = UserDefaults.standard
            defaults.setValue(noteData, forKey: "allNotes")
        } else {
            print("Failed to save from ComposeNoteController")
        }
    }
    
    func getTitle() -> String {
        if let text = textView.text {
            if let firstLineRange = text.range(of: "\n") {
                return String(text[text.startIndex..<firstLineRange.lowerBound])
            } else {
                return "New note"
            }
        } else {
            return "New note"
        }
    }
    
}

protocol ComposeNoteControllerDelegate {
    func composeNoteControllerDidLoad(allNotes: [[Note]])
}
