//
//  TableViewMoveCellProtocol.swift
//
//  Created by DangGu on 16/3/2.
//  Copyright © 2016年 StormXX. All rights reserved.
//

import UIKit

enum SnapShotStatus {
    case moving
    case origin
}

@objc protocol MoveableCellTableViewProtocol: class {
    // property for moving row
    var snapshot: UIView! { get set }
    var originIndexPath: IndexPath! { get set}
    var sourceIndexPath: IndexPath! { get set }
    var lastPosition: NSValue! { get set }
    var movingRowGesture: UILongPressGestureRecognizer! { get set }
    // property for tableview auto scroll
    var autoscrollDistance: CGFloat { get set }
    var autoscrollTimer: Timer? { get set }
    var isTableViewBelowNavigationBar: Bool { get set }
    
    // for implement
    @objc func longPressGestureAction(_ recognizer: UIGestureRecognizer)
    @objc func autoscrollTimerAction(_ timer: Timer)
    func moveableCellTableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    func moveableCellTableView(_ tableView: UITableView, didEndMoveRowAt originIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    func moveableCellTableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    func moveableCellTableView(_ tableView: UITableView, shouldMoveRowAt indexPath: IndexPath, to destinationIndexPath: IndexPath) -> Bool
    func moveableCellTableView(_ tableView: UITableView, snapshotStartMovingAnimation snapshot: UIView)
    func moveableCellTableView(_ tableView: UITableView, snapshotEndMovingAnimation snapshot: UIView)
}

extension MoveableCellTableViewProtocol where Self:UIViewController {
    func addMoveCellForTableView() {
        guard let tableView = self.value(forKey: "tableView") as? UITableView else { return }
        movingRowGesture = UILongPressGestureRecognizer(target: self, action: #selector(MoveableCellTableViewProtocol.longPressGestureAction(_:)))
        tableView.addGestureRecognizer(movingRowGesture)
    }
    
    func handleLongPressGesture(_ recognizer: UIGestureRecognizer) {
        guard let tableView = self.value(forKey: "tableView") as? UITableView else { return }
        let positionInTableView = recognizer.location(in: tableView)
        switch recognizer.state {
        case .began:
            guard let indexPath = tableView.indexPathForRow(at: positionInTableView), self.moveableCellTableView(tableView, canMoveRowAt: indexPath) else { return }
            startMovingRowInTableView(tableView, position: positionInTableView)
        case .changed:
            guard snapshot != nil else { return }
            moveSnapshotToPosition(positionInTableView)
            autoScrollInTableView(tableView, position: positionInTableView)
            if autoscrollDistance == 0 {
                moveRowInTableView(tableView, toPosition: positionInTableView)
            }
        default:
            guard snapshot != nil else { return }
            endMovingRowInTableView(tableView)
        }
    }
    
    // MARK: - moving row help method
    func startMovingRowInTableView(_ tableView: UITableView, position: CGPoint) {
        guard let indexPath = tableView.indexPathForRow(at: position), let cell = tableView.cellForRow(at: indexPath), let moveableCell = cell as? MoveableCell else { return }
        cell.isSelected = false
        cell.isHighlighted = false
        snapshot = moveableCell.moveableSnapshot
        snapshot.center = cell.center
        tableView.addSubview(snapshot)
        moveableCell.toggleMoving(true)
        UIView.animate(withDuration: 0.33, animations: {
            self.updateSnapshot(.moving)
            self.moveableCellTableView(tableView, snapshotStartMovingAnimation: self.snapshot)
        })
        sourceIndexPath = indexPath
        originIndexPath = indexPath
        lastPosition = NSValue(cgPoint: position)
    }
    
    func moveSnapshotToPosition(_ position: CGPoint) {
        guard snapshot != nil else { return }
        let deltaY = position.y - lastPosition.cgPointValue.y
        snapshot.center.y += deltaY
        lastPosition = NSValue(cgPoint: position)
    }
    
    func moveRowInTableView(_ tableView: UITableView, toPosition position: CGPoint) {
        guard let indexPath = tableView.indexPathForRow(at: position), snapshot != nil && moveableCellTableView(tableView, shouldMoveRowAt: sourceIndexPath, to: indexPath) else { return }
        if indexPath != sourceIndexPath {
            self.moveableCellTableView(tableView, moveRowAt: sourceIndexPath, to: indexPath)
            tableView.beginUpdates()
            tableView.deleteRows(at: [sourceIndexPath], with: .fade)
            tableView.insertRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            if let cell = tableView.cellForRow(at: indexPath) as? MoveableCell {
                cell.toggleMoving(true)
            }
            sourceIndexPath = indexPath
        }
    }
    
    func endMovingRowInTableView(_ tableView: UITableView) {
        stopAutoscroll()
        guard let cell = tableView.cellForRow(at: sourceIndexPath), snapshot != nil, let moveableCell = cell as? MoveableCell else { return }
        UIView.animate(withDuration: 0.33, animations: {
            self.snapshot.center = cell.center
            self.moveableCellTableView(tableView, snapshotEndMovingAnimation: self.snapshot)
        }, completion: { (_) -> Void in
            moveableCell.toggleMoving(false)
            self.snapshot.alpha = 0
            self.snapshot.removeFromSuperview()
            self.snapshot = nil
            self.moveableCellTableView(tableView, didEndMoveRowAt: self.originIndexPath, to: self.sourceIndexPath)
            self.sourceIndexPath = nil
            self.originIndexPath = nil
        })
    }
    
    func updateSnapshot(_ status: SnapShotStatus) {
        switch status {
        case .moving:
            snapshot.alpha = 0.95
        case .origin:
            snapshot.alpha = 1.0
        }
    }
    
    // MARK: - auto scroll tableview help method
    func autoScrollInTableView(_ tableView: UITableView, position: CGPoint) {
        func canScroll() -> Bool {
            return (tableView.frame.height + deltaTableViewContentOffSet()) < tableView.contentSize.height
        }
        
        func determineAutoscrollDistanceForSnapShot() {
            autoscrollDistance = 0
            
            if canScroll() && snapshot.frame.intersects(tableView.bounds) {
                let distanceToTopEdge = snapshot.frame.minY - tableView.bounds.minY + deltaTableViewContentOffSet()
                let distanceToBottomEdge = tableView.bounds.maxY - snapshot.frame.maxY
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
            autoscrollTimer = Timer.scheduledTimer(timeInterval: (1.0 / 60.0), target: self, selector: #selector(MoveableCellTableViewProtocol.autoscrollTimerAction(_:)), userInfo: nil, repeats: true)
        }
    }
    
    func autoscrollTimerFired(_ timer: Timer) {
        guard let tableView = self.value(forKey: "tableView") as? UITableView else { return }
        func legalizeAutoscrollDistance() {
            let minimumLegalizeDistance = (tableView.contentOffset.y - deltaTableViewContentOffSet()) * -1.0
            let maximumLegalizeDistance = tableView.contentSize.height - ((tableView.frame.height + deltaTableViewContentOffSet()) + (tableView.contentOffset.y - deltaTableViewContentOffSet()))
            autoscrollDistance = max(autoscrollDistance, minimumLegalizeDistance)
            autoscrollDistance = min(autoscrollDistance, maximumLegalizeDistance)
        }
        
        legalizeAutoscrollDistance()
        
        tableView.contentOffset.y += autoscrollDistance
        snapshot.frame.origin.y += autoscrollDistance
        
        let position = movingRowGesture.location(in: tableView)
        lastPosition = NSValue(cgPoint: position)
        moveRowInTableView(tableView, toPosition: position)
    }
    
    func stopAutoscroll() {
        autoscrollDistance = 0
        guard let timer = autoscrollTimer else { return }
        timer.invalidate()
        autoscrollTimer = nil
    }
    
    func deltaTableViewContentOffSet() -> CGFloat {
        let isTranslucent = navigationController?.navigationBar.isTranslucent ?? true
        guard isTableViewBelowNavigationBar && isTranslucent else { return 0.0 }
        let orientation = UIApplication.shared.statusBarOrientation
        if UIInterfaceOrientationIsLandscape(orientation) {
            return -44.0
        } else {
            return -64.0
        }
    }
}

protocol MoveableCell: class {
    var moveableSnapshot: UIView { get }
    func toggleMoving(_ moving: Bool)
}

extension MoveableCell where Self:UITableViewCell {
    var moveableSnapshot: UIView {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshot = UIImageView(image: image)
        let layer = snapshot.layer
        layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.4
        return snapshot
    }
    
    func toggleMoving(_ moving: Bool) {
        let alpha: CGFloat = moving ? 0.0 : 1.0
        self.contentView.alpha = alpha
        self.alpha = alpha
        self.backgroundView?.alpha = alpha
    }
}

extension UIViewController {
    open override func value(forUndefinedKey key: String) -> Any? {
        return nil
    }
}
