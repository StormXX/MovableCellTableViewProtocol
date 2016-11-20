//
//  TableViewController.swift
//  MoveableCellTableViewProtocolDemo
//
//  Created by DangGu on 16/3/6.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

let cellIdentifier = "CellIdentifier"
class TableViewController: UITableViewController {
    
    var dataArray: [String] = []
    
    //MARK: - MovableCellTableViewProtocol Property
    // property for moving row
    var snapshot: UIView!
    var sourceIndexPath: IndexPath!
    var originIndexPath: IndexPath!
    var lastPosition: NSValue!
    var movingRowGesture: UILongPressGestureRecognizer!
    // property for tableview auto scroll
    var autoscrollDistance: CGFloat = 0
    var autoscrollTimer: Timer?
    var isTableViewBelowNavigationBar: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        addMoveCellForTableView()
        tableView.tableFooterView = UIView()
        dataArray = ["Planning", "Processing", "Done", "WTF", "啊哈", "good", "拥抱", "温柔", "突然好想你", "如烟", "有些事现在不做一辈子都不会做了", "知足", "孙悟空", "诺亚方舟", "仓颉", "后青春期的诗", "天使", "倔强", "时光机"]
        dataArray = ["Planning", "Processing", "Done"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.toggleMoving(false)
        cell.textLabel?.text = dataArray[(indexPath as NSIndexPath).row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension TableViewController: MoveableCellTableViewProtocol {
    func longPressGestureAction(_ recognizer: UIGestureRecognizer) {
        handleLongPressGesture(recognizer)
    }
    
    func autoscrollTimerAction(_ timer: Timer) {
        autoscrollTimerFired(timer)
    }

    func moveableCellTableView(_ tableView: UITableView, moveRowAtIndexPath sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath) {
        let originData = dataArray[(sourceIndexPath as NSIndexPath).row]
        dataArray.remove(at: (sourceIndexPath as NSIndexPath).row)
        dataArray.insert(originData, at: (destinationIndexPath as NSIndexPath).row)
    }

    func moveableCellTableView(_ tableView: UITableView, didEndMoveRowAtIndexPath originIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath) {
    }

    func moveableCellTableView(_ tableView: UITableView, canMoveRowAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }
    
}
