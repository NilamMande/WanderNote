//
//  NoteViewModel.swift
//  WanderNote
//
//  Created by Nilam on 4/8/18.
//  Copyright © 2018 Wander. All rights reserved.
//

import UIKit

class NoteViewModel: NSObject {

    class var shared: NoteViewModel {
        struct Singleton {
            static let instance = NoteViewModel()
        }
        return Singleton.instance
    }
    
    var listArray = [NoteModel?]()
    
}
