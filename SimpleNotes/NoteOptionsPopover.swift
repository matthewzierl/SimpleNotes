//
//  NoteOptionsPopover.swift
//  SimpleNotes
//
//  Created by Matthew Zierl on 8/18/24.
//

import UIKit

class NoteOptionsPopover: UITableViewController {
    
    var options = ["View as Gallery", "Select Notes", "Open Random Note", "Compose Note"]
    
    var delegate: NoteOptionsPopoverDelegate?
    
    var isCollectionView = false {
        didSet {
            if isCollectionView {
                options = ["View as List", "Select Notes", "Open Random Note", "Compose Note"]
            } else {
                options = ["View as Gallery", "Select Notes", "Open Random Note", "Compose Note"]
            }
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OptionCell")
        
        preferredContentSize = CGSize(width: 225, height: options.count * 44) // usually for popover views

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return options.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
        let option = options[indexPath.row]
        
        
        var config = cell.defaultContentConfiguration()
        config.text = option
        
        var image: UIImage!
        
        switch option {
        case "View as List":
            image = UIImage(systemName: "list.bullet")
        case "View as Gallery":
            image = UIImage(systemName: "square.grid.2x2")
        case "Select Notes":
            image = UIImage(systemName: "checkmark.circle")
        case "Open Random Note":
            image = UIImage(systemName: "questionmark.square")
        case "Compose Note":
            image = UIImage(systemName: "square.and.pencil")
        default:
            break
        }
        
        let imageView = UIImageView(image: image)
        
        cell.contentConfiguration = config
        cell.accessoryView = imageView
        
        
        
        return cell
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.isEditing = true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch options[indexPath.row] {
        case "View as List":
            delegate?.switchViewMode()
            dismiss(animated: true)
            break
        case "View as Gallery":
            // tell main view to change view
            // switch cell for "View as List"
            delegate?.switchViewMode()
            dismiss(animated: true)
            break
        case "Select Notes":
            // let cells be selectable?
            delegate?.selectNotes()
            dismiss(animated: true)
            break
        case "Open Random Note":
            // choose random note to push to navigation stack
            delegate?.openRandomNote()
            dismiss(animated: true)
            break
        case "Compose Note":
            // tell main view to compose new note
            delegate?.composeNote()
            dismiss(animated: true)
            break
        default:
            break
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol NoteOptionsPopoverDelegate {
    func switchViewMode()
    func selectNotes()
    func openRandomNote()
    func composeNote()
}
