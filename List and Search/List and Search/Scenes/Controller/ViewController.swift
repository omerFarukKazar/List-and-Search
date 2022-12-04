//
//  ViewController.swift
//  List and Search
//
//  Created by Ömer Faruk Kazar on 2.12.2022.
//

import UIKit

final class ViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak private var listTableView: UITableView!
    
    private var items = [String]() /* {
        didSet {
                        listTableView.reloadData()
             didSet başta pratik bir çözüm olarak görünmüştü ancak bir çok farklı fonksiyonalite eklediğimiz için tüm datayı reload etmek her zaman işimize gelmiyor.
        }
    } */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        listTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        listTableView.delegate = self
        listTableView.dataSource = self
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
        
        let defaultButton = UIAlertAction(title: "OK", style: .default, handler: { [weak alertController] _ in // used weak ref to fix retain cycle
            guard let textInput = alertController?.textFields?.first?.text else { return }
            self.items.append(textInput)
            self.listTableView.insertRows(at: [IndexPath(row: self.items.count - 1, section: .zero)], with: .automatic) // reloadData() alternatif çözüm ancak birden fazla section kullanıyor olsaydık, items array'ini de indexPath gibi 2D array olarak tanımlamamız gerekirdi.
            // Tableview'in kendi IndexPath'ine bir türlü ulaşamadım maalesef.
            // TODO: - Üstteki sebeplerden dolayı bu çözüm de pek içime sinmedi. Refactoring'te tekrardan bak
        })
        alertController.addAction(defaultButton)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true)
    }
    
}

// MARK: UITableViewDelegate & UITableViewDataSource
extension ViewController: UITableViewDelegate,
                          UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            fatalError("UITableViewCell not found.")
        }// UITableViewCell() olarak da oluşturabilirdik ancak o şekilde talbeView'den bağımsız olacağı için, didSelectRow gibi methodlarda sıkıntı çıkabilmesi ihtimaline karşın tableView üzerinden oluşturduk.
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Normalde row'u deleteRows fonksiyonu çağırarak silmemiz daha sağlıklı bu sayede tüm tableview yeniden yüklenmez. Bu tableview elemanları basit olduğu ( text'ten ibaret, içerisinde birden çok kompleks view element barındırmıyor ) için, çok fazla tableview elemanı olmayacağı için ve API bağlantısı olmadığı için didSet'te tableView.reloadData() fonksiyonu ile handle etmek performans açısından sorun olmaz ancak diğer türlü büyük problem yaratırdı.
            
            // NOTE: - The reloadSections:withRowAnimation: and reloadRowsAtIndexPaths:withRowAnimation: methods, which were introduced in iOS 3.0, allow you to request the table view to reload the data for specific sections and rows instead of loading the entire visible table view by calling reloadData.
            
            // Kaynak: https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/TableView_iPhone/ManageInsertDeleteRow/ManageInsertDeleteRow.html#//apple_ref/doc/uid/TP40007451-CH10-SW9
            
            // https://developer.apple.com/documentation/uikit/views_and_controls/table_views#//apple_ref/doc/uid/TP40007451
        }
    }
}

