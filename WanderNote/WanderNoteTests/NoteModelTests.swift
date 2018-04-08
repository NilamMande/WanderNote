//
//  NoteModelTests.swift
//  WanderNoteTests
//
//  Created by Nilam on 4/8/18.
//  Copyright © 2018 Wander. All rights reserved.
//

import XCTest
@testable import WanderNote

class NoteModelTests: XCTestCase {
    var note: NoteModel!

    override func setUp() {
        super.setUp()
        note = NoteModel(noteName: "First Note", details: "This is my sample note data.")
    }
    
    override func tearDown() {
        note = nil
        super.tearDown()
    }
    
    func testForEmptyData() {
        XCTAssertTrue(note.name.isEmpty == false)
        XCTAssertTrue(note.noteData.isEmpty == false)
    }
    
    func testNotesSize() {
        let noteData: String = note.noteData
        XCTAssertTrue(noteData.count <= 300)
    }
}
