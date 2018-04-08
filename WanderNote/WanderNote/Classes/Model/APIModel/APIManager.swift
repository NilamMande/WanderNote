//
//  APIManager.swift
//  WanderNote
//
//  Created by Nilam on 4/8/18.
//  Copyright © 2018 Wander. All rights reserved.
//

import UIKit
import RxSwift

class APIManager: NSObject {
    static let sharedInstance: APIManager = APIManager()

    func getNotesAPIRequest(_ params: [String:String]? = nil) ->  Observable<[NoteModel]>?{
        let urlStr = kServerAPIUrl + kAPI_GetNotes
        var notesArray = [NoteModel]()
        return Endpoint.Request().get(path: urlStr, params: params)
            .map { data in
                let json = data as! [String:AnyObject]
                let status = json["status"] as! String
                if status == "SUCCESS"{
                    guard let responseObject = json["object"] else{return notesArray}
                    let object = responseObject as! [String:AnyObject]
                    guard let totalNotes = object["notes"] else{return notesArray}
                   
                    let notes = totalNotes as! [[String:AnyObject]]
                    for note in notes{
                        let pastNote = NoteModel(noteName: note["name"] as! String, details: note["details"] as! String)
                        notesArray.append(pastNote)
                    }
                }
                return  notesArray
        }
    }
    
    func saveNoteAPIRequest(_ params: [String:String]? = nil) ->  Observable<Bool>?{
        let urlStr = kServerAPIUrl + kAPI_SaveNote
        return Endpoint.Request().post(path: urlStr, params: params as [String : AnyObject]?)
            .map { data in
                let json = data as! [String:AnyObject]
                let status = json["status"] as! String
                if status == "SUCCESS"{
                    return true
                } else {
                    throw ApiError.invalidConversations
                }
        }
    }
}

public enum ApiError: Error {
    case error(description: String)
    case invalidConversations
}
