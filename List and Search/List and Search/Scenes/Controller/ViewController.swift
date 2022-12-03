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
    
    private var items = [String]() {
        didSet {
            listTableView.reloadData()
        }
    }
    
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
        }
        alertController.addAction(confirmButton)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true)
        
    }
    
    @IBAction private func didTapAddBarButtonItem(_ sender: Any) {
        let alertController = UIAlertController(title: "Add New Item", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        
        let defaultButton = UIAlertAction(title: "OK", style: .default, handler: { _ in
            guard let textInput = alertController.textFields?.first?.text else { return }
            self.items.append(textInput)})
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
    
}

