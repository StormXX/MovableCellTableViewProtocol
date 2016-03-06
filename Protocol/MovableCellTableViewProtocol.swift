//
//  TableViewMoveCellProtocol.swift
//
//  Created by DangGu on 16/3/2.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

enum SnapShotStatus {
    case Moving
    case Origin
}

protocol MovableCellTableViewProtocol: class{
    // property for moving row
    var snapshot: UIView! { get set }
    var sourceIndexPath: NSIndexPath! { get set }
    var lastPosition: CGPoint! { get set }
    var movingRowGesture: UILongPressGestureRecognizer! { get set }
    // property for tableview auto scroll
    var autoscrollDistance: CGFloat { get set }
    var autoscrollTimer: NSTimer? { get set }
    var isTableViewBelowNavigationBar: Bool { get set }
    
    //extension protocol
    func addMoveCellForTableView()
    func handleLongPressGesture(recognizer: UIGestureRecognizer)
    func autoscrollTimerFired(timer: NSTimer)
    
    //for implement
    func longPressGestureAction(recognizer: UIGestureRecognizer)
    func moveableCellTableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
    func autoscrollTimerAction(timer: NSTimer)
}

extension MovableCellTableViewProtocol where Self:UIViewController {
    
    func addMoveCellForTableView() {
        guard let tableView = self.valueForKey("tableView") as? UITableView else { return }
        movingRowGesture = UILongPressGestureRecognizer(target: self, action: "longPressGestureAction:")
        tableView.addGestureRecognizer(movingRowGesture)
    }
    
    func handleLongPressGesture(recognizer: UIGestureRecognizer) {
        guard let tableView = self.valueForKey("tableView") as? UITableView else { return }
        let positionInTableView = recognizer.locationInView(tableView)
        switch recognizer.state {
        case .Began:
            startMovingRowInTableView(tableView, position: positionInTableView)
        case .Changed:
            moveSnapshotToPosition(positionInTableView)
            autoScrollInTableView(tableView, position: positionInTableView)
            if (autoscrollDistance == 0) {
                moveRowInTableView(tableView, toPosition: positionInTableView)
            }
        default:
            endMovingRowInTableView(tableView)
        }
    }
    
    //MARK: - moving row help method
    func startMovingRowInTableView(tableView: UITableView, position: CGPoint) {
        guard let indexPath = tableView.indexPathForRowAtPoint(position), cell = tableView.cellForRowAtIndexPath(indexPath) else { return }
        cell.selected = false
        cell.highlighted = false
        snapshot = cell.snapshot
        snapshot.center = cell.center
        tableView.addSubview(snapshot)
        UIView.animateWithDuration(0.33) { [unowned self]() -> Void in
            self.updateSnapshot(.Moving)
            cell.toggleMoving(true)
        }
        sourceIndexPath = indexPath
        lastPosition = position
    }
    
    func moveSnapshotToPosition(position: CGPoint) {
        let deltaY = position.y - lastPosition.y
        snapshot.center.y += deltaY
        lastPosition = position
    }
    
    func moveRowInTableView(tableView: UITableView, toPosition position: CGPoint) {
        guard let indexPath = tableView.indexPathForRowAtPoint(position) else { return }
        if indexPath != sourceIndexPath {
            self.moveableCellTableView(tableView, moveRowAtIndexPath: sourceIndexPath, toIndexPath: indexPath)
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([sourceIndexPath], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.endUpdates()
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                cell.toggleMoving(true)
            }
            sourceIndexPath = indexPath
        }
    }
    
    func endMovingRowInTableView(tableView: UITableView) {
        stopAutoscroll()
        guard let cell = tableView.cellForRowAtIndexPath(sourceIndexPath) else { return }
        UIView.animateWithDuration(0.33, animations: { [unowned self]() -> Void in
            self.snapshot.center = cell.center
            self.snapshot.alpha = 0
            cell.toggleMoving(false)
            }) { (finished) -> Void in
                self.snapshot.removeFromSuperview()
                self.snapshot = nil
        }
        sourceIndexPath = nil
    }
    
    func updateSnapshot(status: SnapShotStatus) {
        switch status {
        case .Moving:
            snapshot.alpha = 0.95
        case .Origin:
            snapshot.alpha = 1.0
        }
    }
    
