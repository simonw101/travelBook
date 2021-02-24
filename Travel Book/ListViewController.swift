//
//  ListViewController.swift
//  Travel Book
//
//  Created by Simon Wilson on 24/02/2021.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var titleArray = [String]()
    
    var idArray = [UUID]()
    
    var chosenTitle = ""
    
    var chosenTitleId: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addLocation))
        
        getData()
        
        
    }
    
    func getData() {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = appDelegate?.persistentContainer.viewContext {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    
                    self.titleArray.removeAll(keepingCapacity: false)
                    
                    self.idArray.removeAll(keepingCapacity: false)
                    
                    for result in results as! [NSManagedObject] {
                        
                    
                        if let title = result.value(forKey: "title") as? String {
                            
                            self.titleArray.append(title)
                            
                        }
                        
                        if let id = result.value(forKey: "id") as? UUID {
                            
                            self.idArray.append(id)
                            
                        }
                        
                        self.tableView.reloadData()
                        
                    }
                    
                }
                
            } catch {
                
                print("unable to retrieve data")
                
            }
        }
        
    }
    
    @objc func addLocation() {
        chosenTitle = ""
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenTitle = titleArray[indexPath.row]
        chosenTitleId = idArray[indexPath.row]
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewController" {
            
            let destinationVC = segue.destination as? ViewController
            
            destinationVC?.selectedTitle = chosenTitle
            
            destinationVC?.selectedTitleId = chosenTitleId
        }
    }
    
}
