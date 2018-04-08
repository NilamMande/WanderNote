//
//  ListViewController.swift
//  WanderNote
//
//  Created by Nilam on 4/8/18.
//  Copyright © 2018 Wander. All rights reserved.
//

import UIKit
import RxSwift

class ListViewController: UIViewController {
    let disposeBag: DisposeBag = DisposeBag()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        fetchNotesDataFromAPI()
        self.tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addNewNote(_ sender: Any) {
        self.performSegue(withIdentifier: "details-view-segue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "details-view-segue" {
                let controller = segue.destination as! DetailsViewController
                 controller.isNewNote = true
        }
    }
    
    func fetchNotesDataFromAPI() {
        APIManager.sharedInstance.getNotesAPIRequest()?
            .subscribe(onNext: { _notes in
                print(_notes)
                NoteViewModel.shared.listArray = _notes
                self.tableView.reloadData()
            }, onError: {_err in
                self.tableView.reloadData()
            }, onCompleted: {
            }).disposed(by: self.disposeBag)
    }
}

// MARK: - Tableview related methods
extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NoteViewModel.shared.listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        cell.setupCell( NoteViewModel.shared.listArray[indexPath.row]!)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            if let viewController = UIStoryboard(name: "Main",
                                                 bundle: nil).instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController {
                viewController.myNote = NoteViewModel.shared.listArray[indexPath.row]!
                viewController.isNewNote = false
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController,
                                                 animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            NoteViewModel.shared.listArray.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
