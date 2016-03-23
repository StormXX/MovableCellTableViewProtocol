# MovableCellTableViewProtocol
A Swift Protocol Extension For Moveable Cell TableView
> if you use Xcode7.3 and Swift 2.2 please use branch "swift2.2" and change the type of `lastPosition` to NSValue!

###Usage

call the `addMoveCellForTableView()` in viewDidLoad() and call the `cell.toggleMoving(false)` in `tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell`

#### Implement Properties
```
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
```
> if your tableview is with a navigationbar, set isTableViewBelowNaviationBar true, otherwise false

#####  Implement delegate
```
func longPressGestureAction(recognizer: UIGestureRecognizer) {
    handleLongPressGesture(recognizer)
}
    
func autoscrollTimerAction(timer: NSTimer) {
    autoscrollTimerFired(timer)
}
    
func moveableCellTableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
    // exchange data code here
}

func moveableCellTableView(tableView: UITableView, didEndMoveRowAtIndexPath originIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
    // end move handle
    }
```

> Because of selector in protocol extension is not supported, so you have to implement the longPressGestureAction(\_:) and autoscrollTimerAction(\_:) and call the handleLongPressGesture(\_:) and autoscrollTimerFired(\_:). If you have a better solution for it, please pull request.

## Minimum Requirement
iOS 8.0

## License
MovableCellTableViewProtocol is released under the MIT license. See [LICENSE](https://github.com/StormXX/MoveableCellTableViewProtocol/blob/master/LICENSE) for details.

## More Info
Have a question? Please [open an issue](https://github.com/StormXX/MoveableCellTableViewProtocol/issues/new)!