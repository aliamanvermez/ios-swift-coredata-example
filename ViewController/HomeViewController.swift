//
//  NotesViewController.swift
//  Coffee Notes
//
//  Created by Ali Amanvermez on 7.08.2023.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var lastNotesTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()

    }
    
    func setUpTableView(){
        lastNotesTableView.delegate = self
        lastNotesTableView.dataSource = self
        lastNotesTableView.layer.cornerRadius = 16
    }
    
    
    @IBAction func addNoteClicked(_ sender: Any) {
        print("add note clicked")
    }
    
}

extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "Test Note"
        cell.backgroundColor = .blue
        return cell
    }
    
    
}
