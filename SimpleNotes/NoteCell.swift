//
//  NoteCell.swift
//  SimpleNotes
//
//  Created by Matthew Zierl on 8/18/24.
//

import UIKit

class NoteCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        self.accessoryType = selected ? .checkmark : .none
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    }

}
