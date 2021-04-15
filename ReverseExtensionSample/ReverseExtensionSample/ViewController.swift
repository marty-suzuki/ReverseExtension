//
//  ViewController.swift
//  ReverseExtensionSample
//
//  Created by marty-suzuki on 2017/03/01.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import ReverseExtension

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var messages: [MessageModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.re.dataSource = self
        
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        tableView.re.delegate = self
        tableView.re.scrollViewDidReachTop = { scrollView in
            print("scrollViewDidReachTop")
        }
        tableView.re.scrollViewDidReachBottom = { scrollView in
            print("scrollViewDidReachBottom")
        }
        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableView.automaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        messages.append(MessageModel())
        tableView.beginUpdates()
        tableView.re.insertRows(at: [IndexPath(row: messages.count - 1, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
    
    @IBAction func trashButtonTapped(_ sender: UIBarButtonItem) {
        messages.removeAll()
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        (cell as? TableViewCell)?.configure(with: messages[indexPath.row])
        return cell
    }
}


extension ViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollView.contentOffset.y =", scrollView.contentOffset.y)
    }
}
