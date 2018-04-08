//
//  ListTableViewCell.swift
//  WanderNote
//
//  Created by Nilam on 4/8/18.
//  Copyright © 2018 Wander. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupCell(_ note : NoteModel) {
        self.nameLabel.textColor = UIColor.darkGray
        self.nameLabel.text = note.name!
    }
}
