//
//  AddNoteViewController.swift
//  Coffee Notes
//
//  Created by Ali Amanvermez on 7.08.2023.
//

import UIKit
import CoreData
class AddNoteViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextView!
    var chosenNote = ""
    var chosenNoteId : UUID?
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfiguration()
        if chosenNote != "" {
            fetchCoreData()
        }
    }
    
    func viewConfiguration(){
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    
    }
    
    func fetchCoreData(){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
            
            let idString = chosenNoteId?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let title = result.value(forKey: "title") as? String {
                            titleTextField.text = title
                        }
                        if let note = result.value(forKey: "note") as? String {
                            noteTextField.text = note
                        }
                    
                    }
                }
                
            }catch {
                print("fetch error")
            }
    }
    
    @IBAction func addNoteClicked(_ sender: Any) {
        
        //Genel Core Data App Delegate Casting ve context oluşturma
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //Core Data'nın içindeki Notes Entity'sine erişme
        let newNote = NSEntityDescription.insertNewObject(forEntityName: "Notes", into: context)
        
        //Textfield ve Textview'dan gelen değerleri Core Data'ya kaydetme
        
        newNote.setValue(titleTextField.text, forKey: "title")
        newNote.setValue(noteTextField.text, forKey: "note")
        newNote.setValue(UUID(), forKey: "id")
        newNote.setValue(Date(), forKey: "date")
        
        do{
            try context.save()
            print("Saved")
        }catch{
            print("Error : Core Data can not saved")
        
        }
        
        
        //Aşğıdaki Notification Center kodunu detaylıca açıklarsak : NotificationCenter'ın default değerine post methodu ile bir notification gönderiyoruz. Bu notification'ın adını "newDataAdded" olarak belirliyoruz. Bu notification'ı gönderirken object olarak nil değerini gönderiyoruz. Bu notification'ı gönderdiğimizde NotesViewController'da bu notification'ı dinleyen bir kodumuz varsa bu notification'ı dinleyen kod çalışacak.
        NotificationCenter.default.post(name: NSNotification.Name("newDataAdded"), object: nil)
        
        self.navigationController?.popViewController(animated: true)
    }
}
