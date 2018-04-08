//
//  DetailsViewController.swift
//  WanderNote
//
//  Created by Nilam on 4/8/18.
//  Copyright © 2018 Wander. All rights reserved.
//

import UIKit
import RxSwift

class DetailsViewController: UIViewController {

    let disposeBag: DisposeBag = DisposeBag()
    @IBOutlet weak var textCountLabel: UILabel!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var submitButton: CustomButton!
    var isNewNote: Bool = true
    var myNote : NoteModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
    }

    func initialSetUp() {
        if isNewNote == false {
            titleText.text = myNote?.name
            noteTextView.text = myNote?.noteData
            submitButton.setTitle("Update", for: .normal)
            noteTextView.textColor = UIColor.darkGray
            textCountLabel.text = "\(300 - noteTextView.text.count)/300"
        } else {
            titleText.text = ""
            noteTextView.text = ""
            submitButton.setTitle("Submit", for: .normal)
            noteTextView.text = "Write your note here..."
            noteTextView.textColor = UIColor.lightGray
            textCountLabel.text = "300/300"
        }
    }
    
    @IBAction func goBackScreen(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveNote(_ sender: Any) {
        if titleText.text?.validateStringForEmpty() == true ||  noteTextView.text?.validateStringForEmpty() == true{
            //no title
            let alertController = UIAlertController(title: "Alert", message:
                "Please fill both title and details", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        if isNewNote == true {
//            saveNoteAPICall()
            saveNewNote()
        } else {
            updateNote()
        }
    }
    
    func saveNewNote() {
        let newNote = NoteModel(noteName: "\(self.titleText.text!)", details: "\(self.noteTextView.text!)")
        NoteViewModel.shared.listArray.insert(newNote, at: 0)
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateNote() {
        let index = NoteViewModel.shared.listArray.index{$0 === myNote}
        NoteViewModel.shared.listArray.remove(at: index!)
        saveNewNote()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func saveNoteAPICall() {
        let parameters = ["name": self.titleText.text!,
                          "details": self.noteTextView.text! ]
        APIManager.sharedInstance.saveNoteAPIRequest(parameters)?
            .subscribe(onNext: { data in
            }, onError: {_err in
                print("Something went wrong.")
                //show error alert
            }, onCompleted: {
                print("completed")
               // show success alert
                self.saveNewNote()
            }).disposed(by: self.disposeBag)
    }
}

extension DetailsViewController: UITextViewDelegate{
//MARK:- TextView Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.darkGray
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Write your note here..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //300 chars restriction
        let textCount = textView.text.count + (text.count - range.length)
        if textCount <= 300 {
          self.textCountLabel.text = "\(300 - textCount)/300"
          return true
        } else {
            self.textCountLabel.text = "0/300"
            return false
        }
    }
}

extension String {
    func validateStringForEmpty() -> Bool {
        if self.isEmpty == true {
            let trimmedString = self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            if trimmedString.isEmpty == true {
                return true
            }
        }
        return false
    }
}
