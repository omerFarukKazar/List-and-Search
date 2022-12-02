//
//  ViewController.swift
//  List and Search
//
//  Created by Ömer Faruk Kazar on 2.12.2022.
//

import UIKit

class ViewController: UIViewController,
                      UITableViewDelegate,
                      UITableViewDataSource{
    
    @IBOutlet weak var listTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        listTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        listTableView.delegate = self
        listTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
         fatalError("UITableViewCell not found.")
        }// UITableViewCell() olarak da oluşturabilirdik ancak o şekilde talbeView'den bağımsız olacağı için, didSelectRow gibi methodlarda sıkıntı çıkabilmesi ihtimaline karşın tableView üzerinden oluşturduk.
        cell.textLabel?.text = "Row - \(indexPath.row)"
        return cell
    }

}

