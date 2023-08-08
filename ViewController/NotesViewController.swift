//
//  NotesViewController.swift
//  Coffee Notes
//
//  Created by Ali Amanvermez on 7.08.2023.
//

import UIKit
import CoreData
class NotesViewController: UIViewController {
    
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var notesTableView: UITableView!
    
    var noteTitleArray = [String]()
    var noteIdArray = [UUID]()
    var selectedNote = ""
    var selectedNoteID : UUID?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        getDataFromCoreData()
    }
    
    //AddObserver işlemini açıklarsak : Notification Center'ın default değerine addObserver methodu ile bir notification dinleyicisi ekliyoruz. Bu notification'ın adını post işlemini yaparken kullandığımız key olan "newDataAdded" olarak belirliyoruz. Bu notification'ı dinlerken NotesViewController'da bu notification'ı dinleyen bir kodumuz varsa bu notification'ı dinleyen kod çalışacak.
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getDataFromCoreData), name: NSNotification.Name("newDataAdded"), object: nil)
    }
    
    func setUpView(){
        notesTableView.delegate = self
        notesTableView.dataSource = self
    }
    
    @objc func getDataFromCoreData(){
        noteTitleArray.removeAll(keepingCapacity: false)
        noteIdArray.removeAll(keepingCapacity: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        //Verileri çekme işlemi nasıl yapılır?
        //Burada gördüğümüz gibi bir fetch request oluşturuyoruz ve bu fetch request'i Notes Entity'sine gönderiyoruz.
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        //returnsObjectsAsFaults neden kullanılır? Bu değer false olarak ayarlanırsa verileri çekerken hafızada tutar ve verileri çekerken hafızada tuttuğu için performansı arttırır.
        fetchRequest.returnsObjectsAsFaults = false
        
        //Aşağıdaki kod bloğunda tümüyle şunu yapıyoruz : fetch request'i çalıştırıyoruz ve bu fetch request'in sonuçlarını results değişkenine atıyoruz. Bu results değişkeni bir NSManagedObject dizisi. Bu diziyi for döngüsü ile dönüyoruz ve her bir result değerini NSManagedObject olarak cast ediyoruz. Daha sonra bu NSManagedObject'in title ve id değerlerini alıyoruz ve noteTitleArray ve noteIdArray dizilerine atıyoruz.
        do {
            let results = try context.fetch(fetchRequest)
            for result in results as! [NSManagedObject] {
                if let noteTitle = result.value(forKey: "title") as? String {
                    self.noteTitleArray.append(noteTitle)
                }
                if let noteId = result.value(forKey: "id") as? UUID {
                    self.noteIdArray.append(noteId)
                }
                self.notesTableView.reloadData()
            }
        } catch{
            print("Fetch error")
        }
        
        
        
        
        
    }
    
    @IBAction func addNoteClicked(_ sender: Any) {
        selectedNote = ""
        performSegue(withIdentifier: "toAddNoteVC", sender: nil)
    }
    
}

extension NotesViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteTitleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = noteTitleArray[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddNoteVC" {
            let destinationVC = segue.destination as! AddNoteViewController
            destinationVC.chosenNote = selectedNote
            destinationVC.chosenNoteId = selectedNoteID
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedNote = noteTitleArray[indexPath.row]
        selectedNoteID = noteIdArray[indexPath.row]
        performSegue(withIdentifier: "toAddNoteVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
            let idString = noteIdArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try! context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == noteIdArray[indexPath.row] {
                                context.delete(result)
                                noteTitleArray.remove(at: indexPath.row)
                                noteIdArray.remove(at: indexPath.row)
                                self.notesTableView.reloadData()
                                do {
                                    try context.save()
                                } catch {
                                    print("Error")
                                }
                            }
                        }
                    }
                }
            } catch {
                print("Error")
            
            }
            
            
            
        }
    }
    
    
}
