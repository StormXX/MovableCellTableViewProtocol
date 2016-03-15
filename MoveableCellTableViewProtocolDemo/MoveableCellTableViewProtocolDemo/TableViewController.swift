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
    var sourceIndexPath: NSIndexPath!
    var originIndexPath: NSIndexPath!
    var lastPosition: CGPoint!
    var movingRowGesture: UILongPressGestureRecognizer!
    // property for tableview auto scroll
    var autoscrollDistance: CGFloat = 0
    var autoscrollTimer: NSTimer?
    var isTableViewBelowNavigationBar: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        addMoveCellForTableView()
        dataArray = ["Planning", "Processing", "Done", "WTF", "啊哈", "good", "拥抱", "温柔", "突然好想你", "如烟", "有些事现在不做一辈子都不会做了", "知足", "孙悟空", "诺亚方舟", "仓颉", "后青春期的诗", "天使", "倔强", "时光机"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        cell.toggleMoving(false)
        cell.textLabel?.text = dataArray[indexPath.row]
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
}

extension TableViewController: MoveableCellTableViewProtocol {
    func longPressGestureAction(recognizer: UIGestureRecognizer) {
        handleLongPressGesture(recognizer)
    }
    
    func autoscrollTimerAction(timer: NSTimer) {
        autoscrollTimerFired(timer)
    }

    func moveableCellTableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let originData = dataArray[sourceIndexPath.row]
        dataArray.removeAtIndex(sourceIndexPath.row)
        dataArray.insert(originData, atIndex: destinationIndexPath.row)
    }

    func moveableCellTableView(tableView: UITableView, didEndMoveRowAtIndexPath originIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
    }
    
    
}