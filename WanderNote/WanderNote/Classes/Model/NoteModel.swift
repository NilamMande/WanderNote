//
//  NoteModel.swift
//  WanderNote
//
//  Created by Nilam on 4/8/18.
//  Copyright © 2018 Wander. All rights reserved.
//

import UIKit

class NoteModel {
    var name: String!
    var noteData: String!
    
    init(noteName: String, details: String) {
        name = noteName
        noteData = details
    }
}
