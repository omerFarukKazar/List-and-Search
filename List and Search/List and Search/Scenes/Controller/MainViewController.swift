//
//  ViewController.swift
//  List and Search
//
//  Created by Ömer Faruk Kazar on 2.12.2022.
//

import UIKit
import CoreData

final class MainViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak private var listTableView: UITableView!
    
    private var items = [NSManagedObject]() /* {
                                             didSet {
                                             listTableView.reloadData()
                                             didSet başta pratik bir çözüm olarak görünmüştü ancak bir çok farklı fonksiyonalite eklediğimiz için tüm datayı reload etmek her zaman işimize gelmiyor.
                                             }
                                             } */
    private var isFiltering: Bool = false { // This flag is used to handle if search operation is active or not.
        didSet {
            listTableView.reloadData()
        }
    }
    
    private var filteredItems = [NSManagedObject]()
    
    // MARK: - Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        listTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let searchController = UISearchController()
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        fetchItems()
    }
    
    // MARK: - IBActions For Bar Button Items
    @IBAction private func didTapTrashBarButtonItem(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to remove all the items in the list?", preferredStyle: .alert)
        
        let confirmButton = UIAlertAction(title: "Remove all", style: .default) { _ in
            self.items.removeAll()
            self.listTableView.reloadData()
        }
        alertController.addAction(confirmButton)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true)
        // Generic bi alertcontroller yazılabilir.
        // TODO: - Refactoring'de tekrar bak
    }
    
    @IBAction private func didTapAddBarButtonItem(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add New Item", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        
        let defaultButton = UIAlertAction(title: "OK", style: .default, handler: { [weak alertController] _ in // used weak reference to fix retain cycle
            guard let textInput = alertController?.textFields?.first?.text else { return }
            
            self.createItem(values: ["title" : textInput])
            
            self.listTableView.insertRows(at: [IndexPath(row: self.items.count - 1, section: .zero)], with: .automatic) // reloadData() alternatif çözüm ancak birden fazla section kullanıyor olsaydık, items array'ini de indexPath gibi 2D array olarak tanımlamamız gerekirdi.
            // Tableview'in kendi IndexPath'ine bir türlü ulaşamadım maalesef.
            // TODO: - Üstteki sebeplerden dolayı bu çözüm de pek içime sinmedi. Refactoring'te tekrardan bak
        })
        alertController.addAction(defaultButton)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true)
    }
    
    //MARK: - Methods
    /// Fetches items from CoreData and uses completion in order to handle error or success situations.
    private func fetchItems() {
        DBManager.shared.read(completion: { objects, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let object = objects else { return }
                self.items = object
            }
        })
    }
    
    /// Creates item on CoreData and uses completion in order to handle error or success situations.
    /// - Parameter values: A dictionary which corresponds to Core Data Entity Model.
    private func createItem(values: [String : Any]) {
        DBManager.shared.create(entityName: "ListItem",
                                values: values) { object, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let object = object else {
                return
            }
            self.items.append(object)
        }
    }
    
    /// Removes item on CoreData and uses completion in order to handle error or success situations.
    /// - Parameter indexPath: The IndexPath of the element which wanted to delete.
    private func remove(at indexPath: IndexPath) {
        // Silme işlemini obje üzerinden gerçekleştirdik ancak UUID üzerinden gerçekleştirmek belki daha efektif olabilirdi ?
        if isFiltering {
            let object = filteredItems[indexPath.row]
            DBManager.shared.delete(entityName: "ListItem", object: object, completion: { error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            })
            
            items.removeAll { item in
                item == object
            } // Silinen objenin search işlemi yapılmadığı görünümde silinmesi için items'den de silmem gerekti
            filteredItems.remove(at: indexPath.row)
            listTableView.deleteRows(at: [indexPath], with: .fade)
        } else {
            let object = items[indexPath.row]
            DBManager.shared.delete(entityName: "ListItem", object: object, completion: { error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            })
            items.remove(at: indexPath.row)
            listTableView.deleteRows(at: [indexPath], with: .fade)
        }
        // items'in didSet'inde listTableView.reloadData() fonksiyonunu da kullanabilirdik ancak                                     listTableView.deleteRows(at: [indexPath], with: .fade) kullanıp row'u deleteRows fonksiyonu çağırarak silmemiz daha sağlıklı bu sayede tüm tableview yeniden yüklenmez. Bu tableview elemanları basit olduğu ( text'ten ibaret, içerisinde birden çok kompleks view element barındırmıyor ) için, çok fazla tableview elemanı olmayacağı için ve API bağlantısı olmadığı için didSet'te tableView.reloadData() fonksiyonu ile handle etmek performans açısından sorun olmaz ancak diğer türlü büyük problem yaratırdı.
        
        // NOTE: - The reloadSections:withRowAnimation: and reloadRowsAtIndexPaths:withRowAnimation: methods, which were introduced in iOS 3.0, allow you to request the table view to reload the data for specific sections and rows instead of loading the entire visible table view by calling reloadData.
        
        // Kaynak: https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/TableView_iPhone/ManageInsertDeleteRow/ManageInsertDeleteRow.html#//apple_ref/doc/uid/TP40007451-CH10-SW9
        
        // https://developer.apple.com/documentation/uikit/views_and_controls/table_views#//apple_ref/doc/uid/TP40007451
    }
}

// MARK: UITableViewDelegate & UITableViewDataSource
extension MainViewController: UITableViewDelegate,
                              UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering ? filteredItems.count : items.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            fatalError("UITableViewCell not found.")
        }// UITableViewCell() olarak da oluşturabilirdik ancak o şekilde talbeView'den bağımsız olacağı için, didSelectRow gibi methodlarda sıkıntı çıkabilmesi ihtimaline karşın tableView üzerinden oluşturduk.
        let item = isFiltering ? filteredItems[indexPath.row] : items[indexPath.row]
        cell.textLabel?.text = item.value(forKey: "title") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            remove(at: indexPath)
        }
    }
}

// MARK: - UISearchControllerDelegate
extension MainViewController: UISearchResultsUpdating {
    // Both text and item's title are lowercased and begins searching at the first character.
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text?.lowercased(), text.count > .zero {
            filteredItems = items.filter({ item in
                if let title = item.value(forKey: "title") as? String {
                    return title.lowercased().contains(text)
                }
                return false
            })
            isFiltering = true
        } else {
            filteredItems.removeAll()
            isFiltering = false
        }
    }
}
