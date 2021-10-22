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
    
    private var sections: [[MessageModel]] = (1...10)
        .map { i -> [MessageModel] in
            (0..<i)
                .map {
                    MessageModel(imageName: "marty1", message: "\($0) hello", time: "00:00")
                }
        }

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
        let i = sections.count - 1
        var messages = sections[i]
        messages.append(MessageModel())
        sections[i] = messages
        tableView.beginUpdates()
        tableView.re.insertRows(at: [IndexPath(row: messages.count - 1, section: i)], with: .automatic)
        tableView.endUpdates()
    }
    
    @IBAction func trashButtonTapped(_ sender: UIBarButtonItem) {
        sections.removeLast(max(0, sections.count - 1))
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let messages = sections[indexPath.section]
        (cell as? TableViewCell)?.configure(with: messages[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let messages = sections[indexPath.section]
        let message = messages[indexPath.row]
        print("willDisplay: \(message)")
    }
}


extension ViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollView.contentOffset.y =", scrollView.contentOffset.y)
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // Delete text is mirrored, so make sure to always disable it.
        .none
    }
}