    //MARK: - auto scroll tableview help method
    func autoScrollInTableView(tableView: UITableView, position: CGPoint) {
        func canScroll() -> Bool {
            return (CGRectGetHeight(tableView.frame) + deltaTableViewContentOffSet()) < tableView.contentSize.height
        }
        
        func determineAutoscrollDistanceForSnapShot() {
            autoscrollDistance = 0
            
            if canScroll() && CGRectIntersectsRect(snapshot.frame, tableView.bounds) {
                let distanceToTopEdge = CGRectGetMinY(snapshot.frame) - (CGRectGetMinY(tableView.bounds) - deltaTableViewContentOffSet())
                let distanceToBottomEdge = CGRectGetMaxY(tableView.bounds) - CGRectGetMaxY(snapshot.frame)
//                print("distanceToTopEdge \(distanceToTopEdge) distanceToBottomEdge \(distanceToBottomEdge)")
                
                if distanceToTopEdge < 0 {
                    autoscrollDistance = CGFloat(ceilf(Float(distanceToTopEdge / 5.0)))
                } else if distanceToBottomEdge < 0 {
                    autoscrollDistance = CGFloat(ceilf(Float(distanceToBottomEdge / 5.0))) * -1
                }
            }
        }
        
        determineAutoscrollDistanceForSnapShot()
        
        if autoscrollDistance == 0 {
            guard let timer = autoscrollTimer else { return }
            timer.invalidate()
            autoscrollTimer = nil
        } else if autoscrollTimer == nil {
            autoscrollTimer = NSTimer.scheduledTimerWithTimeInterval((1.0 / 60.0), target: self, selector: "autoscrollTimerAction:", userInfo: nil, repeats: true)
        }
    }
    
    func autoscrollTimerFired(timer: NSTimer) {
        guard let tableView = self.valueForKey("tableView") as? UITableView else { return }
        func legalizeAutoscrollDistance() {
            let minimumLegalizeDistance = (tableView.contentOffset.y - deltaTableViewContentOffSet()) * -1.0
            let maximumLegalizeDistance = tableView.contentSize.height - ((CGRectGetHeight(tableView.frame) + deltaTableViewContentOffSet()) + (tableView.contentOffset.y - deltaTableViewContentOffSet()))
//            print("***********")
//            print("befor autoscrollDistance \(autoscrollDistance)")
            autoscrollDistance = max(autoscrollDistance, minimumLegalizeDistance)
            autoscrollDistance = min(autoscrollDistance, maximumLegalizeDistance)
//            print("after autoscrollDistance \(autoscrollDistance)")
//            print("minimumLegalizeDistance \(minimumLegalizeDistance)")
//            print("maximumLegalizeDistance \(maximumLegalizeDistance)")
        }
        
        legalizeAutoscrollDistance()
        
        tableView.contentOffset.y += autoscrollDistance
        snapshot.frame.origin.y += autoscrollDistance
        
        let position = movingRowGesture.locationInView(tableView)
        lastPosition = position
        moveRowInTableView(tableView, toPosition: position)
    }
    
    func stopAutoscroll() {
        autoscrollDistance = 0
        guard let timer = autoscrollTimer else { return }
        timer.invalidate()
        autoscrollTimer = nil
    }
    
    func deltaTableViewContentOffSet() -> CGFloat {
        guard isTableViewBelowNavigationBar else { return 0.0 }
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        if UIInterfaceOrientationIsLandscape(orientation) {
            return -44.0
        } else {
            return -64.0
        }
    }
}

extension UITableViewCell {
    var snapshot: UIView {
        get {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0);
            self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            
            let snapshot = UIImageView(image: image)
            let layer = snapshot.layer
            layer.shadowOffset = CGSizeMake(-5.0, 0.0);
            layer.shadowRadius = 5.0;
            layer.shadowOpacity = 0.4;
            return snapshot;
        }
    }
    
    func toggleMoving(moving: Bool) {
        let alpha: CGFloat = moving ? 0.0 : 1.0
        self.contentView.alpha = alpha
        self.alpha = alpha
        self.backgroundView?.alpha = alpha
    }
}

extension UIViewController {
    public override func valueForUndefinedKey(key: String) -> AnyObject? {
        return nil
    }
}